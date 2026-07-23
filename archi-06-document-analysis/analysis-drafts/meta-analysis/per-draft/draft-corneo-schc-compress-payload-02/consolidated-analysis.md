# Consolidated SCHC Architecture Alignment: draft-corneo-schc-compress-payload-02

## Final Minimal -07 Decision
Not included in final minimal -07: payload-oriented Architecture changes are deferred for author discussion.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Medium
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Easy | Medium | Yes | No |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
- **Natural expressibility:** SCHC Architecture -06 cannot naturally express the draft under study in its current form because the architecture's core definitions (SCHC, C/D, and Stratum) restrict processing exclusively to protocol headers.
- **Principal conceptual mapping:** The draft's template-based payload compression maps to a profile-specific C/D operation on a parsed payload field. The `equal-template` MO maps to a custom Matching Operator (MO), and the payload template maps to the Target Value (TV) field of a rule.
- **Principal migration difficulty:** Terminology migration is straightforward (mostly mechanical substitutions of "SCHC node" to "SCHC Instance"). The main architectural challenge lies in the tight coupling of the `equal-template` MO with residue extraction, which devia

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: payload-oriented Architecture changes are deferred for author discussion. (6) |

Most difficult SCHC Architecture change: Not included in final minimal -07: payload-oriented Architecture changes are deferred for author discussion. (6)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1 (Introduction): Clarify that payload compression operates within a SCHC Instance using rules defined in the Context, and that the C/D engine of the Instance performs the compression/decompression. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2.1 (Matching Procedure): Clarify that the C/D engine of the compressing Instance executes these steps when evaluating the rule. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2.4 (Match Failure): Change "SCHC compressor" to "C/D engine of the compressing Instance". |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4: Clarify that these FIDs are defined in the Context's Set of Rules (SoR), and that the Parser associated with the Context is responsible for extracting the payload field(s) matching the FID. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 5: Change "SCHC node" to "SCHC Instance". |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 5: Clarify that the C/D engine uses the Parser defined in the Context to identify the payload field corresponding to the payload FID. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 6: Change "SCHC node" to "SCHC Instance". |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 6: Clarify that the Parser and Data Model defined in the Context map the structured JSON payload to these specific FIDs. |

Most difficult draft-under-study change: Section 4: Clarify that these FIDs are defined in the Context's Set of Rules (SoR), and that the Parser associated with the Context is responsible for extracting the payload field(s) matching the FID. (8)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

- **Natural expressibility:** SCHC Architecture -06 cannot naturally express the draft under study in its current form because the architecture's core definitions (SCHC, C/D, and Stratum) restrict processing exclusively to protocol headers.
- **Principal conceptual mapping:** The draft's template-based payload compression maps to a profile-specific C/D operation on a parsed payload field. The `equal-template` MO maps to a custom Matching Operator (MO), and the payload template maps to the Target Value (TV) field of a rule.
- **Principal migration difficulty:** Terminology migration is straightforward (mostly mechanical substitutions of "SCHC node" to "SCHC Instance"). The main architectural challenge lies in the tight coupling of the `equal-template` MO with residue extraction, which devia

