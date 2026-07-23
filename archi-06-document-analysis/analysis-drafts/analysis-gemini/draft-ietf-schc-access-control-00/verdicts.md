# Architectural alignment review: draft-ietf-schc-access-control-00

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All core concepts of the access control model (rules, fields, fragmentation parameters, and local enforcement of management permissions) can be naturally represented within the -06 model using Context metadata, Rule metadata, the Instance Manager, and the Domain Manager. No reinterpretation of the SCHC technical model is required. |
| Transition difficulty | Easy | A pure terminology search-and-replace is not sufficient because we must address the structural misalignment of `ac-modify-set-of-rules` and define how multiple instances are targeted. | The draft is very short (729 lines including large tables and YANG module), and the terminology and conceptual edits required are straightforward, localized, and easily mapped without changing the underlying protocol or security semantics. |
| SCHC Architecture adaptation need | None | Highest grade | -06 already provides all the necessary architectural concepts (Endpoints, Instances, Contexts, Instance Managers, Domain Managers, and Data Models) to fully support the draft's access control model without any modification. In fact, -06 already lists the draft as a related security document. |

## Executive assessment
The reference architecture SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping maps the Remote Entity (Management Client) to the Domain Manager and the local Rule Manager (RM) to the Instance Manager. The access control leaves function as Context/Rule metadata. The principal migration difficulty lies in correcting the structural nesting of `ac-modify-set-of-rules` in the YANG module, which is currently placed inside individual rules rather than at the root of the ruleset. No SCHC Architecture gap exists, and no modification to the reference architecture is required.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Remote Entity / Management Client | The external entity that initiates requests to update, add, or delete SCHC Rules. | External to the Endpoint (e.g., network server) | Domain or Administrative | N/A | 1 Remote Entity can manage N Rule Managers. | Communicates via NETCONF/RESTCONF/CORECONF. |
| Rule Manager (RM) | Local component on the endpoint that processes management requests and enforces access controls on rules. | Endpoint / Device | Endpoint-local | N/A | 1 Rule Manager per Endpoint. | Interprets the access control leaves. |
| Context / SCHC Rules | The container for SCHC compression and fragmentation rules. | Rule Manager / Endpoint | Endpoint-local (shared conceptually with peer) | N/A | 1 Context contains a Set of Rules. | Described by the augmented YANG Data Model. |
| Set of Rules | The collection of rules. | Rule Manager / Endpoint | Endpoint-local | N/A | 1 Set of Rules contains N Rules. | In YANG, represented by `/schc:schc/schc:rule`. |
| ac-modify-set-of-rules | Read-only leaf controlling whether rules can be added, deleted, or modified in the Set of Rules. | Rule Manager / Endpoint | Set of Rules / Instance | `ac-modify-set-of-rules` | 1 per Rule (structurally in draft's YANG; logically 1 per Set). | Hierarchical prerequisite for rule edits. |
| ac-modify-compression-rule | Read-only leaf controlling whether field descriptions can be added, deleted, or modified within a compression rule. | Rule Manager / Endpoint | Compression Rule | `ac-modify-compression-rule` | 1 per Compression Rule. | Prerequisite for field description edits. |
| ac-modify-field | Read-only leaf controlling modification of a specific Field Description (FID, TV, MO, CDA). | Rule Manager / Endpoint | Field Description | `ac-modify-field` | 1 per Field Description entry. | Typified by `field-access-right` enum. |
| ac-modify-timers | Read-only boolean leaf controlling whether fragmentation timers/parameters can be modified. | Rule Manager / Endpoint | Fragmentation Rule | `ac-modify-timers` | 1 per Fragmentation Rule. | Simply controls fragmentation timer edits. |
| TV/MO/CDA combinations | The valid combinations of TV, MO, and CDA that the RM must validate to prevent invalid/absurd rules. | Rule Manager / Endpoint | Rule-local / Validation | N/A | N/A | Described in Section 4 of the draft. |
| CoAP Options Access Control | Predefined read-only vs read/write permissions for specific CoAP headers and options. | Rule Manager / Endpoint | Field Description | Field ID (FID) | N/A | Figures 2 and 3 define standard permissions. |

## Native architectural model
The draft under study, `draft-ietf-schc-access-control-00`, addresses a critical security vulnerability in dynamic SCHC deployments: the risk of malicious or erroneous rule modifications. While the base SCHC specifications assume static, pre-configured rules, modern deployments require the ability to update, add, or delete rules dynamically via remote management protocols. Unrestricted rule modifications could allow an attacker to bypass compression, inject arbitrary data, or cause denial of service.

To mitigate these risks, the draft introduces a fine-grained access control model for SCHC rules. It extends the standard YANG Data Model defined in [RFC9363] by adding read-only access control leaves to the rule structure. These leaves define the permissions of remote entities to modify the ruleset at various levels of granularity.

The native architecture consists of a Remote Entity (or Management Client) that initiates rule modification requests, and a local Rule Manager (RM) residing on the endpoint. The Remote Entity communicates with the Rule Manager using network management protocols such as NETCONF, RESTCONF, or CORECONF.

When the Remote Entity attempts to write or edit the ruleset, the Rule Manager acts as the enforcement point. It intercepts the management requests and validates them against the read-only access control leaves associated with the target rules or fields.

The access control model is hierarchical and operates at four levels of granularity: the Set of Rules, the compression rule, individual field descriptions, and fragmentation rules. The leaves `ac-modify-set-of-rules`, `ac-modify-compression-rule`, `ac-modify-field`, and `ac-modify-timers` represent the permissions at these levels.

The `ac-modify-set-of-rules` leaf controls modifications at the ruleset level. It specifies whether the Remote Entity can add new rules, delete existing ones, or only modify existing rules. In the draft's YANG model, this leaf is structurally nested inside the individual rule, representing a per-rule setting that logically affects the parent collection.

The `ac-modify-compression-rule` leaf controls modifications to an individual compression rule, specifically governing whether field descriptions can be added, removed, or modified. This leaf is active only if the parent ruleset permissions allow modification.

At the finest level of granularity, the `ac-modify-field` leaf controls modifications to a specific Field Description within a compression rule. It restricts changes to the Target Value (TV), Matching Operator (MO), or Compression-Decompression Action (CDA) of a specific header field, preventing critical security fields from being altered while allowing dynamic fields (like URI paths) to be updated.

For fragmentation rules, the draft defines `ac-modify-timers`, a boolean leaf that controls whether fragmentation timers and associated state parameters can be modified.

In addition to YANG-defined access rights, the draft establishes validation constraints on TV/MO/CDA combinations. It defines a matrix of valid and invalid combinations (e.g., marking certain combinations as "absurd") that the Rule Manager must enforce during rule modification to ensure operational consistency and block potential attacks.

Finally, the draft specifies default access control profiles for CoAP headers and options. It defines fixed read-only rules for static base header fields (like Version or Code) and flexible read-write rules for repeatable options (like Uri-Path or Uri-Query), aligning security policies with protocol semantics.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Remote Entity / Management Client | The external entity initiating rule updates. | Domain Manager (specifically Context Manager) | Direct | Aligned (Domain/Administrative scope) | Aligned (1 Domain Manager to N Instances) | None. | The Domain Manager is responsible for context provisioning and synchronization in -06. |
| Rule Manager (RM) | Local component enforcing access control and applying rule modifications. | Instance Manager | Direct | Aligned (Endpoint-local) | Aligned (1 Instance Manager per Endpoint) | None. | The Instance Manager in -06 is responsible for "synchronizing Contexts" and managing configuration. |
| Context / SCHC Rules | The ruleset container. | Context | Direct | Aligned (shared by Instances) | Aligned | None. | Context in -06 contains the SoR and metadata. |
| Set of Rules | The collection of rules. | Set of Rules (SoR) | Direct | Aligned (Instance-local) | Aligned | None. | Maps directly to the collection of Rules. |
| ac-modify-set-of-rules | Permitted modifications to the ruleset. | Context Metadata / Instance Configuration | Partial | Mismatched (structurally nested in Rule in draft, but logically applies to SoR/Instance) | Mismatched (draft: 1 per Rule; -06: 1 per SoR/Instance) | Structurally nested under individual Rule in draft, which conflicts with its scope as a ruleset-wide control. | In -06, the permission to modify the SoR belongs to the Context or Instance Configuration. |
| ac-modify-compression-rule | Permitted modifications to a compression rule. | Rule Metadata | Direct | Aligned (Rule-local) | Aligned (1 per Rule) | None. | In -06, a Rule is structured; this leaf is metadata on the C/D Rule. |
| ac-modify-field | Permitted modifications to a field entry. | Rule Entry Metadata | Direct | Aligned (Rule entry-local) | Aligned (1 per Field Description) | None. | Metadata on the Field Description entry within the Rule. |
| ac-modify-timers | Permitted modifications to fragmentation timers. | Rule Metadata | Direct | Aligned (Rule-local) | Aligned (1 per Rule) | None. | Controls modification of the fragmentation parameters/variables within the Rule. |
| TV/MO/CDA combinations | Valid C/D field descriptor configurations. | Parser / Data Model validation rules | Profile-specific | Aligned (Instance-local validation) | Aligned | The draft codifies these rules as protocol constraints, which -06 handles via profile/data model constraints. | -06 leaves validation rules to technology-specific profiles or data models. |
| CoAP Options Access Control | Predefined access rights for CoAP fields. | Data Model / Context template | Profile-specific | Aligned (applied to CoAP profile) | Aligned | These are profile-level constraints for CoAP compression, not core architectural components. | Naturally defined by a CoAP compression profile using -06's extensible data model/Context. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Owned by the Rule Manager at the Endpoint. | Shared between two or more Instances in a Session; managed by the Domain/Instance Manager. | Aligned | The RM processes updates locally, which corresponds to the Instance Manager applying updates to the Instance's Context. |
| Ownership of Set of Rules | Nesting under `/schc:schc/schc:rule` list. | Contained within the Context of an Instance. | Aligned | The ruleset is stored at the Endpoint and matches the SoR of the Instance. |
| Ownership of Set of Variables | Mentions fragmentation timers (which belong to fragmentation rule state). | Contained in the Set of Variables (SoV) per Session. | Aligned | Modifying timers affects the variables used at runtime. |
| Endpoint↔SCHC Instance | Implicitly treated as 1:1 (refers to "end-point Rule Manager" and "endpoints"). | 1 Endpoint can host multiple Instances, each with its own Context and Config. | Partially Aligned | The draft's model assumes a single instance per endpoint. Under -06, the Rule Manager must distinguish which Instance/Context is being updated. |
| SCHC Instance↔Session | Implicitly 1:1 or not detailed. | N Instances participate in a Session; Sessions share a Context. | Aligned | Enforcing access control on a Context affects all Instances sharing that Context. |
| Sharing of Context between Sessions/Instances | Implicitly shared between the two communicating endpoints. | Multiple Sessions/Instances can share the same Context. | Aligned | If a Context is shared, a modification by one Endpoint must be synchronized with other Endpoints sharing it. |
| RuleID scope | Key of the `rule` list; unique within the instance. | Unique within the scope of the Instance / Context. | Aligned | Identifies the target rule for modifications. |
| Discriminator scope | Not applicable. | Used by Dispatcher to route packets to the correct Instance. | Not applicable | Discriminators are for routing, while access control operates on the management plane. |
| Control Header processing scope | Not applicable. | Used for routing or metadata; independent of rule modification. | Not applicable | No overlap with access control. |
| Domain membership and boundaries | Assumes remote entity manages the local endpoint's rules. | A Domain groups Instances sharing Contexts; managed by Domain Manager. | Aligned | The Remote Entity acts as the Domain Manager, and the Endpoint belongs to the managed Domain. |

## Challenged mappings
| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| ac-modify-set-of-rules | Composite (Context Metadata / Instance Configuration) | The draft places this leaf inside each individual rule container (`/schc:schc/schc:rule`). However, it logically controls the ability to add or delete rules from the entire Set of Rules. If no rules exist, or if different rules contain conflicting values, the RM cannot evaluate it consistently. In -06, the Set of Rules is owned by the Context or Instance, meaning this control belongs at the Context/Instance level, not inside individual Rules. | Partial | Changed from Composite to Partial because the draft's structural scoping of this leaf under individual rules does not align with the ruleset-level scope in -06. |

## Architectural risk points
- **Risk:** Rule-Nested Ruleset Permissions
  - **Why it matters:** In the draft's YANG model, the leaf `ac-modify-set-of-rules` is nested inside `/schc:schc/schc:rule` (which is a list of rules). This creates a logical paradox: if the ruleset is empty, the management client cannot read this leaf to determine if it is permitted to add a rule. Furthermore, if multiple rules exist with conflicting values for this leaf, there is no defined behavior for which permission takes precedence.
  - **Consequence for migration:** To align with -06, the permission to modify the Set of Rules must be moved out of the rule list and placed at the top-level container of the SCHC instance (e.g., `/schc:schc` or inside the Context/Instance Configuration), requiring a structural modification of the YANG schema.
- **Risk:** Multi-Instance Endpoint Management Ambiguity
  - **Why it matters:** The draft assumes a single implicit endpoint/instance structure (referring to the "end-point Rule Manager"). However, -06 explicitly allows multiple SCHC Instances to coexist on a single Endpoint, each with its own Context and configuration. The draft does not specify how a management request identifies which Instance or Context is the target of the rule modification.
  - **Consequence for migration:** The management protocol and Rule Manager must be updated to include an Instance or Context identifier in the request path, so the Instance Manager can apply the access control rules to the correct Instance context.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 6.1, and Appendix A (lines 644-649) | `leaf ac-modify-set-of-rules` is nested inside `/schc:schc/schc:rule`. | Move the `ac-modify-set-of-rules` leaf to the root container `/schc:schc` (or a separate instance/context configuration container) instead of the individual `rule` list element. | REQUIRED FOR CONCEPTUAL ALIGNMENT | If the ruleset is empty, or if different rules contain conflicting values, the Rule Manager cannot determine the permission to add or delete rules. Ruleset-wide permissions must reside at the ruleset/instance level. |
| 2 | Throughout (e.g. Sections 1, 3, 5) | Uses "end-point Rule Manager", "endpoints", "remote entity". | Replace "end-point Rule Manager" / "Rule Manager" with "Instance Manager" (or "local Rule Manager acting as part of the Instance Manager"), "endpoints" with "Instances", and "remote entity" with "Domain Manager" or "Remote Management Client". | REQUIRED FOR TERMINOLOGY MIGRATION | Align terminology with the core components defined in SCHC Architecture -06. |
| 3 | Section 3 (Terminology) | Placeholder "ToDo" list for terminology definitions. | Replace placeholders with standard definitions for "Instance Manager", "Domain Manager", "Context", and "Set of Rules", referencing their definitions in `draft-ietf-schc-architecture-06`. | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves temporary placeholders and integrates terminology with the reference architecture. |
| 4 | Section 5 (YANG Access Control) | "The SCHC access control augments the YANG module defined in [RFC9363] to allow a remote entity to manipulate the rules." | Clarify that in multi-instance deployments, the management request must carry a SCHC Instance Identifier or Context Identifier so the Instance Manager can route the request to the correct Instance. | OPTIONAL CLARIFICATION | Clarifies how the model scales to multi-instance endpoints. |
| 5 | Appendix A (YANG model, lines 582-586 and 592) | Description references "compound-ack behavior" and "Compound Ack". | Update description and references to match SCHC Access Control. | EDITORIAL | Fixes copy-paste errors from the Compound ACK draft. |
| 6 | Section 6.3.1 | "...the based header is only readable..." | Correct "based header" to "base header". | EDITORIAL | Typo fix. |
| 7 | Abstract & Section 1 | "...defines defines augmentation..." and "...define a augmentation..." | Correct to "...defines an augmentation..." and "...define an augmentation...". | EDITORIAL | Grammatical fixes. |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Mostly (fixing the YANG structure of `ac-modify-set-of-rules` changes structural behavior, but preserves the original security and administrative intent).
- Can the migration be performed mechanically? No (requires architectural judgment to relocate the ruleset-level permission and define multi-instance target scoping).
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A (no gap exists)
- What is the single most important migration issue? Resolving the structural scoping of the `ac-modify-set-of-rules` leaf in the YANG model, moving it from the individual rule list to the root container level to make ruleset-wide modifications logically and technically checkable.
