# Consolidated SCHC Architecture Alignment: draft-ietf-schc-schclet-00

## Final Minimal -07 Decision
Not included in final minimal -07: SCHClet clarification changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: Yes

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | High | Easy | Trivial | Yes | Yes |

## Agreement and Differences
Claude and Gemini are marked **incompatible**: one source identifies an actual Architecture gap and the other does not.

## Final Consolidated Assessment
SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is the direct match between the draft's "SCHClet" and the architecture's "SCHClet" component, which operates within a single Instance. The principal migration difficulty lies in clarifying the relationship between SCHClets and Instances (specifically correcting a sentence that refers to an Instance itself being defined as a SCHClet) and aligning configuration terminology (mapping "SCHClet Configuration" to subsets of Context and Instance Configuration). No SCHC Architecture gap exists, as all simplifying assumptions (elided headers, lack of discriminators, and static provisioning) are native features of the -06 model. SCHC Architecture -06 can **naturally express** draft-ietf-schc-schclet-00. This is the strongest
possible starting position: -06 was authored with awareness of the SCHClet work, already carries a
normative **SCHClet** definition (Terminology §3 and a dedicated §4.2.2.3), already cites this draft
as `[DRAFT-SCHCLET]`, and already lists *SCHClets (modular subfunctions)* among the SCHC
functionalities selectable in an Instance Configuration (§4.2.1.1).

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: SCHClet clarification changes are deferred. (2) |

Most difficult SCHC Architecture change: Not included in final minimal -07: SCHClet clarification changes are deferred. (2)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4.1, paragraph 2 (lines 307-310): "While not recommended, a SCHC Instance operating on a specific Stratum MAY be implemented using a single SCHClet, or combined with other SCHClets to achieve the functionality of a complete SCHC Instance." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2 (Terminology - Full Configuration): "Full SCHC Implementation Configuration (Full Configuration): The union of the Context (including Set of Rules) and the Instance Configuration supported by a Full SCHC Implementation." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2 (Terminology - SCHClet Configuration): "SCHClet Configuration: A subset of the Context (including Rules) and/or Instance Configuration that is implemented and supported by a given SCHClet. This may be a single SCHC Profile, or a set of such." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §1, §3.1, §4, §4.1 (each "SCHC Stratum Header" occurrence): Rename to "Control Header" (per -06 §4.2.5.1) and state it is the Control Header's multiplexing role, elided when a single Stratum/Instance is used |
| REQUIRED FOR TERMINOLOGY MIGRATION | §1 ("A SCHClet operates on a single Stratum and on a single SCHC Instance"), §4, §4.1: Add one clause stating that a SCHClet is a modular subfunction hosted within a single Instance, and that a minimal deployment may consist of a single such SCHClet |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.1, §4 (interoperability paragraphs): Re-anchor on -06 Context consistency: interoperability holds because the SCHClet's Context/Set of Rules is compatible with the peer's, per -06 §6.2 and Appendix A.3 |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2 Terminology (SCHClet, Full SCHC Implementation, Full/SCHClet Configuration): Cross-reference -06: map SCHClet to -06 §4.2.2.3; express Full/SCHClet Configuration as (subset of) Instance Configuration + Context/Set of Rules |

Most difficult draft-under-study change: Section 4.1, paragraph 2 (lines 307-310): "While not recommended, a SCHC Instance operating on a specific Stratum MAY be implemented using a single SCHClet, or combined with other SCHClets to achieve the functionality of a complete SCHC Instance." (7)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is the direct match between the draft's "SCHClet" and the architecture's "SCHClet" component, which operates within a single Instance. The principal migration difficulty lies in clarifying the relationship between SCHClets and Instances (specifically correcting a sentence that refers to an Instance itself being defined as a SCHClet) and aligning configuration terminology (mapping "SCHClet Configuration" to subsets of Context and Instance Configuration). No SCHC Architecture gap exists, as all simplifying assumptions (elided headers, lack of discriminators, and static provisioning) are native features of the -06 model.

### Claude Executive Assessment

SCHC Architecture -06 can **naturally express** draft-ietf-schc-schclet-00. This is the strongest
possible starting position: -06 was authored with awareness of the SCHClet work, already carries a
normative **SCHClet** definition (Terminology §3 and a dedicated §4.2.2.3), already cites this draft
as `[DRAFT-SCHCLET]`, and already lists *SCHClets (modular subfunctions)* among the SCHC
functionalities selectable in an Instance Configuration (§4.2.1.1).

