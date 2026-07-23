# Consolidated SCHC Architecture Alignment: draft-ietf-schc-access-control-00

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: No - calibration difference

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | High | Easy | None | Yes | Yes |

## Agreement and Differences
Claude and Gemini have a calibration difference: conceptual: Very High vs High.

## Final Consolidated Assessment
The reference architecture SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping maps the Remote Entity (Management Client) to the Domain Manager and the local Rule Manager (RM) to the Instance Manager. The access control leaves function as Context/Rule metadata. The principal migration difficulty lies in correcting the structural nesting of `ac-modify-set-of-rules` in the YANG module, which is currently placed inside individual rules rather than at the root of the ruleset. No SCHC Architecture gap exists, and no modification to the reference architecture is required. SCHC Architecture -06 can **naturally express** draft-ietf-schc-access-control-00. The access-control draft is not, in substance, an architectural document: it is a YANG Data Model augmentation of RFC 9363 that attaches per-Rule, per-field, and per-fragmentation-timer access-right leaves to the existing SCHC rule structure, plus profile-specific access tables for the CoAP header/options and a validity table for TV/MO/CDA combinations.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 6.1, and Appendix A (lines 644-649): Move the ac-modify-set-of-rules leaf to the root container /schc:schc (or a separate instance/context configuration container) instead of the individual rule list element. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Throughout (e.g. Sections 1, 3, 5): Replace "end-point Rule Manager" / "Rule Manager" with "Instance Manager" (or "local Rule Manager acting as part of the Instance Manager"), "endpoints" with "Instances", and "remote entity" with "Domain Manager" or "Remote Management Client". |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3 (Terminology): Replace placeholders with standard definitions for "Instance Manager", "Domain Manager", "Context", and "Set of Rules", referencing their definitions in draft-ietf-schc-architecture-06. |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3 Terminology (the "ToDo" stub: Access Control / Management request processing / Rule Manager / Context): Write the definitions using -06 terms: define Access Control as Data-Model-carried Context *metadata*; define the write path as -06 Configuration Distribution / Context Provisioning & Synchronization; define Rule Manager as the composition of -06 Instance Manager + Domain Manager + Context Repository; align "Context" with -06 Context (SoR + metadata) and clarify that access rights apply to the Rules of the SoR |
| REQUIRED FOR TERMINOLOGY MIGRATION | Abstract; §1 Introduction: "the Rules of a Context (its Set of Rules) are static and shared by two or more SCHC Instances" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5 YANG Access Control: "to constrain how a management entity — the Domain Manager or Instance Manager of [I-D.ietf-schc-architecture] — may modify the Rules of a Context" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §5 bullets; §6.1–§6.3: "Set of Rules (SoR)", "compression (C/D) Rule", "fragmentation (F/R) Rule", "field descriptor" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §6.3 / Appendix A (ac-modify-timers): Add: access control here applies to the F/R Rule *configuration* in the Context, not to the runtime Set of Variables (SoV) |
| REQUIRED FOR TERMINOLOGY MIGRATION | §7 References ([I-D.ietf-schc-architecture]): Update citation to -06 |

Most difficult draft-under-study change: Section 6.1, and Appendix A (lines 644-649): Move the ac-modify-set-of-rules leaf to the root container /schc:schc (or a separate instance/context configuration container) instead of the individual rule list element. (9)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The reference architecture SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping maps the Remote Entity (Management Client) to the Domain Manager and the local Rule Manager (RM) to the Instance Manager. The access control leaves function as Context/Rule metadata. The principal migration difficulty lies in correcting the structural nesting of `ac-modify-set-of-rules` in the YANG module, which is currently placed inside individual rules rather than at the root of the ruleset. No SCHC Architecture gap exists, and no modification to the reference architecture is required.

### Claude Executive Assessment

SCHC Architecture -06 can **naturally express** draft-ietf-schc-access-control-00. The access-control draft is not, in substance, an architectural document: it is a YANG Data Model augmentation of RFC 9363 that attaches per-Rule, per-field, and per-fragmentation-timer access-right leaves to the existing SCHC rule structure, plus profile-specific access tables for the CoAP header/options and a validity table for TV/MO/CDA combinations.

