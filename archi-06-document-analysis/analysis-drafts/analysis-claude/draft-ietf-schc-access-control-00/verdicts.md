# Architectural alignment review: draft-ietf-schc-access-control-00

## Verdicts
- Conceptual equivalence: **High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | Not **Very High**: the draft's "Rule Manager", "Management request processing", and "Context" are undefined ToDo stubs (Section 3) that must be *decomposed* onto -06's Instance Manager / Domain Manager / Context Repository and its Context/SoR split. The draft equates "Context" with "SCHC Rules", whereas -06 defines Context as SoR + metadata; resolving this requires a genuine interpretive decision (map the draft's "Context" to -06 SoR, and the access rights to -06 Context *metadata*), not pure relabeling. | Not **Medium**: no concept needs reframing, extra constraints, or profile-specific semantics to fit. The core objects the draft actually manipulates — Rule, Set of Rules, compression/fragmentation Rules, field descriptors (FID/TV/MO/CDA), fragmentation timers — map **Directly** to -06, and the access-control layer is a natural Data Model / Context-metadata extension that -06 already anticipates and cites. |
| Transition difficulty | Easy | Not **Very Easy**: the Terminology section is an unwritten "ToDo" stub and the phrases "remote entity to manipulate the rules" (Section 5) and "shared by two endpoints" (Abstract/Intro) require *local* architectural judgment (which -06 management entity; Endpoint vs Instance; two vs two-or-more) rather than a blind find-and-replace. | Not **Medium**: the document is short, edits are localized and repeatable, and the two largest technical artifacts — the TV/MO/CDA combination table (Figure 1) and the CoAP access-control tables (Figures 2-3) — need **no** architectural change because MO/CDA/TV and the CoAP FIDs are already RFC 8724 / RFC 8824 vocabulary shared by -06. |
| SCHC Architecture adaptation need | None | Highest grade | Not **Trivial**: every notion the draft requires is already present and sufficiently defined in -06 — Rule and RuleID; Set of Rules; Context as "a SoR together with metadata [that] may refer to a data model"; the management/write path via Domain Manager, Context Repository, and Instance Manager; and -06 Section 7 already cites `[I-D.ietf-schc-access-control]` as "an access control model for SCHC Rules". No additive definition, note, or explicit statement of an implied relationship is needed in -06 to make the mapping natural. |

## Executive assessment

SCHC Architecture -06 can **naturally express** draft-ietf-schc-access-control-00. The access-control draft is not, in substance, an architectural document: it is a YANG Data Model augmentation of RFC 9363 that attaches per-Rule, per-field, and per-fragmentation-timer access-right leaves to the existing SCHC rule structure, plus profile-specific access tables for the CoAP header/options and a validity table for TV/MO/CDA combinations.

The **principal conceptual mapping** is that the objects the draft governs (Set of Rules, compression Rule, fragmentation Rule, Field Description/entry, and the TV/MO/CDA field descriptors) map one-to-one onto -06's Set of Rules (SoR), C/D Rule, F/R Rule, and C/D field descriptors, while the *access rights themselves* are Context **metadata** carried in the Data Model — which -06 explicitly admits ("Context: A SoR together with metadata. Metadata may, for example, refer to a data model"). The draft's write-path entity, the "Rule Manager", maps as a **Composite** onto -06's Domain Manager / Context Repository / Instance Manager management functions.

The **principal migration difficulty** is not volume but under-specification: the draft's Terminology section is a literal "ToDo" stub, and the terms "Rule Manager", "Management request processing", "Context", and RFC 8724-style "endpoint" must be pinned to specific -06 concepts. These are few, localized, and have clear repeatable answers, hence *Easy* rather than *Very Easy*.

There is **no Architecture gap**. -06 already provides the Context/metadata hook for access-right leaves, the management entities for the modification path, and an explicit forward reference to this very draft as the access-control model. Nothing in the draft forces a change to -06's conceptual model. Because adaptation need is None (ConEq High, transition Easy), both a `schc-architecture-edits.md` (None form) and a complete `terminology-migration.diff` are produced.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC Rule | A compression or fragmentation rule, per RFC 8724 / RFC 9363, that this draft makes selectively modifiable | Held by the two endpoints; represented in the RFC 9363 YANG model | Shared between the two sharing endpoints (peer-pair) | RuleID (RFC 8724) | A Set of Rules contains N Rules (1:N) | Draft treats Rules as "static and shared by two endpoints" (RFC 8724 assumption) |
| Set of Rules | The collection of Rules subject to access control at the top level | RFC 9363 model root (`/schc:schc/schc:rule` list) | Peer-pair / device | — | 1 Set of Rules : N Rules | Governed by `ac-modify-set-of-rules` |
| Compression rule / Field Description (entry) | A C/D Rule and its per-field descriptors (FID, FL, FP/POS, DI, TV, MO, CDA) | Inside a Rule of `nature compression` | Rule-local | FID (+ FL/FP/DI) | 1 Rule : N Field Descriptions | Governed by `ac-modify-compression-rule` / `ac-modify-field` |
| Fragmentation rule | An F/R Rule whose parameters/timers may be modified | Inside a Rule of `nature fragmentation` | Rule-local | RuleID | 1 | Governed by `ac-modify-timers` (boolean) |
| TV / MO / CDA and their valid combinations | Field-descriptor elements; Figure 1 marks combinations as ok / x / absurd to detect or avoid attacks | Within a Field Description | Rule-local | — | Constrained combination matrix | RFC 8724 semantics; a rule-content validity constraint, not an architectural entity |
| Access Control | Restrictions on which Rules / fields / elements may be added, removed, or modified | Expressed as read-only leaves in the augmented Data Model | Applies to the shared rule store | The `*-access-right` leaf values | Attached per Rule / per compression-rule / per field / per fragmentation timer | Core contribution of the draft |
| rule-access-right enum | `no-change(s)` / `modify-existing-element` / `add-remove-element` | Data Model typedef | Per Rule and per compression Rule | enum value 0/1/2 | Applied by `ac-modify-set-of-rules`, `ac-modify-compression-rule` | Layered activation: field level requires the outer levels enabled |
| field-access-right enum | `no-change` / `change-tv` / `change-mo-cda-tv` | Data Model typedef | Per Field Description | enum value 0/1/2 | Applied by `ac-modify-field` | |
| Rule Manager (RM) | The end-point entity that receives a management request and applies the rule change | "end-point" (a peer node) | Endpoint-local write path | — | 1 RM per endpoint (implied) | Named only in the Terminology ToDo; not otherwise defined |
| Management request processing | NETCONF / RESTCONF / CORECONF request is processed and passed to the RM | Management plane between a remote manager and the endpoint | Administrative / management scope | — | remote manager → endpoint RM | Transport left to NETCONF/RESTCONF/CORECONF |
| Remote entity | The external actor allowed to manipulate the rules | Outside the endpoint | Administrative domain | — | N managers : N endpoints (unstated) | "a remote entity to manipulate the rules" (Section 5) |
| Endpoint (RFC 8724 sense) | One of the two peers that hold and share the Rules | Physical/logical peer node | Peer-pair | — | 2 endpoints share one rule set | Draft uses the pre-architecture "two endpoints" framing |
| Context | Listed in Terminology as "SCHC Rules" | The rule store | Peer-pair | — | — | Equated with the rules themselves, not SoR + metadata |
| YANG Data Model (augmentation) | RFC 9363 module extended with access-control leaves | ietf-schc-access-control module | Model/tooling scope | YANG paths | augments `/schc:schc/schc:rule` and sub-nodes | The concrete mechanism carrying access control |
| NACM (RFC 8341) | Standard YANG user/group access control, considered and rejected as too coarse | Management plane | User/group scope | — | — | Explicitly deemed a poor fit; motivates the bespoke leaves |
| CoAP base-header / options access control | Per-field Read-Only / Read-Write tables for the CoAP header and options | Applies to CoAP-profile C/D Rules (RFC 8824) | Profile-specific, per field | FID (CoAP.*) | Per-FID access setting | Repeatable options MAY be modifiable; base header MUST NOT be modified |

## Native architectural model

The access-control draft operates almost entirely one layer below the SCHC Architecture. Its object of study is the *rule store* described by RFC 8724 and formalized as a YANG Data Model by RFC 9363. In its own words, "rules are static and shared by two endpoints", and the problem it addresses is that "inappropriate changes to SCHC Rules" enable attacks. Its contribution is therefore a controlled-mutation model over the existing rule structure, not a new set of runtime components.

The native model is hierarchical and mirrors the RFC 9363 tree. At the top is the Set of Rules. Within it are Rules, each of a given "nature" (compression or fragmentation). A compression Rule contains a list of Field Descriptions (called "entry" in the model), each carrying the RFC 8724 descriptor tuple: FID, field length (FL), field position (FP/POS), direction indicator (DI), Target Value (TV), Matching Operator (MO), and Compression/Decompression Action (CDA). The draft adds nothing to this structure; it *annotates* it.

The annotations are three enumerated access-right leaves plus one boolean. `ac-modify-set-of-rules` decides, for a Set of Rules, whether nothing may change, whether existing Rules may be modified, or whether Rules may also be added/removed. `ac-modify-compression-rule` does the same at the granularity of Field Descriptions within a compression Rule. `ac-modify-field` decides, for a single Field Description, whether nothing may change, only the TV may change, or the MO/CDA/TV may change. `ac-modify-timers` is a boolean that permits or forbids modification of fragmentation-rule timers. The leaves are `config false` (read-only): they express policy that a manager must observe, and their absence means "not modifiable".

A second, orthogonal contribution is the TV/MO/CDA validity matrix (Figure 1). This is a rule-*content* integrity constraint: some descriptor combinations are meaningful ("ok"), some are forbidden by construction ("x"), and some are nonsensical ("absurd"). Its purpose is defensive — an out-of-range combination can signal or prevent an attack. It is not tied to any runtime component; it constrains what a valid Rule may contain.

The management plane is sketched but not developed. The Terminology section (itself flagged "ToDo") states that "the NETCONF, RESTCONF or CORECONF request is processed and passed to the end-point Rule Manager". Thus the draft posits a **remote manager** issuing standard YANG management operations, and an **end-point Rule Manager (RM)** that receives those operations and applies them to the local rule store subject to the access-right leaves. Neither entity is formally defined; the RM appears only as a bullet in the ToDo list.

The draft explicitly considers and rejects NACM (RFC 8341) as the access-control mechanism: NACM's user/group granularity "does not fit this rule model" because the goal is to authorize modification of *a specific rule entry and specific leaves within it*, not classes of nodes across the tree. This is why the draft introduces per-Rule/per-field leaves rather than reusing NACM rules.

The final component is a pair of profile-specific tables for SCHC-for-CoAP (RFC 8824). Figure 2 assigns Read-Only/Read-Write to each CoAP base-header field (Version, Type, TKL, Code, MessageID, Token), stating that the base header "MUST NOT be modified". Figure 3 does the same for the full set of CoAP options, allowing modification chiefly of repeatable options so that repetition can be represented. These tables instantiate the generic access-control leaves for a specific compression profile; they are illustrative applications, not new mechanisms.

In terms of scope and cardinality, the draft is thin and largely inherited from RFC 8724: one Set of Rules shared by two endpoints; Rules identified by RuleID; Field Descriptions identified within a Rule by FID (plus FL/FP/DI). The draft does not discuss multiple simultaneous rule sets, multiple managers, or multi-domain deployment. Scope for the access rights is "wherever this rule store is used" — effectively the shared rule store of the peer-pair. Ownership of the policy sits with whoever provisions the Data Model.

The trust model is implicit but central to the motivation: the rule store is a security-sensitive asset, remote modification is the threat surface, and the access-right leaves plus the TV/MO/CDA matrix are the mitigation. The draft does not specify who authenticates the remote manager; it assumes a management protocol (NETCONF/RESTCONF/CORECONF) that provides that.

In summary, the native model is: *a static, shared SCHC rule store (RFC 8724 / RFC 9363), annotated with read-only access-right metadata and content-validity constraints, mutated over a standard YANG management interface by a remote manager acting through a per-endpoint Rule Manager.* Everything architectural about it is borrowed; the novelty is the metadata and the constraint matrix.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC Rule | Modifiable C/D or F/R rule | Rule (identified by RuleID) | Direct | Aligned (Rule within a Context) | Aligned (SoR : Rule = 1:N) | None | -06 §3, §4.2.5 |
| Set of Rules | Top-level collection under access control | Set of Rules (SoR) | Direct | Aligned (SoR belongs to an Instance's Context) | Aligned | Draft implies one shared set; -06 allows per-Instance SoR, a superset | -06 §3 "Set of Rules (SoR)" |
| Compression rule | C/D rule with field descriptors | C/D Rule (Rule with C/D field descriptors) | Direct | Aligned | Aligned | None | -06 §4.2.2.1 |
| Field Description / entry | Per-field descriptor (FID/FL/FP/DI/TV/MO/CDA) | C/D field descriptors of a Rule | Direct | Aligned (Rule-local) | Aligned (Rule : descriptor = 1:N) | Terminology "entry"/"Field Description" vs "field descriptor" | -06 §3 Rule def; RFC 8724 |
| Fragmentation rule | F/R rule with modifiable timers | F/R Rule (mode + parameters) | Direct | Aligned | Aligned | None | -06 §4.2.2.2 |
| TV / MO / CDA validity matrix | Allowed descriptor combinations | MO, CDA (per -06 §3, RFC 8724) content constraint | Profile-specific | Aligned (Rule content) | N/A | -06 does not enumerate valid combinations; nor does it need to (RFC 8724 semantics) | A rule-content constraint expressible within any -06 SoR; not an architectural entity |
| Access Control (access-right leaves) | Read-only policy metadata on rules/fields | Context **metadata** carried in the Data Model | Composite (Context + Data Model + management entities) | Aligned (metadata travels with the Context) | Aligned | -06 does not itself define access-right granularity, but explicitly delegates it to this draft (§7) | -06 §3 "Context ... together with metadata ... refer to a data model"; §7 cites this draft |
| rule/field-access-right enums | Enumerated permission levels | Values within the Data Model metadata | Profile-specific | Aligned | Aligned | None (pure Data Model content) | Data-model detail, not architecture |
| Rule Manager (RM) | End-point entity applying rule changes | Instance Manager + Domain Manager + Context Repository (management functions) | Composite | Aligned (per-Endpoint management + Domain-level Context management) | Aligned | -06 has no single entity literally named "Rule Manager"; the write path is split across management entities | -06 §3, §4.2.2.4, Figure 2 |
| Management request processing | NETCONF/RESTCONF/CORECONF applied to rules | Configuration Distribution / Context Provisioning & Synchronization (management plane) | Partial | Aligned (management scope) | Aligned | -06 abstracts the management transport; it does not mandate NETCONF/RESTCONF/CORECONF | Transport choice is a profile/management decision -06 permits |
| Remote entity | External actor modifying rules | Domain Manager (and its operator) | Direct | Aligned (Domain-scope authority) | Aligned | None | -06 §4.1.2, Figure 2 |
| Endpoint (RFC 8724 "two endpoints") | Peer holding/sharing the rules | Instance (holds Context) hosted on an Endpoint | Partial | Needs resolution: draft's "endpoint" ≈ -06 Instance for rule-holding, Endpoint for hosting | -06 generalizes 2 → "two or more" Instances | Overloaded term: RFC 8724 "endpoint" ≠ -06 "Endpoint" | -06 §3 Endpoint/Instance split |
| Context (= "SCHC Rules") | The rule store | Set of Rules (SoR) within a Context | Misleading | Draft's "Context" is narrower than -06 Context | — | -06 Context = SoR **+ metadata**; draft equates Context with the rules only | Must map draft "Context" to -06 SoR, and the AC metadata to -06 Context metadata |
| YANG Data Model (augmentation) | RFC 9363 module + AC leaves | Data Model (Context metadata) | Direct | Aligned | Aligned | None | -06 §3 Context; §4.2.1.2 |
| NACM (rejected) | Coarse user/group AC deemed unfit | (No -06 counterpart; management-plane concern) | Not applicable | N/A | N/A | -06 does not model NACM; irrelevant to -06 expressibility | Editorial/motivational only |
| CoAP header/options access tables | Per-field RO/RW for RFC 8824 profile | Profile applying AC metadata to C/D field descriptors of a SCHC-for-CoAP Context | Profile-specific | Aligned (profile constrains its own Rules) | Aligned | None | -06 §5 Deployment Profiles legitimizes such profile constraints |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Not distinguished; "Context" == the rules | Context (SoR + metadata) owned/served by the Domain via Context Repository; used by an Instance | Partial | Draft must adopt -06's Context = SoR + metadata; access rights become part of that metadata. No behavioral change |
| Ownership of Set of Rules | The shared rule store of the two endpoints | SoR is the rule collection available to an Instance, provisioned within a Context | Aligned | Access-control leaves attach cleanly to the SoR and its Rules |
| Ownership of Set of Variables (SoV) | Not addressed | Runtime per-Session variables (timers, counters) | Not applicable (draft governs *configuration* of timers, not runtime SoV) | `ac-modify-timers` governs the F/R Rule parameters (config), distinct from -06 SoV (runtime); worth a one-line clarification |
| Endpoint ↔ SCHC Instance | Conflated as "endpoint" | Endpoint hosts one or more Instances; Instance holds the Context | Partial | Resolve draft "endpoint" to Instance (rule-holder) hosted on an Endpoint |
| SCHC Instance ↔ Session | Not addressed | An Instance participates in one or more Sessions; SoV is per-Session | Not applicable | Access control is Session-independent (it is on the Context/SoR), consistent with -06 |
| Sharing of Context between Sessions/Instances | Implicitly one shared set for two endpoints | A Context may be shared by two or more Instances / across Sessions | Aligned (special case) | Draft's 2-party assumption is a subset of -06; migration only broadens "two" to "two or more" |
| RuleID scope | RFC 8724 RuleID | RuleID identifies a Rule within a Context | Aligned | No change |
| Discriminator scope | Not used | Routes Datagrams to Instances | Not applicable | Access control is orthogonal to dispatch |
| Control Header processing scope | Not used | Framing/multiplexing metadata on the Datagram | Not applicable | Access control is a management-plane concern, not a data-plane header |
| Domain membership and boundaries | Not addressed; implicit single administrative scope | Domain = Instances sharing a common set of Contexts; managed by a Domain Manager | Partial | Access-control policy naturally lives at Domain scope (the Domain Manager governs Context modification); migration should state this once |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Access Control (access-right leaves) | Profile-specific | Is it merely a profile detail, or does hiding it in "Context metadata" abuse the metadata hook? -06 §3 explicitly says Context metadata "may refer to a data model", and §7 cites this draft as the access-control model. The metadata channel is being used for exactly its stated purpose (data-model-carried policy), not as a generic escape hatch. But calling it purely "profile-specific" understates that it also relies on the Data Model concept **and** the management entities that enforce it. | Composite (Context metadata + Data Model + management entities) | Reclassified from Profile-specific to Composite: the mapping is natural but genuinely spans three -06 concepts, and -06 itself anticipates it. Not a gap, but not a single-concept profile detail either |
| Rule Manager (RM) | Direct (to Instance Manager) | Does RM equal the Instance Manager alone? The RM applies *Rule* (i.e., Context/SoR) modifications. In -06, Context content is owned at Domain scope (Context Repository / Domain Manager), while the Instance Manager distributes configuration and synchronizes Contexts to Instances within an Endpoint. A single-entity mapping to Instance Manager would misplace ownership of the SoR. | Composite (Instance Manager + Domain Manager + Context Repository) | Reclassified from Direct to Composite so that ownership of the modified SoR stays at Domain scope while the per-Endpoint apply-path stays with the Instance Manager |
| Context (draft "= SCHC Rules") | Direct (to -06 Context) | Mapping draft "Context" directly to -06 "Context" would silently change meaning: -06 Context = SoR + metadata, whereas the draft's "Context" is just the rules. Using the identical word would hide that the access rights are metadata *added to* the Context, not part of the rules themselves. | Misleading | The identical term carries different scope; the draft's "Context" is -06's SoR, and the access rights are -06 Context metadata. Must be resolved explicitly, not by one-word substitution |
| Endpoint (RFC 8724 "two endpoints") | Direct (to -06 Endpoint) | -06 sharply separates Endpoint (hosting entity) from Instance (holder of the Context that runs SCHC). The draft's rule-sharing "endpoint" is the rule-holder = -06 Instance, not -06 Endpoint. A direct Endpoint mapping would misattribute the Context to the hosting entity. | Partial | Overloaded term resolved: rule-holding "endpoint" → Instance; hosting → Endpoint |

Three mappings were tightened during the adversarial pass (Access Control, Rule Manager, Context), and one term (Endpoint) was explicitly de-overloaded. None of these changes lowers the verdicts: all remaining mappings are Direct, Composite, or naturally Profile-specific, and every challenge was resolved *within* -06's existing concepts — confirming no Architecture gap.

## Architectural risk points

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

## Needed modifications to the draft under study

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

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §7 Security Considerations | Access-control model reference | "[I-D.ietf-schc-access-control] defines an access control model for SCHC Rules." | (No change required.) Optionally, one clause could note that such access control is carried as Context metadata in the Data Model and enforced by the Domain/Instance management entities. | OPTIONAL CLARIFICATION (**not a gap**) | -06 already provides the Context-metadata hook (§3), the management entities (§4.2.2.4, Fig. 2), and the forward reference. Any addition is a readability nicety, not a requirement to express the draft |

There are **zero ARCHITECTURE GAP** items. Every concept the draft requires is already present in -06.

## Final migration assessment
- **Can the draft be migrated without changing technical behavior?** Yes.
- **Can the migration be performed mechanically?** Mostly — the bulk is meaning-preserving terminology substitution; a small number of localized decisions (resolve overloaded "endpoint"/"Context"; express "Rule Manager" as a composite of -06 management entities) require light architectural judgment.
- **Does the draft expose a SCHC Architecture -06 gap?** No.
- **Is the gap required for this draft or merely useful generally?** Not applicable — there is no gap. The single -06 item above is an OPTIONAL CLARIFICATION that is only marginally useful, not required.
- **What is the single most important migration issue?** Pinning the draft's under-defined, overloaded terms — "Rule Manager", "Management request processing", and "Context (= SCHC Rules)" — onto -06's Context/SoR split and its Domain Manager / Context Repository / Instance Manager management functions, so that ownership of the mutated Set of Rules stays at Domain scope.

No modification to SCHC Architecture -06 is required.
