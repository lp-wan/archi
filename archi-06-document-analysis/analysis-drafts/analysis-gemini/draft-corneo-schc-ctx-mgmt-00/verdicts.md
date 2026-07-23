# Architectural alignment review: draft-corneo-schc-ctx-mgmt-00

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **Very High** | Highest grade. | All core concepts of rule referencing, branching, and context compression map directly or compositely to SCHC Architecture -06 without substantive reinterpretation of technical behavior. |
| **Transition difficulty** | **Easy** | Requires minor non-mechanical adjustments to map "endpoints" and "compressor/decompressor" to -06 "Instances" and "Endpoints," rather than a pure search-and-replace. | No major structural rewrites or complex architectural judgments are needed; technical intent and rules remain stable. |
| **SCHC Architecture adaptation need** | **Trivial** | No existing normative definitions or statements in -06 shift meaning; the core architecture remains fully stable. | Clarifications (definition of Rule Fragment, and explicit notes on sequential/recursive execution of composed rules) are necessary to make the mapping natural and explicit. |

## Executive assessment
- **Natural Expressibility:** SCHC Architecture -06 can naturally express the draft under study. The draft's core mechanisms (nested rules and dynamic branching) fit within the existing concept of SCHC Rules and the C/D engine execution, provided that the sequential execution of composed rule fragments is explicitly recognized.
- **Principal Conceptual Mapping:** The native draft concepts of "compressor/decompressor" map directly to the C/D functions of the **SCHC Instance**. "Context" and "Rules" (including merged, deprecated, and fragment rules) map directly to -06 **Context** and **Rules**.
- **Principal Migration Difficulty:** The main migration difficulty is updating the terminology of the draft from general "endpoints" to specific "Instances" and "Endpoints," and aligning the dynamic "Context Compression Procedure" (Section 4.3) with the static-by-default Domain Manager provisioning model of SCHC Architecture -06.
- **Architecture Gap:** A trivial architecture gap exists because -06 does not explicitly define "Rule Fragments" or detail how the C/D engine sequentially/recursively executes composed rules.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **Compressor / Decompressor** | The functional engines that execute rule matching, compression, and decompression. | Device / Gateway | Node-local processing | None | 1 per executing entity | Handles packet processing pointer and branch queue. |
| **Context** | The set of rules shared between the compressor and decompressor. | Shared between peers | Session scope | None | 1 per communication relationship | Must be kept synchronized. |
| **Rule** (incl. merged, deprecated, fragment) | A list of field descriptions with matching operators and compression/decompression actions. | Context | Context-local | Rule ID (RuleID) | N rules per Context | Can be composed recursively or branched. |
| **ref(N) CDA** | Action that suspends the current rule and applies Rule N to the packet. | Field description in a rule | Rule-local control flow | Rule ID N | 0..N per rule | Suspend/resume execution logic. |
| **ref-edit(N,M) CDA** | Action that applies Rule N with M overridden field descriptions. | Field description in a rule | Rule-local control flow | Rule ID N, override count M | 0..N per rule | Dynamic override in memory. |
| **branch CDA** | Action that encodes a selection among alternative rule fragments into the residual. | Field description in a rule | Rule-local control flow | Selection target value | 0..N per rule | Encodes short index on the wire. |
| **match-mapping MO** | Matching operator using a mapping table to select a branch based on field value. | Field description in a rule | Field-local matching | Field value | Used with branch on FL > 0 | Matches explicit header fields (e.g., Next Header). |
| **match-rule MO** | Matching operator that sequentially evaluates candidate rules to select a branch. | Field description in a rule | Field-local matching | Candidate Rule IDs list | Used with branch on FL = 0 | Matches implicit payload types (e.g., UDP payload). |
| **Branch Queue** | An internal state queue for depth-first execution of branched rules. | Compressor/Decompressor | Packet processing transaction | None | 1 per rule execution session | Maintains execution order. |
| **Rule ID 0** | Fallback Rule ID used to transmit uncompressed packets on matching failure. | Context / Protocol | Global / Link | Rule ID 0 | 1 per context | Standard no-compression escape. |

## Native architectural model

The draft-corneo-schc-ctx-mgmt-00 document addresses context management overhead and combinatorial rule explosion when compressing multi-layer protocol stacks. In standard SCHC, compressing a multi-layer stack requires defining flat rules that duplicate lower-layer field descriptions (e.g., IPv6) for every combination of upper-layer protocols (e.g., UDP, TCP, RTP, CoAP). As contexts scale, this duplication increases context storage on constrained devices and leads to slow rule matching times.

To solve this, the draft introduces two primary mechanisms: Rule Referencing and Rule Fragment Branching. These mechanisms allow contexts to be organized hierarchically and executed modularly by the compressor/decompressor.

