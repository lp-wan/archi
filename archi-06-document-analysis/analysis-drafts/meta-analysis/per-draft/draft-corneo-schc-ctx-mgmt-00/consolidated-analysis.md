# Consolidated SCHC Architecture Alignment: draft-corneo-schc-ctx-mgmt-00

## Final Minimal -07 Decision
Not included in final minimal -07: composable-rule / Rule Fragment changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | Trivial | Yes | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
- **Natural Expressibility:** SCHC Architecture -06 can naturally express the draft under study. The draft's core mechanisms (nested rules and dynamic branching) fit within the existing concept of SCHC Rules and the C/D engine execution, provided that the sequential execution of composed rule fragments is explicitly recognized.
- **Principal Conceptual Mapping:** The native draft concepts of "compressor/decompressor" map directly to the C/D functions of the **SCHC Instance**. "Context" and "Rules" (including merged, deprecated, and fragment rules) map directly to -06 **Context** and **Rules**.
- **Principal Migration Difficulty:** The main migration difficulty is updating the terminology of the draft from general "endpoints" to specific "Instances" and "Endpoints," and aligning the dynamic

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: composable-rule / Rule Fragment changes are deferred. (3) |

Most difficult SCHC Architecture change: Not included in final minimal -07: composable-rule / Rule Fragment changes are deferred. (3)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Throughout draft: Update to "SCHC Instance (or its C/D function)" and "SCHC Instances" / "Endpoints hosting the Instances" |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4.3: "Distribute and synchronize the updated Context containing the new rules to all participating SCHC Instances via the Domain Manager and Instance Managers. Once confirmed..." |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 7.1 & 7.2: Clarify that the Domain Manager and Instance Manager validate context integrity (DAG verification) and enforce limits during provisioning. |

Most difficult draft-under-study change: Section 4.3: "Distribute and synchronize the updated Context containing the new rules to all participating SCHC Instances via the Domain Manager and Instance Managers. Once confirmed..." (3)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

- **Natural Expressibility:** SCHC Architecture -06 can naturally express the draft under study. The draft's core mechanisms (nested rules and dynamic branching) fit within the existing concept of SCHC Rules and the C/D engine execution, provided that the sequential execution of composed rule fragments is explicitly recognized.
- **Principal Conceptual Mapping:** The native draft concepts of "compressor/decompressor" map directly to the C/D functions of the **SCHC Instance**. "Context" and "Rules" (including merged, deprecated, and fragment rules) map directly to -06 **Context** and **Rules**.
- **Principal Migration Difficulty:** The main migration difficulty is updating the terminology of the draft from general "endpoints" to specific "Instances" and "Endpoints," and aligning the dynamic

