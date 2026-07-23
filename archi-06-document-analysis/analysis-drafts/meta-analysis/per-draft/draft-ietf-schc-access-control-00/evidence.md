# Evidence Notes: draft-ietf-schc-access-control-00

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

The reference architecture SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping maps the Remote Entity (Management Client) to the Domain Manager and the local Rule Manager (RM) to the Instance Manager. The access control leaves function as Context/Rule metadata. The principal migration difficulty lies in correcting the structural nesting of `ac-modify-set-of-rules` in the YANG module, which is currently placed inside individual rules rather than at the root of the ruleset. No SCHC Architecture gap exists, and no modification to the reference architecture is required.

### Architectural risk points

- **Risk:** Rule-Nested Ruleset Permissions
  - **Why it matters:** In the draft's YANG model, the leaf `ac-modify-set-of-rules` is nested inside `/schc:schc/schc:rule` (which is a list of rules). This creates a logical paradox: if the ruleset is empty, the management client cannot read this leaf to determine if it is permitted to add a rule. Furthermore, if multiple rules exist with conflicting values for this leaf, there is no defined behavior for which permission takes precedence.
  - **Consequence for migration:** To align with -06, the permission to modify the Set of Rules must be moved out of the rule list and placed at the top-level container of the SCHC instance (e.g., `/schc:schc` or inside the Context/Instance Configuration), requiring a structural modification of the YANG schema.
- **Risk:** Multi-Instance Endpoint Management Ambiguity
  - **Why it matters:** The draft assumes a single implicit endpoint/instance structure (referring to the "end-point Rule Manager"). However, -06 explicitly allows multiple SCHC Instances to coexist on a single Endpoint, each with its own Context and configuration. The draft does not specify how a management request identifies which Instance or Context is the target of the rule modification.
  - **Consequence for migration:** The management protocol and Rule Manager must be updated to include an Instance or Context identifier in the request path, so the Instance Manager can apply the access control rules to the correct Instance context.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 6.1, and Appendix A (lines 644-649) | `leaf ac-modify-set-of-rules` is nested inside `/schc:schc/schc:rule`. | Move the `ac-modify-set-of-rules` leaf to the root container `/schc:schc` (or a separate instance/context configuration container) instead of the individual `rule` list element. | REQUIRED FOR CONCEPTUAL ALIGNMENT | If the ruleset is empty, or if different rules contain conflicting values, the Rule Manager cannot determine the permission to add or delete rules. Ruleset-wide permissions must reside at the ruleset/instance level. |
| 2 | Throughout (e.g. Sections 1, 3, 5) | Uses "end-point Rule Manager", "endpoints", "remote entity". | Replace "end-point Rule Manager" / "Rule Manager" with "Instance Manager" (or "local Rule Manager acting as part of the Instance Manager"), "endpoints" with "Instances", and "remote entity" with "Domain Manager" or "Remote Management Client". | REQUIRED FOR TERMINOLOGY MIGRATION | Align terminology with the core components defined in SCHC Architecture -06. |
| 3 | Section 3 (Terminology) | Placeholder "ToDo" list for terminology definitions. | Replace placeholders with standard definitions for "Instance Manager", "Domain Manager", "Context", and "Set of Rules", referencing their definitions in `draft-ietf-schc-architecture-06`. | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves temporary placeholders and integrates terminology with the reference architecture. |
| 4 | Section 5 (YANG Access Control) | "The SCHC access control augments the YANG module defined in [RFC9363] to allow a remote entity to manipulate the rules." | Clarify that in multi-instance deployments, the management request must carry a SCHC Instance Identifier or Context Identifier so the Instance Manager can route the request to the correct Instance. | OPTIONAL CLARIFICATION | Clarifies how the model scales to multi-instance endpoints. |
| 5 | Appendix A (YANG model, lines 582-586 and 592) | Description references "compound-ack behavior" and "Compound Ack". | Update description and references to match SCHC Access Control. | EDITORIAL | Fixes copy-paste errors from the Compound ACK draft. |
| 6 | Section 6.3.1 | "...the based header is only readable..." | Correct "based header" to "base header". | EDITORIAL | Typo fix. |
| 7 | Abstract & Section 1 | "...defines defines augmentation..." and "...define a augmentation..." | Correct to "...defines an augmentation..." and "...define an augmentation...". | EDITORIAL | Grammatical fixes. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Mostly (fixing the YANG structure of `ac-modify-set-of-rules` changes structural behavior, but preserves the original security and administrative intent).
- Can the migration be performed mechanically? No (requires architectural judgment to relocate the ruleset-level permission and define multi-instance target scoping).
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A (no gap exists)
- What is the single most important migration issue? Resolving the structural scoping of the `ac-modify-set-of-rules` leaf in the YANG model, moving it from the individual rule list to the root container level to make ruleset-wide modifications logically and technically checkable.

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can **naturally express** draft-ietf-schc-access-control-00. The access-control draft is not, in substance, an architectural document: it is a YANG Data Model augmentation of RFC 9363 that attaches per-Rule, per-field, and per-fragmentation-timer access-right leaves to the existing SCHC rule structure, plus profile-specific access tables for the CoAP header/options and a validity table for TV/MO/CDA combinations.