Rule Referencing is enabled by two new Compression/Decompression Actions (CDAs): `ref(N)` and `ref-edit(N,M)`. The `ref(N)` CDA allows a rule to reference a dedicated lower-layer rule (Rule N) by its Rule ID. When encountered, the compressor/decompressor suspends the current rule's execution, runs Rule N, and then returns to process subsequent field descriptions. The `ref-edit(N,M)` CDA extends this by allowing the referencing rule to dynamically override up to M field descriptions in the referenced Rule N before applying it, resolving cases where a shared header field (such as Next Header) differs between referencing protocols.

To facilitate rule referencing, the draft proposes an optimization process called the Context Compression Procedure. This procedure groups identical sets of adjacent field descriptions across the context, extracts them into new rules, and replaces the duplicated segments in the original rules with referencing CDAs. The new rules are then signaled to all endpoints.

Rule Fragment Branching allows a rule to branch dynamically to alternative rule fragments based on packet content. It is implemented via the `branch` CDA and two Matching Operators (MOs): `match-mapping` and `match-rule`. The `branch` CDA associates target values or rule candidate lists with next Rule IDs and short residual codes.

When the next protocol is explicitly signaled by a header field (e.g., Next Header in IPv6), the `match-mapping` MO matches the field value against the mapping table, encodes the corresponding short residual on the wire, and queues the selected Rule ID for execution.

When the next protocol is implicit (e.g., payload after UDP), the `match-rule` MO is used with a zero-length field. The compressor sequentially evaluates a list of candidate rules against the packet. The first matching rule determines the branch, encoding its index in the residual.

Branch processing is depth-first: if a rule contains multiple branches, each branched rule fragment is fully processed (including its own nested branches) before the parent rule's next queued branch is evaluated. A tracking pointer (`Current_Location`) advances as fragments are compressed.

If a referenced rule fragment fails to match the packet, the entire compression fails, and the packet is sent uncompressed using Rule ID 0. To prevent failure on unknown payloads, the branch mapping can include a `branch(NULL)` fallback to gracefully terminate compression and leave the remainder of the packet uncompressed.

Finally, the draft identifies security concerns regarding the reference graph, mandating that implementations prevent circular references (infinite loops) and enforce resource limits on nesting depth, mapping table size, and candidate evaluation lists to prevent resource exhaustion.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **Compressor / Decompressor** | Execution engines for C/D operations. | **SCHC Instance (C/D Function)** | Direct | Aligned | Aligned | In -06, C/D is a logical function within an Instance. | Standard C/D execution. |
| **Context** | Synchronized rule database. | **Context** | Direct | Aligned | Aligned | None | None. |
| **Rule** (incl. fragments) | Field descriptions list. | **Rule** | Direct | Aligned | Aligned | None | Fragments are standard rules. |
| **ref(N) / ref-edit(N,M) CDA** | Control flow redirection CDAs. | **CDA (extensibility)** | Profile-specific | Aligned | Aligned | Control flow redirects instead of single field transformation. | Fully compliant with -06 extensibility. |
| **branch CDA** | Selection encoding CDA. | **CDA (extensibility)** | Profile-specific | Aligned | Aligned | Encodes next Rule ID index in residual. | Fully compliant with -06 extensibility. |
| **match-mapping MO** | Value-to-branch matching. | **Matching Operator (MO)** | Direct | Aligned | Aligned | Extends mapping to select branches. | Fully compliant with -06. |
| **match-rule MO** | Candidate rule list evaluation. | **Matching Operator (MO)** | Profile-specific | Aligned | Aligned | Sequentially evaluates rules instead of field values. | Fully compliant with -06. |
| **Branch Queue / Pointer** | Transaction processing state. | **C/D Internal State** | Direct | Aligned | Aligned | Internal state details are not modeled in -06. | Implementation detail. |
| **Rule ID 0** | Fallback uncompressed rule. | **no-compression Rule** | Direct | Aligned | Aligned | None | Standard SCHC concept. |
| **Context Compression Procedure** | Optimization and signaling. | **Domain Manager / Instance Manager** | Composite | Aligned | Aligned | The draft details the algorithm; -06 models the managers. | Maps to context synchronization plane. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Shared between compressor and decompressor. | Owned by Instance and shared between Instances of a Session. | Fully aligned | None. |
| **Ownership of Set of Rules** | Part of Context. | Part of Context. | Fully aligned | None. |
| **Ownership of Set of Variables** | Not mentioned (inherits RFC8724). | Owned by Session / Instance. | Not applicable | None. |
| **Endpoint↔SCHC Instance** | Uses "SCHC endpoint" as the logical node containing rules. | Endpoint hosts Instances; Instance executes C/D with Context. | Terminology Mapping | Draft text must refer to Instances for rule execution and context. |
| **SCHC Instance↔Session** | Implicit peer communication. | Session connects Instances sharing Context. | Fully aligned | None. |
| **Sharing of Context between Sessions/Instances** | Context is shared between participating endpoints. | Context shared between Instances of a Session. | Fully aligned | None. |
| **RuleID scope** | Unique within the Context. | Unique within the Context (SoR). | Fully aligned | Rule IDs are local to the Instance Context. |
| **Discriminator scope** | Not mentioned. | Used by Dispatcher to route to Instance. | Not applicable | None. |
| **Control Header processing scope** | Not mentioned. | Decoded before/after RuleID to select Instance. | Not applicable | None. |
| **Domain membership and boundaries** | Not mentioned. | Logical grouping of Instances sharing Contexts. | Fully aligned | None. |

