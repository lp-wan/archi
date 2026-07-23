# SCHC Architecture -06 — Document Analysis

An AI-assisted expressibility and migration analysis of the SCHC document set,
evaluated against the baseline **`draft-ietf-schc-architecture-06`**.

> ⚠️ **These analyses are AI-generated and have not been human-reviewed.**
> They are a research/working aid, not IETF consensus. The authoritative
> documents are the Internet-Drafts and RFCs themselves. Treat every verdict,
> edit suggestion, and diff below as a machine-produced hypothesis to be checked.

## What this is

Each SCHC draft (and each published SCHC RFC) was analyzed **independently against
the same reference architecture** (`draft-ietf-schc-architecture-06`) to answer three
questions:

1. **Conceptual equivalence** — can the document's ideas be expressed in the -06
   architecture's vocabulary and model?
2. **Transition difficulty** — how hard is it to migrate the document's terminology
   and mechanisms onto -06?
3. **Architecture adaptation need** — does -06 itself need to change to accommodate
   the document?

A synthesis ("meta") layer then consolidated the results into a **minimal proposal
for Architecture -07**.

## Models used

Two models analyzed each document independently:

- **Claude Opus 4.8** — see `analysis-drafts/analysis-claude/`.
- **Gemini 3.5 Flash (High)** — see `analysis-drafts/analysis-gemini/` (drafts) and
  `analysis-lpwan-rfc/` (RFCs).

The RFC set was analyzed by Gemini only. Because two independent models ran the same
prompt, the meta layer can flag where they disagreed (see below).

## Method

- Every document was analyzed with one shared prompt: `prompt/schc_analysis.md`.
- The driver `prompt/run_analysis.sh` renders that template into a per-document prompt
  (the `_prompt.md` stored beside each result) and runs one model on it, grounding it in
  two local files: the document under study and the -06 architecture text.
- Each run produced three deliverables:
  - `verdicts.md` — the three verdicts above, with rationale and evidence.
  - `schc-architecture-edits.md` — proposed edits to the architecture (only where warranted).
  - `terminology-migration.diff` — proposed terminology migration for that document.
- `_meta.json` beside each run records the agent and timing (start/end/duration).

## Layout

| Path | Contents |
|------|----------|
| `sources/` | The analyzed source documents. `draft-ietf-schc-architecture-06.txt` is the baseline; `drafts/` holds the 19 drafts under study; `rfcs/` holds the 7 SCHC RFCs. |
| `prompt/` | The master prompt (`schc_analysis.md`) and the driver (`run_analysis.sh`). |
| `analysis-drafts/` | The draft analyses and their synthesis (see the three sub-folders below). |
| `analysis-drafts/analysis-claude/` | Per-draft raw analysis from **Claude Opus 4.8**. |
| `analysis-drafts/analysis-gemini/` | Per-draft raw analysis from **Gemini 3.5 Flash (High)**. |
| `analysis-drafts/meta-analysis/` | The consolidated synthesis: `recap.md` (one row per draft), `incompatibilities.md` (**where the Claude and Gemini analyses disagreed** — a two-model divergence / calibration-difference index), `schc-architecture-07-proposal.md`, the `06-to-07` diff, and `per-draft/<doc>/` consolidated analyses + evidence. |
| `analysis-lpwan-rfc/` | Per-RFC raw analysis (Gemini 3.5 Flash (High)) for the 7 SCHC RFCs. |

Each per-document folder (under `analysis-drafts/analysis-claude/`,
`analysis-drafts/analysis-gemini/`, and `analysis-lpwan-rfc/`) contains: `_prompt.md`
(the exact prompt sent), `_meta.json` (agent + timing), `verdicts.md`,
`schc-architecture-edits.md`, and `terminology-migration.diff`.

## The meta-analysis, in one line

The consolidated package deliberately draws only on the Claude and Gemini runs, and
applies a **minimal-diff policy**: the proposed Architecture -07 change set is narrowed
to a single item (Control Header routing / inspection pointers). Other candidate changes
surfaced by the analysis are retained as **evidence** but are *not* proposed for -07.
Because two independent models analyzed the same documents,
`analysis-drafts/meta-analysis/incompatibilities.md` records **where Claude and Gemini
reached different conclusions** — the low-confidence spots where human judgment matters
most. See `analysis-drafts/meta-analysis/README.md` for the exact policy.

## How it was run

The analyses were produced by `prompt/run_analysis.sh`, which applies
`prompt/schc_analysis.md` to each source document against the -06 architecture text and
invokes the model CLI per document. The script and prompt are included here so the exact
inputs and instructions are reproducible; regenerating the outputs requires the model CLIs
the script drives.

## Provenance & license

- The source drafts and RFCs are IETF documents, published under the terms of
  [BCP 78](https://www.rfc-editor.org/info/bcp78); rights remain with their authors
  and the IETF Trust.
- The analysis outputs in this folder are machine-generated for study purposes.
- For the architecture draft itself, see the parent repository's `README.md`
  ("SCHC Minimal Architecture").