The **principal conceptual mapping** is that the objects the draft governs (Set of Rules, compression Rule, fragmentation Rule, Field Description/entry, and the TV/MO/CDA field descriptors) map one-to-one onto -06's Set of Rules (SoR), C/D Rule, F/R Rule, and C/D field descriptors, while the *access rights themselves* are Context **metadata** carried in the Data Model — which -06 explicitly admits ("Context: A SoR together with metadata. Metadata may, for example, refer to a data model"). The draft's write-path entity, the "Rule Manager", maps as a **Composite** onto -06's Domain Manager / Context Repository / Instance Manager management functions.

The **principal migration difficulty** is not volume but under-specification: the draft's Terminology section is a literal "ToDo" stub, and the terms "Rule Manager", "Management request processing", "Context", and RFC 8724-style "endpoint" must be pinned to specific -06 concepts. These are few, localized, and have clear repeatable answers, hence *Easy* rather than *Very Easy*.

There is **no Architecture gap**. -06 already provides the Context/metadata hook for access-right leaves, the management entities for the modification path, and an explicit forward reference to this very draft as the access-control model. Nothing in the draft forces a change to -06's conceptual model. Because adaptation need is None (ConEq High, transition Easy), both a `schc-architecture-edits.md` (None form) and a complete `terminology-migration.diff` are produced.

### Architectural risk points

**Risk 1 — Overloaded "Endpoint" / "Context".**
- **Risk:** The draft uses "endpoint" in the RFC 8724 sense and "Context" as a synonym for "the rules", both of which collide with -06's precisely defined Endpoint, Instance, and Context.
- **Why it matters:** A naive word-for-word migration would misplace ownership of the SoR and blur the Endpoint/Instance boundary, corrupting the very relationships -06 exists to clarify.
- **Consequence for migration:** Requires deliberate resolution (endpoint→Instance/Endpoint; Context→SoR + Context-metadata) at each occurrence. Localized but not blind — this is what keeps the transition at *Easy* rather than *Very Easy*.

**Risk 2 — Under-defined write-path entity ("Rule Manager").**
- **Risk:** The draft names a "Rule Manager" only in a ToDo bullet, without defining its scope or its relationship to the SoR it mutates.
- **Why it matters:** Ownership of Context content is a Domain-scope concern in -06; an unqualified per-endpoint RM could imply that an Endpoint independently owns/mutates its SoR, contradicting -06's Domain-managed Context model.
- **Consequence for migration:** The RM must be expressed as the *composition* of -06's Domain Manager / Context Repository (ownership) and Instance Manager (per-Endpoint apply/sync), not as a new standalone role. This is a framing decision, not a technical change.

