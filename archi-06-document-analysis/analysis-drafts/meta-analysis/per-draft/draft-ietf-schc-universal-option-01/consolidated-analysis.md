# Consolidated SCHC Architecture Alignment: draft-ietf-schc-universal-option-01

## Final Minimal -07 Decision
Not included in final minimal -07: deterministic field descriptor ordering changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: No

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | Trivial | Yes | Yes |
| Claude | Very High | Easy | Trivial | Yes | Yes |

## Agreement and Differences
Claude and Gemini agree on headline verdicts and gap status.

## Final Consolidated Assessment
The Static Context Header Compression (SCHC) Architecture -06 can naturally express the concepts, relationships, and assumptions of `draft-ietf-schc-universal-option-01`. The principal conceptual mapping involves treating the hierarchical option representation (composed of a `space-id` and an `option-id`) as a composite Field Identifier within a Rule's field descriptor in the Context/Data Model. The main migration difficulty lies in updating references from the old architecture draft (`[I-D.ietf-lpwan-architecture]`) to `draft-ietf-schc-architecture-06` and performing minor mechanical updates to terminology (e.g., replacing "end-point" with "Endpoint"/"Instance" and "Rule management" with "Context management"). A trivial architecture gap exists because the current -06 text lacks explicit g... SCHC Architecture -06 can naturally express draft-ietf-schc-universal-option-01. The draft is, architecturally, a Data-Model document: it extends the RFC 9363 YANG model with an `entry-option-space` list keyed by a protocol namespace (`space-id`) and the protocol's native option identifier (`option-id`), so that Rules can describe options unknown to the deployed implementation. Everything below the Rule boundary (FID, space-id, option-id, entries, TV/MO/CDA, SIDs, CBOR, CORECONF) sits at a granularity that -06 deliberately delegates to the Data Model named in the Context's metadata — a natural, defined use of the -06 Context concept, not an escape hatch.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: deterministic field descriptor ordering changes are deferred. (3) |

Most difficult SCHC Architecture change: Not included in final minimal -07: deterministic field descriptor ordering changes are deferred. (3)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 5.2: Change reference from [I-D.ietf-lpwan-architecture] to draft-ietf-schc-architecture-06 and clarify the exact section (e.g., Section 4.2.1.2 on Context or Section 4.2.2.1 on C/D). |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 5.4.3: Change reference from [I-D.ietf-lpwan-architecture] to draft-ietf-schc-architecture-06 (or its Section 4.2.1.2). |
| REQUIRED FOR TERMINOLOGY MIGRATION | Figure 1: Change "SCHC end-points" to "SCHC Instances" (or "SCHC Endpoints" hosting Instances) and update text to align with -06 terminology. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1, 2.1, 2.2, etc.: Update to "SCHC Endpoints" or "SCHC Instances" to match -06 terminology. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 5.2: Retain as is but make sure it is clearly stated. |
| REQUIRED FOR TERMINOLOGY MIGRATION | §1, goals bullet: "Simplify Rule and Context management between SCHC Endpoints" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2.2, first paragraph and Figure 1 caption: "Rule management between two SCHC Endpoints whose Instances share a Context" / caption "Rule Management between two SCHC Endpoints" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2.2, scenario bullet: "SCHC Endpoints S1 and S2 each host a SCHC Instance; the two Instances compress and decompress the traffic within a Session, using a shared Context (Set of Rules)." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2.2, problem bullet: "…so that, when the updated Context is distributed to S2 (e.g., by the Domain Manager or a dynamic Context update mechanism), S2 can understand which option is involved…" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2.3, second bullet: "making the exchange of Rules (Context synchronization) between them problematic" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.3, advantages paragraph: "enabling different SCHC implementations to exchange Rules (synchronize Contexts) for any option" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.2: "all Instances participating in a Session must process entries in the same order" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.2: "This constraint is stated in the Context consistency considerations of [I-D.ietf-schc-architecture]: the order of entries is part of the Context and is preserved by Context distribution and synchronization." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.3, third bullet: "It allows for cleaner Rule exchange between SCHC Endpoints (Context synchronization within a Domain)" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.4.3: "When a Context is distributed or synchronized between Instances, the order of Field Descriptors must be preserved" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.4.3: Reference redirected to [I-D.ietf-schc-architecture]; "…when a Context is transmitted between Endpoints" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5.4.3, second bullet: "must be processed in a consistent sequence across all Instances" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §6.2, Informative References: Replace with [I-D.ietf-schc-architecture] (draft-ietf-schc-architecture-06) |

Most difficult draft-under-study change: Section 5.2: Retain as is but make sure it is clearly stated. (18)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The Static Context Header Compression (SCHC) Architecture -06 can naturally express the concepts, relationships, and assumptions of `draft-ietf-schc-universal-option-01`. The principal conceptual mapping involves treating the hierarchical option representation (composed of a `space-id` and an `option-id`) as a composite Field Identifier within a Rule's field descriptor in the Context/Data Model. The main migration difficulty lies in updating references from the old architecture draft (`[I-D.ietf-lpwan-architecture]`) to `draft-ietf-schc-architecture-06` and performing minor mechanical updates to terminology (e.g., replacing "end-point" with "Endpoint"/"Instance" and "Rule management" with "Context management"). A trivial architecture gap exists because the current -06 text lacks explicit g...

### Claude Executive Assessment

SCHC Architecture -06 can naturally express draft-ietf-schc-universal-option-01. The draft is, architecturally, a Data-Model document: it extends the RFC 9363 YANG model with an `entry-option-space` list keyed by a protocol namespace (`space-id`) and the protocol's native option identifier (`option-id`), so that Rules can describe options unknown to the deployed implementation. Everything below the Rule boundary (FID, space-id, option-id, entries, TV/MO/CDA, SIDs, CBOR, CORECONF) sits at a granularity that -06 deliberately delegates to the Data Model named in the Context's metadata — a natural, defined use of the -06 Context concept, not an escape hatch.

