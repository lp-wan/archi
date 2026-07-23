# Consolidated SCHC Architecture Alignment: draft-westerlund-schc-compute-address-00

## Final Minimal -07 Decision
Not included in final minimal -07: compute-address is an early individual draft; SoV/C-D dynamic-state changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Medium
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Medium | Trivial | No | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
This review assesses `draft-westerlund-schc-compute-address-00` against `draft-ietf-schc-architecture-06`. SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping involves treating the draft's Address Tables as part of the Set of Variables (SoV), its secret key as part of the Instance Configuration, and its device and network compressor/decompressor as Endpoints hosting client/server SCHC Instances. The principal migration difficulty is that the draft extensively overloads the term 'context' (e.g., using it for the static rules, device-specific address tables, and device identity), which requires careful, manual architectural interpretation to rewrite. An Architecture gap exists because -06 does not explicitly state that the C/D engine can access...

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: compute-address is an early individual draft; SoV/C-D dynamic-state changes are deferred. (1) |

Most difficult SCHC Architecture change: Not included in final minimal -07: compute-address is an early individual draft; SoV/C-D dynamic-state changes are deferred. (1)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4, Paragraph 2 & Section 2 Terminology: Clarify that the Address Table is maintained as part of the Instance's Set of Variables (SoV) rather than the shared static Context (SoR). |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 7.2, Paragraph 1: Specify that the secret_key is provisioned as part of the Instance Configuration or SoV, rather than the shared Context. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1 & Section 4: Update the terminology to refer to "SCHC Endpoints" hosting "SCHC Instances" participating in a "SCHC Session". |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 9.2 & Section 4: Frame the network-side routing and session mapping in terms of the "Dispatcher" routing packets to the correct "Instance" using a "Discriminator" (e.g. PDU session ID). |

Most difficult draft-under-study change: Section 4, Paragraph 2 & Section 2 Terminology: Clarify that the Address Table is maintained as part of the Instance's Set of Variables (SoV) rather than the shared static Context (SoR). (4)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

This review assesses `draft-westerlund-schc-compute-address-00` against `draft-ietf-schc-architecture-06`. SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping involves treating the draft's Address Tables as part of the Set of Variables (SoV), its secret key as part of the Instance Configuration, and its device and network compressor/decompressor as Endpoints hosting client/server SCHC Instances. The principal migration difficulty is that the draft extensively overloads the term 'context' (e.g., using it for the static rules, device-specific address tables, and device identity), which requires careful, manual architectural interpretation to rewrite. An Architecture gap exists because -06 does not explicitly state that the C/D engine can access...

