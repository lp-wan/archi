# Consolidated SCHC Architecture Alignment: draft-ietf-schc-8824-update-09

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
SCHC Architecture -06 can naturally express the draft under study without any modification. The principal conceptual mapping involves representing the Device, NGW, App, and Proxy as physical hosts running logical Endpoints, with Instances executing SCHC C/D within Sessions. The OSCORE Inner/Outer layered compression is mapped to separate SCHC Instances operating at different Strata (Inner CoAP vs. Outer CoAP) on the same Endpoint. The principal migration difficulty is updating the text in Sections 1, 2, and 9 to align with these -06 concepts. No architectural gaps exist. SCHC Architecture -06 can naturally and completely express draft-ietf-schc-8824-update-09.
The draft is a compression specification: it defines how to construct SCHC C/D Rules
(Field Descriptors, MOs, CDAs, FL functions) for CoAP header fields and options, obsoleting
RFC 8824. Its content is almost entirely at the [RFC8724] mechanism level, which -06 adopts
unchanged; the draft touches architecture only at a handful of points.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1 (page 4, line 203): compressing CoAP headers requires installing a common Context containing Rules shared between the communicating SCHC Instances within a Session |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2 (pages 7-9, lines 364-374, 399-421, 453-491): Update text to describe the physical nodes (Device, NGW, App) hosting SCHC Endpoints and Instances communicating within Sessions using Contexts, and clarify the stratification of Inner/Outer Instances. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 9 (pages 46-47, lines 2555-2666): Frame the CoAP proxy as hosting a SCHC Endpoint with separate ingress and egress Instances participating in separate Sessions with adjacent hops. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1, ¶2: "based on a static Context … both SCHC Instances share the static Context before transmission. The way the Context is configured…" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1, ¶3: "installing a common Context, containing the common Set of Rules (SoR), between the two SCHC Instances"; note that independent levels are performed by distinct Instances, each with its own Context |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1, ¶4: "…based on a common Context shared between SCHC Instances. The SCHC Context includes multiple Rules in its Set of Rules (SoR)." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1.1 (Terminology): Add familiarity with the SCHC architecture terms (Endpoint, Instance, Context, SoR, Session, Domain) and an explicit disambiguation: "application/origin/sender/recipient/OSCORE endpoint" are CoAP/OSCORE terms, never SCHC Endpoints; a CoAP option "instance" is unrelated to a SCHC Instance |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2, ¶ after Figure 2: Capitalize: "end-to-end Context initialization … The Context initialization is out of scope" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2, last ¶: "In the case of several SCHC Instances …, each Instance operates with its own Context, and the Contexts may be provided and managed by different SCHC Domains." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 9, intro: Add one framing sentence: each leg on which SCHC is used corresponds to a SCHC Session between two Instances sharing a common Context; an entity performing SCHC on several legs hosts an Instance per leg |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 9.1, ¶1: Append: "i.e., on a Context shared within the SCHC Session established between the SCHC Instances of the two adjacent hops" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 9.2, ¶¶2–3: State that the Inner SCHC Rules form a Context shared end-to-end within a Session between the two application endpoints' Instances, and each Outer rule set is a per-leg Context within a distinct Session |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 12, ¶ on Rule updates: "any time the Rules of the Context are updated on an OSCORE endpoint" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 14.2: Add informative reference to draft-ietf-schc-architecture |

Most difficult draft-under-study change: Section 1.1 (Terminology): Add familiarity with the SCHC architecture terms (Endpoint, Instance, Context, SoR, Session, Domain) and an explicit disambiguation: "application/origin/sender/recipient/OSCORE endpoint" are CoAP/OSCORE terms, never SCHC Endpoints; a CoAP option "instance" is unrelated to a SCHC Instance (14)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can naturally express the draft under study without any modification. The principal conceptual mapping involves representing the Device, NGW, App, and Proxy as physical hosts running logical Endpoints, with Instances executing SCHC C/D within Sessions. The OSCORE Inner/Outer layered compression is mapped to separate SCHC Instances operating at different Strata (Inner CoAP vs. Outer CoAP) on the same Endpoint. The principal migration difficulty is updating the text in Sections 1, 2, and 9 to align with these -06 concepts. No architectural gaps exist.

### Claude Executive Assessment

SCHC Architecture -06 can naturally and completely express draft-ietf-schc-8824-update-09.
The draft is a compression specification: it defines how to construct SCHC C/D Rules
(Field Descriptors, MOs, CDAs, FL functions) for CoAP header fields and options, obsoleting
RFC 8824. Its content is almost entirely at the [RFC8724] mechanism level, which -06 adopts
unchanged; the draft touches architecture only at a handful of points.

