#!/usr/bin/env bash
#
# run_analysis.sh — apply schc_analysis.md to every SCHC draft in this directory.
#
# Three agents (claude, codex, agy) can run concurrently, each in its own terminal.
# Drafts are claimed atomically via mkdir, so no draft is ever analyzed twice.
# All state transitions are appended to analysis/status.log.
#
# Each agent runs with only the tools this analysis needs (read files, write the
# three deliverables). None is given a blanket permission bypass.
#
#   ./run_analysis.sh claude                          # loop until no drafts remain
#   ./run_analysis.sh codex --once                    # one draft, then exit
#   ./run_analysis.sh agy --draft draft-foo-00.txt    # one named draft (re-claims it)
#   ./run_analysis.sh --status                        # state table
#   ./run_analysis.sh --list                          # state, one draft per line
#   ./run_analysis.sh --reap                          # free claims whose owner died
#
# Environment:
#   SCHC_TIMEOUT=3600      per-draft wall-clock limit, seconds
#   SCHC_MAX_FAILS=3       stop a looping run after N consecutive failures (a broken
#                          agent otherwise races through and burns every claim)
#   SCHC_DRY_RUN=1         fake the agent (sleep + touch outputs); for testing the queue
#   SCHC_KEEP_API_KEY=1    keep ANTHROPIC_API_KEY for the claude subprocess (default: strip it)
#   SCHC_OUT_DIR=DIR       write results to DIR instead of ./analysis (second-opinion runs)
#   SCHC_ONLY="a b c"      restrict the queue to these draft stems (subset runs)
#   SCHC_CLAUDE_MODEL / SCHC_CODEX_MODEL / SCHC_AGY_MODEL   override the model

set -uo pipefail

DRAFTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DRAFTS_DIR/.." && pwd)"
TEMPLATE="$DRAFTS_DIR/schc_analysis.md"
ARCH_DRAFT="$DRAFTS_DIR/draft-ietf-schc-architecture-06.txt"
# SCHC_OUT_DIR lets a second opinion (e.g. a Claude re-run) write to its own tree
# so it never overwrites another agent's results. Relative paths are anchored here.
OUT_DIR="${SCHC_OUT_DIR:-$DRAFTS_DIR/analysis}"
case "$OUT_DIR" in /*) ;; *) OUT_DIR="$DRAFTS_DIR/$OUT_DIR" ;; esac
CLAIM_DIR="$OUT_DIR/.claims"
LOG="$OUT_DIR/status.log"

TIMEOUT="${SCHC_TIMEOUT:-3600}"
DRY_RUN="${SCHC_DRY_RUN:-0}"

DELIVERABLES=(verdicts.md schc-architecture-edits.md terminology-migration.diff)

AGENT=""
CURRENT_CLAIM=""   # stem of the draft this process currently owns, "" if none

# --------------------------------------------------------------------------- #
# logging
# --------------------------------------------------------------------------- #

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# log EVENT STEM [NOTE] — one atomic append; kept short so concurrent writes
# from three processes stay under PIPE_BUF and never interleave.
log_event() {
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$(now)" "${AGENT:--}" "$$" "$1" "${2:--}" "${3:--}" >>"$LOG"
}

say() { printf '%s  %-9s %s\n' "$(date -u +%H:%M:%S)" "${AGENT:--}" "$*" >&2; }
die() { printf 'run_analysis.sh: %s\n' "$*" >&2; exit 2; }

# --------------------------------------------------------------------------- #
# drafts
# --------------------------------------------------------------------------- #

# Every *.txt except the reference architecture, smallest first: the big drafts
# get picked up by whichever agent is free rather than blocking the queue.
# SCHC_ONLY, if set, restricts the queue to a space-separated list of draft stems
# (with or without the .txt suffix). Lets a run target just a subset, e.g. the WG docs.
list_drafts() {
    local f base stem
    for f in "$DRAFTS_DIR"/*.txt; do
        [ -e "$f" ] || continue
        base="$(basename "$f")"; stem="${base%.txt}"
        [ "$base" = "draft-ietf-schc-architecture-06.txt" ] && continue
        if [ -n "${SCHC_ONLY:-}" ]; then
            case " ${SCHC_ONLY//.txt/} " in *" $stem "*) ;; *) continue ;; esac
        fi
        printf '%s\t%s\n' "$(wc -c <"$f" | tr -d ' ')" "$f"
    done | sort -n | cut -f2
}

stem_of() { basename "$1" .txt; }

# Last state-bearing event for a draft. SKIP lines are advisory (another agent
# passed it by) and must not mask the real state.
last_event() {
    [ -f "$LOG" ] || return 0
    awk -F'\t' -v s="$1" '$5==s && $4!="SKIP" { ev=$4; ag=$2 } END { if (ev != "") print ev "\t" ag }' "$LOG"
}

is_complete() {
    local stem="$1"
    [ -f "$OUT_DIR/$stem/verdicts.md" ] || return 1
    [ "$(last_event "$stem" | cut -f1)" = "DONE" ]
}

draft_state() {
    local stem="$1" ev ag
    ev="$(last_event "$stem")"; ag="$(printf '%s' "$ev" | cut -f2)"; ev="$(printf '%s' "$ev" | cut -f1)"
    local have_verdicts=0
    [ -f "$OUT_DIR/$stem/verdicts.md" ] && have_verdicts=1

    case "$ev" in
        DONE)
            if [ "$have_verdicts" = 1 ]; then printf 'done\t%s' "$ag"
            else printf 'INCONSISTENT\t%s (DONE logged, verdicts.md missing)' "$ag"; fi ;;
        CLAIMED)
            if [ -d "$CLAIM_DIR/$stem" ]; then printf 'running\t%s' "$ag"
            else printf 'INCONSISTENT\t%s (claimed, claim dir gone)' "$ag"; fi ;;
        FAILED|TIMEOUT|INTERRUPTED)
            printf '%s\t%s' "$(printf '%s' "$ev" | tr 'A-Z' 'a-z')" "$ag" ;;
        REAPED|'')
            printf 'pending\t-' ;;
        *)
            printf '%s\t%s' "$ev" "$ag" ;;
    esac
}

# --------------------------------------------------------------------------- #
# claiming
# --------------------------------------------------------------------------- #

# mkdir is atomic on every POSIX filesystem: exactly one of the three agents wins.
claim() {
    local stem="$1"
    mkdir "$CLAIM_DIR/$stem" 2>/dev/null || return 1
    {
        printf 'agent=%s\npid=%s\nhost=%s\nstarted=%s\n' \
            "$AGENT" "$$" "$(hostname -s)" "$(now)"
    } >"$CLAIM_DIR/$stem/owner"
    CURRENT_CLAIM="$stem"
    return 0
}

release_claim() {
    local stem="${1:-}"
    [ -n "$stem" ] || return 0
    rm -rf "$CLAIM_DIR/$stem"
    [ "$CURRENT_CLAIM" = "$stem" ] && CURRENT_CLAIM=""
    return 0
}

# The winner writes owner/ just after mkdir, so a loser can arrive in between.
# Give it a moment rather than reporting an empty owner.
claim_owner() {
    local f="$CLAIM_DIR/$1/owner" i a
    for i in 1 2 3 4 5 6; do
        [ -f "$f" ] && a="$(sed -n 's/^agent=//p' "$f")"
        [ -n "${a:-}" ] && { printf '%s' "$a"; return 0; }
        sleep 0.05
    done
    printf 'another agent'
}

claim_pid()  { sed -n 's/^pid=//p'  "$CLAIM_DIR/$1/owner" 2>/dev/null; }
claim_host() { sed -n 's/^host=//p' "$CLAIM_DIR/$1/owner" 2>/dev/null; }

# Ctrl-C must free the draft for the other two agents, not strand it.
on_exit() {
    local rc=$?
    if [ -n "$CURRENT_CLAIM" ]; then
        log_event INTERRUPTED "$CURRENT_CLAIM" "released by signal/exit rc=$rc"
        say "INTERRUPTED $CURRENT_CLAIM (claim released)"
        release_claim "$CURRENT_CLAIM"
    fi
    exit $rc
}

# --------------------------------------------------------------------------- #
# prompt rendering
# --------------------------------------------------------------------------- #

render_prompt() {
    local draft_path="$1" stem="$2" dest="$3"

    cat >"$dest" <<EOF
Both documents named below are LOCAL FILES already present on this machine. Read each one in
full with your file-reading tool before you begin. Do not fetch anything from the network, and
do not reconstruct either document from memory — this satisfies the grounding requirement in
Section 0 below.

Write your three deliverables as files, using exactly these paths:

  $OUT_DIR/$stem/verdicts.md
  $OUT_DIR/$stem/schc-architecture-edits.md
  $OUT_DIR/$stem/terminology-migration.diff

Produce File 2 and File 3 only under the conditions the prompt specifies. Emit no other files.
When you are finished, print a one-line summary naming the three verdicts.

---

EOF

    awk -v title="$stem" -v draft="$draft_path" -v arch="$ARCH_DRAFT" '
        function rep(line, key, val,   i) {
            while ((i = index(line, key)) > 0)
                line = substr(line, 1, i - 1) val substr(line, i + length(key))
            return line
        }
        {
            $0 = rep($0, "{{DRAFT_TITLE}}", title)
            $0 = rep($0, "{{DRAFT_URL_OR_TEXT}}", draft)
            $0 = rep($0, "{{SCHC_ARCHITECTURE_URL_OR_TEXT}}", arch)
            print
        }
    ' "$TEMPLATE" >>"$dest"
}

# --------------------------------------------------------------------------- #
# agent invocation
# --------------------------------------------------------------------------- #

agent_argv() {
    local prompt_file="$1" prompt
    prompt="$(cat "$prompt_file")"
    # Least privilege: the analysis only ever needs to read two drafts and write
    # three deliverables. No agent is given blanket permission bypass.
    case "$AGENT" in
        claude)
            # An ANTHROPIC_API_KEY in the environment overrides the claude.ai login and
            # fails if it is stale. Strip it for this subprocess only; SCHC_KEEP_API_KEY=1
            # keeps it for anyone who really is authenticating by key.
            set -- claude -p "$prompt" --allowedTools Read Write Edit Glob Grep
            [ -n "${SCHC_CLAUDE_MODEL:-}" ] && set -- "$@" --model "$SCHC_CLAUDE_MODEL"
            [ "${SCHC_KEEP_API_KEY:-0}" = "1" ] || set -- env -u ANTHROPIC_API_KEY "$@"
            ;;
        codex)
            set -- codex exec --cd "$REPO_ROOT" --sandbox workspace-write "$prompt"
            [ -n "${SCHC_CODEX_MODEL:-}" ] && set -- "$@" --model "$SCHC_CODEX_MODEL"
            ;;
        agy)
            set -- agy -p "$prompt" --mode accept-edits --print-timeout 60m
            [ -n "${SCHC_AGY_MODEL:-}" ] && set -- "$@" --model "$SCHC_AGY_MODEL"
            ;;
        *) die "unknown agent '$AGENT'" ;;
    esac
    printf '%s\0' "$@"
}

agent_model() {
    case "$AGENT" in
        claude) printf '%s' "${SCHC_CLAUDE_MODEL:-default}" ;;
        codex)  printf '%s' "${SCHC_CODEX_MODEL:-default}"  ;;
        agy)    printf '%s' "${SCHC_AGY_MODEL:-default}"    ;;
    esac
}

# There is no timeout(1) on macOS, so: agent in the background, killer alongside,
# wait on the agent, then retire the killer.
run_with_timeout() {
    local run_log="$1"; shift
    local apid kpid rc

    "$@" >"$run_log" 2>&1 &
    apid=$!

    ( sleep "$TIMEOUT"; kill -TERM "$apid" 2>/dev/null ) &
    kpid=$!

    wait "$apid"; rc=$?

    kill "$kpid" 2>/dev/null
    wait "$kpid" 2>/dev/null

    return $rc
}

# --------------------------------------------------------------------------- #
# one draft
# --------------------------------------------------------------------------- #

analyze() {
    local draft_path="$1" stem dest started ended rc elapsed produced=0 f
    stem="$(stem_of "$draft_path")"
    dest="$OUT_DIR/$stem"

    mkdir -p "$dest"
    render_prompt "$draft_path" "$stem" "$dest/_prompt.md"

    started="$(now)"
    local t0=$SECONDS
    say "START     $stem"

    if [ "$DRY_RUN" = "1" ]; then
        sleep $(( (RANDOM % 3) + 1 ))
        for f in "${DELIVERABLES[@]}"; do printf 'dry run\n' >"$dest/$f"; done
        printf 'dry run: %s on %s\n' "$AGENT" "$stem" >"$dest/_run.log"
        rc=0
    else
        local argv=()
        while IFS= read -r -d '' a; do argv+=("$a"); done < <(agent_argv "$dest/_prompt.md")
        run_with_timeout "$dest/_run.log" "${argv[@]}"
        rc=$?
    fi

    elapsed=$(( SECONDS - t0 ))
    ended="$(now)"

    for f in "${DELIVERABLES[@]}"; do
        [ -s "$dest/$f" ] && produced=$(( produced + 1 ))
    done

    cat >"$dest/_meta.json" <<EOF
{
  "draft": "$stem",
  "agent": "$AGENT",
  "model": "$(agent_model)",
  "host": "$(hostname -s)",
  "pid": $$,
  "started": "$started",
  "ended": "$ended",
  "duration_seconds": $elapsed,
  "exit_code": $rc,
  "deliverables_produced": $produced,
  "dry_run": $( [ "$DRY_RUN" = "1" ] && echo true || echo false )
}
EOF

    # SIGTERM from the watchdog surfaces as 143; distinguish it from a real failure.
    if [ $rc -eq 143 ] && [ $elapsed -ge "$TIMEOUT" ]; then
        log_event TIMEOUT "$stem" "killed after ${elapsed}s"
        say "TIMEOUT   $stem after ${elapsed}s (claim released)"
        release_claim "$stem"
        return 1
    fi

    if [ $rc -ne 0 ]; then
        log_event FAILED "$stem" "exit=$rc after ${elapsed}s, claim released"
        say "FAILED    $stem exit=$rc (see $dest/_run.log)"
        release_claim "$stem"
        return 1
    fi

    # verdicts.md is the one unconditional deliverable; without it the run did not happen.
    if [ ! -s "$dest/verdicts.md" ]; then
        log_event FAILED "$stem" "no verdicts.md after ${elapsed}s, claim released"
        say "FAILED    $stem produced no verdicts.md (see $dest/_run.log)"
        release_claim "$stem"
        return 1
    fi

    log_event DONE "$stem" "$produced files, ${elapsed}s"
    say "DONE      $stem ($produced files, ${elapsed}s)"
    CURRENT_CLAIM=""   # keep the claim dir: it marks the draft as taken
    return 0
}

# --------------------------------------------------------------------------- #
# commands
# --------------------------------------------------------------------------- #

cmd_list() {
    local d stem state
    for d in $(list_drafts); do
        stem="$(stem_of "$d")"
        state="$(draft_state "$stem")"
        printf '%-55s %s\n' "$stem" "$(printf '%s' "$state" | tr '\t' ' ')"
    done
}

cmd_status() {
    local d stem state st ag total=0 done_n=0 run_n=0 fail_n=0 pend_n=0 bad_n=0

    printf '\n%-52s  %-13s  %-8s  %s\n' DRAFT STATE AGENT FILES
    printf '%s\n' "$(printf '%.0s-' $(seq 1 96))"

    for d in $(list_drafts); do
        stem="$(stem_of "$d")"
        state="$(draft_state "$stem")"
        st="$(printf '%s' "$state" | cut -f1)"
        ag="$(printf '%s' "$state" | cut -f2)"

        local files="" f
        for f in "${DELIVERABLES[@]}"; do
            if [ -s "$OUT_DIR/$stem/$f" ]; then files="${files}x"; else files="${files}."; fi
        done

        printf '%-52s  %-13s  %-8s  %s\n' "$stem" "$st" "$ag" "$files"

        total=$(( total + 1 ))
        case "$st" in
            done)         done_n=$(( done_n + 1 )) ;;
            running)      run_n=$(( run_n + 1 )) ;;
            pending)      pend_n=$(( pend_n + 1 )) ;;
            INCONSISTENT) bad_n=$(( bad_n + 1 )) ;;
            *)            fail_n=$(( fail_n + 1 )) ;;
        esac
    done

    printf '\nFILES column: verdicts.md / schc-architecture-edits.md / terminology-migration.diff\n'
    printf '%d drafts: %d done, %d running, %d pending, %d failed, %d inconsistent\n\n' \
        "$total" "$done_n" "$run_n" "$pend_n" "$fail_n" "$bad_n"

    if [ -f "$LOG" ]; then
        printf 'Last 10 events (%s):\n' "$LOG"
        tail -n 10 "$LOG" | awk -F'\t' '{ printf "  %s  %-7s %-12s %s %s\n", $1, $2, $4, $5, ($6=="-"?"":"("$6")") }'
        printf '\n'
    fi
}

# A claim whose owning process is gone (same host, PID not alive) and which never
# reached DONE is dead work: free it for the next agent.
cmd_reap() {
    local c stem pid host me freed=0
    me="$(hostname -s)"
    [ -d "$CLAIM_DIR" ] || { printf 'nothing to reap\n'; return 0; }

    for c in "$CLAIM_DIR"/*; do
        [ -d "$c" ] || continue
        stem="$(basename "$c")"
        is_complete "$stem" && continue

        pid="$(claim_pid "$stem")"; host="$(claim_host "$stem")"

        if [ -n "$host" ] && [ "$host" != "$me" ]; then
            printf 'skip   %-50s owned by %s on another host (%s)\n' "$stem" "$(claim_owner "$stem")" "$host"
            continue
        fi
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            printf 'alive  %-50s pid %s (%s)\n' "$stem" "$pid" "$(claim_owner "$stem")"
            continue
        fi

        AGENT="$(claim_owner "$stem")"
        log_event REAPED "$stem" "stale claim, pid $pid gone"
        AGENT=""
        rm -rf "$c"
        printf 'reaped %-50s (pid %s gone)\n' "$stem" "${pid:-?}"
        freed=$(( freed + 1 ))
    done
    printf '%d claim(s) released\n' "$freed"
}

cmd_run() {
    local once="$1" only="$2"
    local d stem attempted=0 ok=0 streak=0
    local breaker="${SCHC_MAX_FAILS:-3}"   # stop after this many failures in a row

    log_event RUN_START - "timeout=${TIMEOUT}s dry_run=$DRY_RUN"
    trap on_exit INT TERM HUP EXIT

    for d in $(list_drafts); do
        stem="$(stem_of "$d")"

        if [ -n "$only" ] && [ "$stem" != "$(stem_of "$only")" ]; then
            continue
        fi

        if [ -z "$only" ] && is_complete "$stem"; then
            say "SKIP      $stem (already complete)"
            continue
        fi

        if [ -n "$only" ]; then
            release_claim "$stem"       # explicit --draft re-runs it
        fi

        if ! claim "$stem"; then
            log_event SKIP "$stem" "claimed by $(claim_owner "$stem")"
            say "SKIP      $stem (claimed by $(claim_owner "$stem"))"
            continue
        fi

        log_event CLAIMED "$stem"
        attempted=$(( attempted + 1 ))
        if analyze "$d"; then
            ok=$(( ok + 1 )); streak=0
        else
            streak=$(( streak + 1 ))
            # A broken agent (dead credits, bad auth) fails in seconds and would
            # otherwise race through and burn every draft's claim. Bail so the
            # drafts stay pending for a healthy agent.
            if [ -z "$only" ] && [ "$streak" -ge "$breaker" ]; then
                log_event RUN_END - "aborted: $streak consecutive failures, breaker=$breaker"
                say "ABORT     $streak failures in a row — stopping (see the last _run.log)"
                trap - INT TERM HUP EXIT
                return 1
            fi
        fi

        [ "$once" = "1" ] && break
    done

    trap - INT TERM HUP EXIT
    log_event RUN_END - "attempted=$attempted ok=$ok"
    say "run finished: attempted $attempted, succeeded $ok"
    [ "$attempted" -eq "$ok" ]
}

# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #

usage() {
    sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

[ -f "$TEMPLATE" ]   || die "missing prompt template: $TEMPLATE"
[ -f "$ARCH_DRAFT" ] || die "missing reference architecture: $ARCH_DRAFT"

mkdir -p "$OUT_DIR" "$CLAIM_DIR"
touch "$LOG"

[ $# -ge 1 ] || usage 2

case "$1" in
    -h|--help) usage 0 ;;
    --status)  cmd_status; exit 0 ;;
    --list)    cmd_list;   exit 0 ;;
    --reap)    cmd_reap;   exit 0 ;;
    claude|codex|agy) AGENT="$1"; shift ;;
    *) die "first argument must be an agent (claude|codex|agy) or --status|--list|--reap|--help" ;;
esac

command -v "$AGENT" >/dev/null 2>&1 || [ "$DRY_RUN" = "1" ] || die "'$AGENT' not found on PATH"

ONCE=0
ONLY=""
while [ $# -gt 0 ]; do
    case "$1" in
        --once|-1) ONCE=1; shift ;;
        --draft)   ONLY="${2:-}"; [ -n "$ONLY" ] || die "--draft needs a filename"; shift 2 ;;
        *) die "unexpected argument: $1" ;;
    esac
done

if [ -n "$ONLY" ] && [ ! -f "$DRAFTS_DIR/$(basename "$ONLY")" ]; then
    die "no such draft: $ONLY"
fi

cmd_run "$ONCE" "$ONLY"
