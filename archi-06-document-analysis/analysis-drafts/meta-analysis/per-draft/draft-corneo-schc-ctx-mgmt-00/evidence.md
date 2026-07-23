# Evidence Notes: draft-corneo-schc-ctx-mgmt-00

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

- **Natural Expressibility:** SCHC Architecture -06 can naturally express the draft under study. The draft's core mechanisms (nested rules and dynamic branching) fit within the existing concept of SCHC Rules and the C/D engine execution, provided that the sequential execution of composed rule fragments is explicitly recognized.
- **Principal Conceptual Mapping:** The native draft concepts of "compressor/decompressor" map directly to the C/D functions of the **SCHC Instance**. "Context" and "Rules" (including merged, deprecated, and fragment rules) map directly to -06 **Context** and **Rules**.
- **Principal Migration Difficulty:** The main migration difficulty is updating the terminology of the draft from general "endpoints" to specific "Instances" and "Endpoints," and aligning the dynamic "Context Compression Procedure" (Section 4.3) with the static-by-default Domain Manager provisioning model of SCHC Architecture -06.
- **Architecture Gap:** A trivial architecture gap exists because -06 does not explicitly define "Rule Fragments" or detail how the C/D engine sequentially/recursively executes composed rules.

### Architectural risk points

- **Risk:** Undefined Context Synchronization Protocol
  - **Why it matters:** The context compression procedure relies on signaling new rules to all endpoints and confirming their reception before removing deprecated rules. Without a standardized protocol, endpoints can suffer context desynchronization, leading to immediate decompression failures.
  - **Consequence for migration:** The draft must clearly state that dynamic rule compression relies on out-of-band management or a future SCHC Architecture management protocol, framing it as a management plane dependency.
- **Risk:** Recursive processing limits on constrained devices
  - **Why it matters:** Constrained IoT nodes have highly limited stack space and RAM. Deep nesting of `ref` and `branch` CDAs could cause stack overflow or memory exhaustion due to the branch queue.
  - **Consequence for migration:** Technology-specific profiles must mandate strict limits on maximum nesting depth and mapping table size.
- **Risk:** Dependency constraint on compatible partial contexts
  - **Why it matters:** Under -06, leaf nodes can host partial contexts containing subsets of rules. However, if a leaf node retains a referencing rule but discards the referenced rule fragment, C/D execution will fail.
  - **Consequence for migration:** Context distribution tools must resolve and package all transitive dependencies when creating compatible partial contexts.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Throughout draft | "compressor/decompressor", "endpoints" | Update to "SCHC Instance (or its C/D function)" and "SCHC Instances" / "Endpoints hosting the Instances" | REQUIRED FOR TERMINOLOGY MIGRATION | Alignment with SCHC Architecture -06 terminology. |
| 2 | Section 4.3 | "Signal the new rules to all SCHC endpoints. Once confirmed..." | "Distribute and synchronize the updated Context containing the new rules to all participating SCHC Instances via the Domain Manager and Instance Managers. Once confirmed..." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Integrates the context compression procedure with the management plane components defined in -06. |
| 3 | Section 7.1 & 7.2 | "Implementations MUST detect circular references... Implementations SHOULD enforce limits..." | Clarify that the Domain Manager and Instance Manager validate context integrity (DAG verification) and enforce limits during provisioning. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Aligns provisioning and security responsibilities with -06 management entities. |
| 4 | Section 4.1 & 4.2 | Target Value and Field Length are not used in `ref` field descriptions. | Add an explicit note on how the parser (as defined in -06) handles these dummy fields. | OPTIONAL CLARIFICATION | Clarifies implementation mapping to the -06 Parser component. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 | Rule | `Rule: A structured description, identified by a RuleID, of how SCHC processes a packet or a SCHC message. Depending on its type, a Rule defines C/D field descriptors, F/R mode and parameters, or no-compression behavior.` | Add at the end: `Rules may reference other rules or branch to alternative rules (rule fragments) within the same Set of Rules to enable modular or dynamic protocol compression.` | ARCHITECTURE GAP | Provides explicit support for rule composition and fragments in the architecture. |
| 2 | Section 3 | Rule Fragment (New Term) | *(None)* | Add definition: `Rule Fragment: A Rule designed to compress or decompress a specific portion or layer of a packet, intended to be composed with other Rules or Rule Fragments.` | ARCHITECTURE GAP | Introduces the concept of rule fragments to the terminology. |
| 3 | Section 4.2.2.1 | C/D Engine | `* applies the compression Rule to the fields of the header(s);` | `* applies the compression Rule to the fields of the header(s); this may include sequentially or recursively executing referenced rules or rule fragments if specified by the rule's actions.` | ARCHITECTURE GAP | Clarifies that the C/D engine execution can be recursive or sequential. |
| 4 | Section 6.2 | Context consistency | `...as long as the Contexts of the Instances participating in a given session remain compatible.` | Add at the end: `Contexts may also be optimized or compressed by grouping shared field descriptions into composed rules, provided the resulting Contexts remain synchronized across all participating Instances.` | OPTIONAL CLARIFICATION | Connects context consistency to context compression procedures. |

### Final migration assessment

- **Can the draft be migrated without changing technical behavior?** Mostly (the core C/D operations and wire residues are unchanged, but context update signaling must be delegated to the management plane).
- **Can the migration be performed mechanically?** Mostly (terminology replacements are mechanical, but reframing Section 4.3 and Section 7 around -06 management entities requires some manual rewriting).
- **Does the draft expose a SCHC Architecture -06 gap?** Yes (the lack of explicit support for rule referencing/composition and sequential/recursive rule execution).
- **Is the gap required for this draft or merely useful generally?** The gap of rule composition is required for this draft; context synchronization clarifications are useful generally.
- **What is the single most important migration issue?** Aligning the dynamic context management and rule signaling assumptions with the static-by-default, Domain Manager-driven provisioning model of SCHC Architecture -06.
