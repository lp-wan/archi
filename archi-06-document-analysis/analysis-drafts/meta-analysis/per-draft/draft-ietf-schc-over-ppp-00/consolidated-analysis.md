# Consolidated SCHC Architecture Alignment: draft-ietf-schc-over-ppp-00

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: No

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | Very High | Easy | None | Yes | Yes |

## Agreement and Differences
Claude and Gemini agree on headline verdicts and gap status.

## Final Consolidated Assessment
The Static Context Header Compression (SCHC) Architecture -06 can naturally express the draft under study (`draft-ietf-schc-over-ppp-00`) without any conceptual stretching. The principal mapping relates the PPP session to a SCHC Session between two SCHC Instances hosted on SCHC Endpoints, where the PPP connection itself serves as the Discriminator used by the Dispatcher. The principal transition difficulty is editorial: introducing the concepts of "Instance", "Dispatcher", and "Discriminator" (which are absent in the draft) and clearly distinguishing between physical/link-layer endpoints and logical SCHC Endpoints. No architectural gaps exist in `draft-ietf-schc-architecture-06` with respect to this draft. SCHC Architecture -06 can **naturally and completely express** draft-ietf-schc-over-ppp-00. The
draft describes a two-peer, point-to-point (peer-to-peer) SCHC deployment in which a PPP session
establishes a virtual link, a SCHC context with a particular set of Rules is provisioned on both
ends (its URI signaled through an IPV6CP option extended from RFC 5172), both peers run SCHC
Compression/Decompression, optional No-ACK fragmentation is available, and — when Rules are
asymmetric — the session initiator takes the Device role.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, Page 3: Rephrase to specify that a PPP session maps to a SCHC Session between two SCHC Instances, sharing a common Context. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.1, Page 4: Update to state that each peer hosts a SCHC Endpoint with a SCHC Instance running the C/D (and optionally F/R) functions. Rephrase "endpoints" in the physical sense to "peer nodes" or "hosts," and reserve "Endpoint" for the logical SCHC Endpoint. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.1, Page 4: Replace Figure 2 with an updated diagram showing SCHC Instances hosted on SCHC Endpoints within the IP Host and IP Router, with the PPP link serving as the discriminator. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, Page 4: Rephrase to state that the initiator's Instance plays the Downside (Device) role and the responder's Instance plays the Upside (Network) role. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.1, Page 4: Rephrase "endpoints" to "Instances" or "peer nodes" where appropriate. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.1, Page 4 (New Subsection): Add a new subsection 4.1.1 "Architectural Mapping" describing the Dispatcher and Discriminator. Specify that the PPP connection itself serves as the Discriminator, and the Dispatcher routes incoming PPP packets with Protocol 0x0057 to the corresponding SCHC Instance. |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3, first sentence (lines 145–147): State that each PPP session carries a SCHC Session over a virtual link; each peer's Endpoint binds one Instance to the PPP session; the Instances share a common Context whose Set of Rules is indicated at setup |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3, last sentence (lines 179–181): "If the Rules are asymmetric, the SCHC Instance that initiates the PPP session plays the role of the Device defined in [SCHC], following the role convention of the SCHC Architecture." (drop "in an LPWAN network") |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.1, first paragraph (lines 191–196): Recast each side as a SCHC Endpoint (hosted on the IP Host/DTE and on the IP Node/DCE/Ethernet device respectively) that associates one Instance with the PPP connection |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.1, "Both endpoints MUST support the function of SCHC Compressor/Decompressor (C/D)" (lines 198–199): "The Instance on each Endpoint MUST support the SCHC Compression/Decompression (C/D) function." Add: the PPP connection is the Discriminator and PPP demultiplexing is the Dispatcher |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.1, "A context may be generated … The context can be asymetric" (lines 218–231): "A Context may be generated … the Context may contain asymmetric Rules, in which case the two Instances play distinct roles." Capitalize "Context" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.2, RuleID numbering scheme heading text (lines 239–252) and Figure 3 caption: Refer to the wire unit as a SCHC Datagram (RuleID + Compression Residue + Payload), per -06 §4.2.5 |
| REQUIRED FOR TERMINOLOGY MIGRATION | Introduction (lines 106–108) and Informative References (lines 509–514): Cite [I-D.ietf-schc-architecture] (draft-ietf-schc-architecture-06) with updated author list/date |

Most difficult draft-under-study change: Section 4.1, Page 4: Update to state that each peer hosts a SCHC Endpoint with a SCHC Instance running the C/D (and optionally F/R) functions. Rephrase "endpoints" in the physical sense to "peer nodes" or "hosts," and reserve "Endpoint" for the logical SCHC Endpoint. (13)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The Static Context Header Compression (SCHC) Architecture -06 can naturally express the draft under study (`draft-ietf-schc-over-ppp-00`) without any conceptual stretching. The principal mapping relates the PPP session to a SCHC Session between two SCHC Instances hosted on SCHC Endpoints, where the PPP connection itself serves as the Discriminator used by the Dispatcher. The principal transition difficulty is editorial: introducing the concepts of "Instance", "Dispatcher", and "Discriminator" (which are absent in the draft) and clearly distinguishing between physical/link-layer endpoints and logical SCHC Endpoints. No architectural gaps exist in `draft-ietf-schc-architecture-06` with respect to this draft.

### Claude Executive Assessment

SCHC Architecture -06 can **naturally and completely express** draft-ietf-schc-over-ppp-00. The
draft describes a two-peer, point-to-point (peer-to-peer) SCHC deployment in which a PPP session
establishes a virtual link, a SCHC context with a particular set of Rules is provisioned on both
ends (its URI signaled through an IPV6CP option extended from RFC 5172), both peers run SCHC
Compression/Decompression, optional No-ACK fragmentation is available, and — when Rules are
asymmetric — the session initiator takes the Device role.

