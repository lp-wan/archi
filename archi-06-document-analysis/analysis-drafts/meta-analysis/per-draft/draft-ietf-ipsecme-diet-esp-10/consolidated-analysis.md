# Consolidated SCHC Architecture Alignment: draft-ietf-ipsecme-diet-esp-10

## Final Minimal -07 Decision
Not included in final minimal -07: Diet-ESP-specific behavior remains SCHClet/profile-level work.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Easy | Trivial | Yes | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
SCHC Architecture -06 can naturally express the technical model of `draft-ietf-ipsecme-diet-esp-10` with minor clarifications. The principal conceptual mapping involves representing the three Diet-ESP compressors (IIPC, CTEC, EEC) as coordinated SCHClets within a single SCHC Instance owned by the IPsec Security Association (SA). The principal migration difficulty lies in updating the terminology to use SCHC Architecture -06 terms consistently and handling the elision of the RuleID and trial-decryption demultiplexing. Two trivial architecture gaps exist in -06 regarding: (1) allowing the RuleID to be implicit (elided) when uniquely determined by out-of-band context (like the SA), and (2) clarifying that the Dispatcher may delegate routing to the security stack to perform trial decryption wh...

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: Diet-ESP-specific behavior remains SCHClet/profile-level work. (2) |

Most difficult SCHC Architecture change: Not included in final minimal -07: Diet-ESP-specific behavior remains SCHClet/profile-level work. (2)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 2.2 / 4.1: Clarify that when the RuleID is elided, the RuleID is implicit and resolved via the SA context, aligning with the SCHC Architecture's concept of implicit rule selection. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 2.1: Clarify that the three compressors (IIPC, CTEC, EEC) can be modeled as three coordinated SCHClets within a single SCHC Instance associated with the SA. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Throughout the draft: Update terminology to use SCHC Architecture -06 terms consistently (e.g., "SCHC Context", "SCHC Rules", "Session"). |

Most difficult draft-under-study change: Section 2.2 / 4.1: Clarify that when the RuleID is elided, the RuleID is implicit and resolved via the SA context, aligning with the SCHC Architecture's concept of implicit rule selection. (3)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can naturally express the technical model of `draft-ietf-ipsecme-diet-esp-10` with minor clarifications. The principal conceptual mapping involves representing the three Diet-ESP compressors (IIPC, CTEC, EEC) as coordinated SCHClets within a single SCHC Instance owned by the IPsec Security Association (SA). The principal migration difficulty lies in updating the terminology to use SCHC Architecture -06 terms consistently and handling the elision of the RuleID and trial-decryption demultiplexing. Two trivial architecture gaps exist in -06 regarding: (1) allowing the RuleID to be implicit (elided) when uniquely determined by out-of-band context (like the SA), and (2) clarifying that the Dispatcher may delegate routing to the security stack to perform trial decryption wh...

