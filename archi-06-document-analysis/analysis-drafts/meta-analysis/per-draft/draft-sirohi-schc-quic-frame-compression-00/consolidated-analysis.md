# Consolidated SCHC Architecture Alignment: draft-sirohi-schc-quic-frame-compression-00

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
The reference architecture `draft-ietf-schc-architecture-06` can naturally and completely express the concepts and technical model of `draft-sirohi-schc-quic-frame-compression-00`. The principal conceptual mapping relates the draft's "inner compressor" and "outer compressor" to two separate SCHC Endpoints (or Instances) operating on different Strata (the QUIC frame stratum and the IP/UDP stratum) on the same physical equipment. The principal migration difficulty is ensuring that the implementation architecture and integration options (like the alternative payload syntax and extension frames) are framed using the formal -06 concepts of Datagrams, Control Headers, Dispatchers, and Discriminators rather than implementation-specific terms like "compressor container." No architectural gaps exis...

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2.2, 2.3, 4.1, 5.1: Change to "RuleID" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2.2, 4.3, 6.1, 8: Capitalize as "Context" when referring to the shared SCHC ruleset and parser metadata |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 6.1: Describe as a single SCHC Instance on an Endpoint, with a Context whose Stratum spans the IP, UDP, and QUIC frame layers. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 6.2: Describe as separate SCHC Endpoints (or Instances) operating at different Strata (inner frames vs outer headers) on the same physical equipment. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 5.2: Frame as a Control Header placed before the RuleID of the SCHC Datagram. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 5.3: Frame as the Extension Frame Type acting as a Dispatcher Discriminator to route the incoming packet to the correct SCHC Instance, representing the RuleID. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.4: Describe stateful rules in terms of the Set of Variables (SoV), distinguishing it from the static Set of Rules (SoR) in the Context. |

Most difficult draft-under-study change: Section 6.2: Describe as separate SCHC Endpoints (or Instances) operating at different Strata (inner frames vs outer headers) on the same physical equipment. (7)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The reference architecture `draft-ietf-schc-architecture-06` can naturally and completely express the concepts and technical model of `draft-sirohi-schc-quic-frame-compression-00`. The principal conceptual mapping relates the draft's "inner compressor" and "outer compressor" to two separate SCHC Endpoints (or Instances) operating on different Strata (the QUIC frame stratum and the IP/UDP stratum) on the same physical equipment. The principal migration difficulty is ensuring that the implementation architecture and integration options (like the alternative payload syntax and extension frames) are framed using the formal -06 concepts of Datagrams, Control Headers, Dispatchers, and Discriminators rather than implementation-specific terms like "compressor container." No architectural gaps exis...

