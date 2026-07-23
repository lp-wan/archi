# Consolidated SCHC Architecture Alignment: draft-munoz-schc-over-dts-iot-02

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Easy | None | Yes | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
The reference architecture (`draft-ietf-schc-architecture-06`) can naturally express the technical behavior and concepts of the draft under study (`draft-munoz-schc-over-dts-iot-02`). The principal conceptual mapping involves representing the ARQ-FEC fragmentation and defragmentation sub-processes (Assembler and Transporter) as internal components of the Fragmentation/Reassembly (F/R) function within a SCHC Instance. The principal migration difficulty lies in the overloaded term "session" — the draft uses "fragmentation session" to refer to the reassembly of a single packet, whereas -06 defines a "Session" as a persistent communication relationship between Instances. To resolve this, the draft's "fragmentation session" should be rebranded as a "fragmentation transaction" or "reassembly pro...

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | 2.3, 2.3.1.2.2, 2.3.1.2.3, 2.3.2, 2.3.2.1, 2.3.2.2, 6, 8.3.1.1: "fragmentation transaction" (or "reassembly transaction") |
| REQUIRED FOR TERMINOLOGY MIGRATION | 2.3: "fragmentation and defragmentation processes of the F/R function in the SCHC Instance are divided into two sub-processes: the assembler sub-process and the transporter sub-process" |
| REQUIRED FOR TERMINOLOGY MIGRATION | 2.3.2: "For each active pair of RuleID and DTag values, the sender MUST maintain within its Set of Variables (SoV)..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | 2.3.2: "For each active pair of RuleID and DTag values, the receiver MUST maintain within its Set of Variables (SoV)..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | 2.3.2: "Each Profile MUST specify which RuleID value(s) in the Context corresponds to SCHC F/R messages operating in this mode." |

Most difficult draft-under-study change: 2.3: "fragmentation and defragmentation processes of the F/R function in the SCHC Instance are divided into two sub-processes: the assembler sub-process and the transporter sub-process" (5)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The reference architecture (`draft-ietf-schc-architecture-06`) can naturally express the technical behavior and concepts of the draft under study (`draft-munoz-schc-over-dts-iot-02`). The principal conceptual mapping involves representing the ARQ-FEC fragmentation and defragmentation sub-processes (Assembler and Transporter) as internal components of the Fragmentation/Reassembly (F/R) function within a SCHC Instance. The principal migration difficulty lies in the overloaded term "session" — the draft uses "fragmentation session" to refer to the reassembly of a single packet, whereas -06 defines a "Session" as a persistent communication relationship between Instances. To resolve this, the draft's "fragmentation session" should be rebranded as a "fragmentation transaction" or "reassembly pro...