**Risk 3 — `ac-modify-timers` vs. Set of Variables.**
- **Risk:** The draft governs modification of fragmentation "timers". -06 distinguishes F/R Rule *parameters* (configuration, in the Context) from the *Set of Variables* (runtime per-Session state such as timers/counters).
- **Why it matters:** If read as governing runtime SoV, `ac-modify-timers` would be scoped wrongly; it governs the *configured* F/R parameters in the Rule.
- **Consequence for migration:** A one-line clarification that access control applies to F/R Rule configuration (Context), not to the runtime SoV, removes the ambiguity. Not an architecture change.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §3 Terminology (the "ToDo" stub: Access Control / Management request processing / Rule Manager / Context) | Undefined bullet list; "passed to the end-point Rule Manager"; "Context. SCHC Rules" | Write the definitions using -06 terms: define Access Control as Data-Model-carried Context *metadata*; define the write path as -06 Configuration Distribution / Context Provisioning & Synchronization; define Rule Manager as the composition of -06 Instance Manager + Domain Manager + Context Repository; align "Context" with -06 Context (SoR + metadata) and clarify that access rights apply to the Rules of the SoR | REQUIRED FOR TERMINOLOGY MIGRATION | Removes overloaded/under-defined terms and pins them to -06 concepts without altering behavior |
| 2 | Abstract; §1 Introduction | "rules are static and shared by two endpoints" | "the Rules of a Context (its Set of Rules) are static and shared by two or more SCHC Instances" | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the RFC 8724 "two endpoints" framing with -06's Endpoint/Instance model and its "two or more" generalization (special case preserved) |
| 3 | §5 YANG Access Control | "to allow a remote entity to manipulate the rules" | "to constrain how a management entity — the Domain Manager or Instance Manager of [I-D.ietf-schc-architecture] — may modify the Rules of a Context" | REQUIRED FOR TERMINOLOGY MIGRATION | Maps the "remote entity" and RM onto -06's management entities and Domain-scoped Context ownership |
| 4 | §5 bullets; §6.1–§6.3 | "set of rules", "compression rule", "fragmentation rule", "Field Description"/"entry", "field-id" | "Set of Rules (SoR)", "compression (C/D) Rule", "fragmentation (F/R) Rule", "field descriptor" | REQUIRED FOR TERMINOLOGY MIGRATION | Consistent use of -06 vocabulary; one-to-one, meaning-preserving |
| 5 | §6.3 / Appendix A (`ac-modify-timers`) | "modify some parameters" of a fragmentation rule / timers | Add: access control here applies to the F/R Rule *configuration* in the Context, not to the runtime Set of Variables (SoV) | REQUIRED FOR TERMINOLOGY MIGRATION | Prevents mis-scoping timers as -06 runtime SoV (Risk 3) |
| 6 | §7 References ([I-D.ietf-schc-architecture]) | Cites `draft-ietf-schc-architecture-01` | Update citation to `-06` | REQUIRED FOR TERMINOLOGY MIGRATION | The draft targets pre-architecture terminology; -06 is the reference model |
| 7 | §3 / §5 | (no explicit statement) | Add one sentence: access rights are Context metadata carried in the RFC 9363 Data Model, consistent with -06 §3 and enforced on the management write path referenced in -06 §7 | OPTIONAL CLARIFICATION | Makes the Composite mapping explicit for readers; not required for correctness |
| 8 | §5 | NACM (RFC 8341) discussion | Optionally note NACM operates at -06 management-plane granularity and is orthogonal to per-Rule access rights | OPTIONAL CLARIFICATION | Situates the rejected mechanism relative to -06; improves readability |
| 9 | Abstract | "defines defines augmentation" | "defines an augmentation" | EDITORIAL | Duplicated word / article error |
| 10 | §1 Introduction | "define a augmentation" | "define an augmentation" | EDITORIAL | Article error |
| 11 | §3 Terminology | "managmente request processing" | "management request processing" | EDITORIAL | Typo |
| 12 | §6.3.1 | "the based header" | "the base header" | EDITORIAL | Typo |
| 13 | Appendix A YANG (module description, revision, contact) | Description references "compound-ack behavior for Ack On Error", "RFC YYYY: Compound Ack"; contact/editor is J-C Zuniga | Replace copy-paste boilerplate with an access-control description and correct editor | EDITORIAL | Wrong boilerplate carried over from another module; unrelated to access control |
| 14 | Appendix A YANG (`rule-access-right`) | enum `no-changes`; prose says `no-change (0)`; `field-access-right` enums carry placeholder description "Reserved slot number." | Make enum name/descriptions consistent with the prose | EDITORIAL | Internal consistency of the model text |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §7 Security Considerations | Access-control model reference | "[I-D.ietf-schc-access-control] defines an access control model for SCHC Rules." | (No change required.) Optionally, one clause could note that such access control is carried as Context metadata in the Data Model and enforced by the Domain/Instance management entities. | OPTIONAL CLARIFICATION (**not a gap**) | -06 already provides the Context-metadata hook (§3), the management entities (§4.2.2.4, Fig. 2), and the forward reference. Any addition is a readability nicety, not a requirement to express the draft |

There are **zero ARCHITECTURE GAP** items. Every concept the draft requires is already present in -06.

### Final migration assessment

- **Can the draft be migrated without changing technical behavior?** Yes.
- **Can the migration be performed mechanically?** Mostly — the bulk is meaning-preserving terminology substitution; a small number of localized decisions (resolve overloaded "endpoint"/"Context"; express "Rule Manager" as a composite of -06 management entities) require light architectural judgment.
- **Does the draft expose a SCHC Architecture -06 gap?** No.
- **Is the gap required for this draft or merely useful generally?** Not applicable — there is no gap. The single -06 item above is an OPTIONAL CLARIFICATION that is only marginally useful, not required.
- **What is the single most important migration issue?** Pinning the draft's under-defined, overloaded terms — "Rule Manager", "Management request processing", and "Context (= SCHC Rules)" — onto -06's Context/SoR split and its Domain Manager / Context Repository / Instance Manager management functions, so that ownership of the mutated Set of Rules stays at Domain scope.

No modification to SCHC Architecture -06 is required.