## Challenged mappings

`No mapping classification changed during the adversarial pass.`

## Architectural risk points

- **Risk:** Undefined Context Synchronization Protocol
  - **Why it matters:** The context compression procedure relies on signaling new rules to all endpoints and confirming their reception before removing deprecated rules. Without a standardized protocol, endpoints can suffer context desynchronization, leading to immediate decompression failures.
  - **Consequence for migration:** The draft must clearly state that dynamic rule compression relies on out-of-band management or a future SCHC Architecture management protocol, framing it as a management plane dependency.
- **Risk:** Recursive processing limits on constrained devices
  - **Why it matters:** Constrained IoT nodes have highly limited stack space and RAM. Deep nesting of `ref` and `branch` CDAs could cause stack overflow or memory exhaustion due to the branch queue.
  - **Consequence for migration:** Technology-specific profiles must mandate strict limits on maximum nesting depth and mapping table size.
- **Risk:** Dependency constraint on compatible partial contexts
  - **Why it matters:** Under -06, leaf nodes can host partial contexts containing subsets of rules. However, if a leaf node retains a referencing rule but discards the referenced rule fragment, C/D execution will fail.
  - **Consequence for migration:** Context distribution tools must resolve and package all transitive dependencies when creating compatible partial contexts.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Throughout draft | "compressor/decompressor", "endpoints" | Update to "SCHC Instance (or its C/D function)" and "SCHC Instances" / "Endpoints hosting the Instances" | REQUIRED FOR TERMINOLOGY MIGRATION | Alignment with SCHC Architecture -06 terminology. |
| 2 | Section 4.3 | "Signal the new rules to all SCHC endpoints. Once confirmed..." | "Distribute and synchronize the updated Context containing the new rules to all participating SCHC Instances via the Domain Manager and Instance Managers. Once confirmed..." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Integrates the context compression procedure with the management plane components defined in -06. |
| 3 | Section 7.1 & 7.2 | "Implementations MUST detect circular references... Implementations SHOULD enforce limits..." | Clarify that the Domain Manager and Instance Manager validate context integrity (DAG verification) and enforce limits during provisioning. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Aligns provisioning and security responsibilities with -06 management entities. |
| 4 | Section 4.1 & 4.2 | Target Value and Field Length are not used in `ref` field descriptions. | Add an explicit note on how the parser (as defined in -06) handles these dummy fields. | OPTIONAL CLARIFICATION | Clarifies implementation mapping to the -06 Parser component. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 | Rule | `Rule: A structured description, identified by a RuleID, of how SCHC processes a packet or a SCHC message. Depending on its type, a Rule defines C/D field descriptors, F/R mode and parameters, or no-compression behavior.` | Add at the end: `Rules may reference other rules or branch to alternative rules (rule fragments) within the same Set of Rules to enable modular or dynamic protocol compression.` | ARCHITECTURE GAP | Provides explicit support for rule composition and fragments in the architecture. |
| 2 | Section 3 | Rule Fragment (New Term) | *(None)* | Add definition: `Rule Fragment: A Rule designed to compress or decompress a specific portion or layer of a packet, intended to be composed with other Rules or Rule Fragments.` | ARCHITECTURE GAP | Introduces the concept of rule fragments to the terminology. |
| 3 | Section 4.2.2.1 | C/D Engine | `* applies the compression Rule to the fields of the header(s);` | `* applies the compression Rule to the fields of the header(s); this may include sequentially or recursively executing referenced rules or rule fragments if specified by the rule's actions.` | ARCHITECTURE GAP | Clarifies that the C/D engine execution can be recursive or sequential. |
| 4 | Section 6.2 | Context consistency | `...as long as the Contexts of the Instances participating in a given session remain compatible.` | Add at the end: `Contexts may also be optimized or compressed by grouping shared field descriptions into composed rules, provided the resulting Contexts remain synchronized across all participating Instances.` | OPTIONAL CLARIFICATION | Connects context consistency to context compression procedures. |

## Final migration assessment
- **Can the draft be migrated without changing technical behavior?** Mostly (the core C/D operations and wire residues are unchanged, but context update signaling must be delegated to the management plane).
- **Can the migration be performed mechanically?** Mostly (terminology replacements are mechanical, but reframing Section 4.3 and Section 7 around -06 management entities requires some manual rewriting).
- **Does the draft expose a SCHC Architecture -06 gap?** Yes (the lack of explicit support for rule referencing/composition and sequential/recursive rule execution).
- **Is the gap required for this draft or merely useful generally?** The gap of rule composition is required for this draft; context synchronization clarifications are useful generally.
- **What is the single most important migration issue?** Aligning the dynamic context management and rule signaling assumptions with the static-by-default, Domain Manager-driven provisioning model of SCHC Architecture -06.
