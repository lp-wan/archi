# Evidence Notes: draft-munoz-schc-over-dts-iot-02

## analysis-gemini
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

The reference architecture (`draft-ietf-schc-architecture-06`) can naturally express the technical behavior and concepts of the draft under study (`draft-munoz-schc-over-dts-iot-02`). The principal conceptual mapping involves representing the ARQ-FEC fragmentation and defragmentation sub-processes (Assembler and Transporter) as internal components of the Fragmentation/Reassembly (F/R) function within a SCHC Instance. The principal migration difficulty lies in the overloaded term "session" — the draft uses "fragmentation session" to refer to the reassembly of a single packet, whereas -06 defines a "Session" as a persistent communication relationship between Instances. To resolve this, the draft's "fragmentation session" should be rebranded as a "fragmentation transaction" or "reassembly process" whose runtime state resides in the Instance's Set of Variables (SoV). No architecture gaps exist in `draft-ietf-schc-architecture-06` for this draft.

### Architectural risk points

- **Risk:** Term Collision on "Session"
  - **Why it matters:** Conflating the draft's ephemeral "fragmentation session" with the -06 "Session" may lead implementers to tear down the long-lived communication association, losing cached Context references or SoV state upon packet completion.
  - **Consequence for migration:** The draft must be edited to replace "fragmentation session" with "fragmentation transaction", "reassembly process", or "reassembly context", reserving the term "Session" for the long-lived Instance-to-Instance communication channel defined in -06.
- **Risk:** Concurrent Reassembly State in SoV
  - **Why it matters:** The -06 architecture defines the Set of Variables (SoV) as flat runtime parameters. If an implementation assumes a single flat set of variables, it cannot support concurrent fragmentations (distinguished by DTag) as required by the draft.
  - **Consequence for migration:** The draft should clarify that when concurrent fragmentation is supported, the Instance's SoV must maintain a structured map of transaction variables (timers, attempts counters) indexed by the DTag, rather than a single global set of variables.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | 2.3, 2.3.1.2.2, 2.3.1.2.3, 2.3.2, 2.3.2.1, 2.3.2.2, 6, 8.3.1.1 | "fragmentation session" | "fragmentation transaction" (or "reassembly transaction") | REQUIRED FOR TERMINOLOGY MIGRATION | To avoid collision with the -06 "Session" which represents a long-lived communication relationship between Instances. |
| 2 | 2.3 | "fragmentation and defragmentation processes of ARQ-FEC mode are divided into two sub-processes: the assembler sub-process and the transporter sub-process" | "fragmentation and defragmentation processes of the F/R function in the SCHC Instance are divided into two sub-processes: the assembler sub-process and the transporter sub-process" | REQUIRED FOR TERMINOLOGY MIGRATION | Integrates the sub-processes into the -06 "F/R function" component of a "SCHC Instance". |
| 3 | 2.3.2 | "For each active pair of RuleID and DTag values, the sender MUST maintain..." | "For each active pair of RuleID and DTag values, the sender MUST maintain within its Set of Variables (SoV)..." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the storage of runtime variables (timers, counters) with the -06 Set of Variables (SoV). |
| 4 | 2.3.2 | "For each active pair of RuleID and DTag values, the receiver MUST maintain..." | "For each active pair of RuleID and DTag values, the receiver MUST maintain within its Set of Variables (SoV)..." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the storage of runtime variables (timers, counters) with the -06 Set of Variables (SoV). |
| 5 | 2.3.2 | "Each Profile MUST specify which RuleID value(s) corresponds to SCHC F/R messages operating in this mode." | "Each Profile MUST specify which RuleID value(s) in the Context corresponds to SCHC F/R messages operating in this mode." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with the -06 concept of RuleID residing in a Context. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable
- What is the single most important migration issue? Resolving the term collision where the draft uses "fragmentation session" for the ephemeral reassembly of a single packet, whereas -06 uses "Session" for a persistent communication channel between Instances.
