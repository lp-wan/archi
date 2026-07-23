# Consolidated SCHC Architecture Alignment: draft-ietf-6lo-schc-15dot4-13

## Final Minimal -07 Decision
Final minimal -07 includes only Control Header routing/inspection pointer metadata; RuleID scope changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Medium
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: No - calibration difference

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Medium | Trivial | No | Yes |
| Claude | High | Easy | Trivial | Yes | Yes |

## Agreement and Differences
Claude and Gemini have a calibration difference: transition: Medium vs Easy.

## Final Consolidated Assessment
Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express almost all of the technical behaviors, protocol stacks, and deployment configurations of the draft under study (`draft-ietf-6lo-schc-15dot4-13`). The principal conceptual mapping translates the draft's "SCHC Data end point" to an -06 "SCHC Instance", and the draft's "SCHC Control Header end point" to a combination of -06's Dispatcher and Instance configurations. The network-wide single or multiple endpoint models map to profile-specific configurations of the Dispatcher and Instance counts. SCHC Architecture -06 **can naturally express** draft-ietf-6lo-schc-15dot4-13. The draft was written against architecture **-05** and already builds on architecture vocabulary (SCHC Stratum, Discriminator, SCHC Control Header, SCHC Datagram, SoR); its wire formats, storage requirements, and the SRO/TRO/PRO/Mesh-Under modes carry over unchanged.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Final minimal -07 | Final minimal -07 includes only Control Header routing/inspection pointer metadata; RuleID scope changes are deferred. (3) |

Most difficult SCHC Architecture change: Final minimal -07 includes only Control Header routing/inspection pointer metadata; RuleID scope changes are deferred. (3)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.2, 3.2.1, 3.2.2, 3.2.3: Rename "SCHC Data end point" to "SCHC Data Instance" or "SCHC Instance", and "SCHC Control Header end point" to "SCHC Control Header Instance" or "Dispatcher context". |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.2.2, 3.2.3: Rename to "Single-Instance networks" and "Multiple-Instance networks" (or "Single-Instance Domains" and "Multiple-Instance Domains"). |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 6.1 (paragraph 4): Reframe this as a profile-specific constraint on the Rule design for PRO, rather than a general update to RFC 8724. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §4.1.2: "This field is an unsigned integer that identifies the SCHC Instance, and thus the Context, that applies to the SCHC Data. The Instances of two or more peer nodes that share that Context (and thus a common SoR) within a Session use the same SCHC Instance ID value." |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §3.2.2, §3.2.3: Redefine as Single-Instance / Multiple-Instance networks: each node hosts one vs. several SCHC Instances, each Instance with its Context (SoR); the Control-Header SoR is stated directly, without an "end point" entity |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.2 intro: Cite the -06 concepts actually used: Endpoint, Instance, Session, Context, SoR, Stratum, Discriminator |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.5.1–3.5.4 text and Figures 8–16 (captions, "Nodes \: "SCHC Data end point called E1", "SCHC Datagram Instance called E1", "same end point identifier ... for two end points that share a Rule", "Single-/Multiple-end point network" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.4, §3.5, §3.5.2, App. A.2/A.3: "nodes" / "as a communicating node" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.1.2, §4.1.3: "identifies the SCHC Instance, and thus the Context, to be used to decompress"; "compressed by a SCHC Instance" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5: "...a Discriminator, used by the Dispatcher to select the appropriate SCHC Instance, and thus the Context (with its SoR)..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.1, §5.2 (incl. Figures 30–36 labels and notes): "the Instance at that SCHC Stratum", "SoR of the Instance at that SCHC Stratum", label "SCHC Control Header" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §6.1, §6.2: "each SCHC Instance needs to know its role (Dev or App), for each Session it participates in, ..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.5.4: "determine the SCHC Instance (and thus the Context) ... ; in that case, the originator address is used as a Discriminator" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §12.1 and all citations: Reference -06; unify inline citations to [I-D.ietf-schc-architecture] |

Most difficult draft-under-study change: §4.1.2: "This field is an unsigned integer that identifies the SCHC Instance, and thus the Context, that applies to the SCHC Data. The Instances of two or more peer nodes that share that Context (and thus a common SoR) within a Session use the same SCHC Instance ID value." (14)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express almost all of the technical behaviors, protocol stacks, and deployment configurations of the draft under study (`draft-ietf-6lo-schc-15dot4-13`). The principal conceptual mapping translates the draft's "SCHC Data end point" to an -06 "SCHC Instance", and the draft's "SCHC Control Header end point" to a combination of -06's Dispatcher and Instance configurations. The network-wide single or multiple endpoint models map to profile-specific configurations of the Dispatcher and Instance counts.

### Claude Executive Assessment

SCHC Architecture -06 **can naturally express** draft-ietf-6lo-schc-15dot4-13. The draft was written against architecture **-05** and already builds on architecture vocabulary (SCHC Stratum, Discriminator, SCHC Control Header, SCHC Datagram, SoR); its wire formats, storage requirements, and the SRO/TRO/PRO/Mesh-Under modes carry over unchanged.

