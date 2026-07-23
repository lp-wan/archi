# Architectural alignment review: draft-ietf-schc-universal-option-01

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | The core technical concepts (hierarchical option spaces, syntactic/semantic option representations, and entry ordering constraints) can be naturally mapped onto SCHC -06 concepts without modifying the underlying technical model. |
| Transition difficulty | Easy | Mostly mechanical terminology updates are needed, but it requires minor local rewriting and updating reference citations. | The draft is short, and its concepts are already highly aligned with the SCHC framework, requiring no architectural restructuring or redesign. |
| SCHC Architecture adaptation need | Trivial | Existing text does not need to change its meaning, but the minor gap (clarifying field descriptor processing and serialization order across multiple data model lists) is easily closed by adding a short note. | A gap does exist: -06 must explicitly specify that entry ordering and residue serialization order must be preserved and consistent when using multiple lists in a data model, which is currently unaddressed. |

## Executive assessment
The Static Context Header Compression (SCHC) Architecture -06 can naturally express the concepts, relationships, and assumptions of `draft-ietf-schc-universal-option-01`. The principal conceptual mapping involves treating the hierarchical option representation (composed of a `space-id` and an `option-id`) as a composite Field Identifier within a Rule's field descriptor in the Context/Data Model. The main migration difficulty lies in updating references from the old architecture draft (`[I-D.ietf-lpwan-architecture]`) to `draft-ietf-schc-architecture-06` and performing minor mechanical updates to terminology (e.g., replacing "end-point" with "Endpoint"/"Instance" and "Rule management" with "Context management"). A trivial architecture gap exists because the current -06 text lacks explicit guidelines on preserving field descriptor ordering and residue serialization sequences when a Context is represented by multiple lists in a data model (like `entry` and `entry-option-space`). This gap is easily resolved by adding minor clarifications to the Context and C/D engine specifications in the architecture.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Protocol Option Space (`space-id`) | Represents a protocol namespace (e.g. CoAP, TCP) to prevent option-id collisions between different protocols. | SCHC WG / IANA | Global | Identityref (`space-type`) | 1:N (one space can contain multiple option-ids). | Part of the list key in the augmented YANG model. |
| Option Identifier (`option-id`) | The native protocol option number (e.g., 11 for Uri-Path) assigned by IANA for that protocol. | IANA / Protocol spec | Local to the `space-id` | `uint32` | N:1 with `space-id` | Allows mapping options using native numbering schemes. |
| `entry-option-space` | List entry in the augmented YANG model representing a rule's field descriptor for a protocol option. | SCHC Instance / Context | Instance-local | Key `[space-id option-id field-position direction-indicator]` | 1:N (one Rule contains multiple option-space entries). | Bypasses the key constraints of the standard `entry` list. |
| Field Identifier (FID) | Abstract identifier representing a header field in standard SCHC. | Standards / RFC 9363 | Global | `identityref` | 1:1 with standard field | Deprecated for CoAP options in favor of `space-id` + `option-id`. |
| Entry Serialization Order | The rule that standard entries must be serialized and processed before option-space entries to maintain residue consistency. | C/D Engine | Session-wide | Implicit (via parser/serializer rules) | N/A | Essential to prevent residue misalignment. |
| Syntactic Option representation | Representing an option by decomposing it into its three wire-format components: option delta/number, length, and value. | C/D Engine / Parser | Node-local | FIDs `CoAP.option`, `CoAP.length`, `CoAP.value` | 1 option to 3 entries | Lower compression efficiency but high flexibility. |
| Semantic Option representation | Directly using protocol option numbers mapped in the rules without converting them to abstract FIDs. | C/D Engine | Session-wide | `space-id` + `option-id` | 1:1 | The primary proposed approach (Universal Options). |

## Native architectural model
The native architectural model of `draft-ietf-schc-universal-option-01` addresses the challenges of compressing protocols with extensible options, such as CoAP, within the SCHC framework. Standard SCHC (RFC 8724) and its YANG Data Model (RFC 9363) abstract CoAP option fields into flat, predefined Field Identifiers (FIDs). This static abstraction creates interoperability and deployment issues when a protocol introduces new options or when private, implementation-specific options are used. Because the FIDs are hardcoded in the software, endpoints cannot represent or exchange rules for new options without software updates.

To resolve this, the draft proposes representing protocol options using their native numbering space rather than converting them to abstract FIDs. To prevent option number collisions between different protocols (since different protocols may use the same number for different options), options are qualified by a protocol namespace called a Protocol Option Space (`space-id`), such as CoAP or TCP. Within this space, each option is identified by its native Option Identifier (`option-id`), such as 11 for Uri-Path.

From a data model perspective, implementing this "Universal Options" approach requires extending the SCHC YANG Data Model. The standard `entry` list in RFC 9363 has a key of `[field-id field-position direction-indicator]`. Because standard FIDs are flat, repeating the same FID for multiple option occurrences in a rule can lead to key collision or structural inefficiency. The draft introduces a separate list, `entry-option-space`, specifically designed to describe protocol options. Its key is `[space-id option-id field-position direction-indicator]`, allowing multiple options to be represented cleanly without conflict.

Having two separate lists of field descriptors (the standard `entry` list and the new `entry-option-space` list) creates a critical constraint for residue serialization. To ensure that both the compressing and decompressing entities process residues in the same sequence, the order of entries must be preserved. The draft specifies that standard entries must always be serialized before option-space entries. Furthermore, the draft requires that the rule transmission and synchronization protocols preserve the order of Field Descriptors as they appear in the packet header, which requires adding ordering constraints (e.g., `ordered-by user;` in YANG) to the data model.

Additionally, the draft discusses a "Syntactic" compression approach as a baseline. In this approach, CoAP options are parsed and represented by three separate fields: option delta/number, option length, and option value. While this syntactic approach allows any option to be processed without updates to the implementation, it is less efficient because it requires three separate rule entries and results in redundant length transmission in the compressed packet residue. The "Semantic" (Universal Options) approach avoids this overhead by mapping options directly using their protocol-specific option numbers and spaces.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Protocol Option Space (`space-id`) | Represents a protocol namespace (e.g., CoAP, TCP) to prevent option-id collisions. | **Data Model** (Context metadata) | Composite | Aligned | Aligned | None | Part of the composite identifier for a field descriptor. |
| Option Identifier (`option-id`) | Native protocol option number (e.g., 11 for Uri-Path). | **Field ID** (Rule field descriptor) | Composite | Aligned | Aligned | None | Combines with `space-id` to identify a specific field. |
| `entry-option-space` | List entry representing a field descriptor for an option in the YANG data model. | **field descriptor** (Rule) | Direct | Aligned | Aligned | None | Represents option field descriptors within a C/D Rule. |
| Field Identifier (FID) | Flat abstract identifier for standard fields. | **Field ID** (Rule field descriptor) | Direct | Aligned | Aligned | None | Maps directly to the standard Field ID concept. |
| Entry Serialization Order | Constraint requiring standard entries to be processed and serialized before option-space entries. | **Context / Data Model** configuration | Partial | Aligned | Aligned | None | Represents a trivial architecture gap, as -06 lacks multi-list serialization rules. |
| Syntactic Option representation | Representing options by decomposing them into delta, length, and value fields. | **field descriptors** in a C/D Rule | Direct | Aligned | Aligned | None | Decomposes one option into three standard field descriptors. |
| Semantic Option representation | Directly using protocol option numbers mapped in the rules. | **field descriptors** in a C/D Rule | Direct | Aligned | Aligned | None | Maps to standard field descriptors using a hierarchical Field ID. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Shared between S1 and S2 (peers) | Shared between two or more Instances in a Session | Aligned | Context consistency is maintained across the session. |
| Ownership of Set of Rules (SoR) | Part of the Context shared between S1 and S2 | Part of the Context shared by Instances | Aligned | Same rules are used for compression and decompression. |
| Ownership of Set of Variables (SoV) | Not applicable | Per-session/Instance runtime parameters | Not applicable | No impact on options representation. |
| Endpoint↔SCHC Instance | S1/S2 are compressing/decompressing nodes | Endpoint hosts one or more Instances | Aligned | S1 and S2 map to Instances on their respective Endpoints. |
| SCHC Instance↔Session | Communication relationship between S1 and S2 | Communication session between Instances | Aligned | S1 and S2 communicate in a Session. |
| Sharing of Context between Sessions/Instances | Shared between S1 and S2 | Shared across a Session / Domain | Aligned | Context sharing behaves identically. |
| RuleID scope | Unique within the shared rule set | Unique within a Context / Session | Aligned | Identifies the correct Rule in the Context. |
| Discriminator scope | Implicitly handles routing | Used by Dispatcher to route Datagrams to Instances | Not applicable | The draft does not define routing or dispatching. |
| Control Header processing scope | Not applicable | Parsed before/after RuleID | Not applicable | The draft does not use Control Headers. |
| Domain membership and boundaries | Shared management domain for S1/S2 | Group of Instances sharing Contexts | Aligned | Standard domain boundaries apply. |

## Challenged mappings
| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Entry Serialization Order | Profile-specific mechanism | Does the C/D engine need to guarantee residue order across multiple lists to interoperate? Yes, because if S1 and S2 serialize or parse residues in a different order, decompression fails. Thus, it cannot be left purely profile-specific without architectural recognition of order preservation when multiple lists are used. | Partial (representing an Architecture Gap) | Reclassified because the C/D engine's residue serialization must follow a deterministic order that matches the packet header sequence, and the architecture must mandate that Context transmission preserves this order to guarantee interoperability. |

## Architectural risk points
- **Risk:** Lack of standardized entry ordering and residue serialization constraints when multiple YANG lists are used.
  - **Why it matters:** YANG lists are unordered by default. If S1 and S2 retrieve rules from different repositories or via CORECONF, the lists may be reordered. If the C/D engine iterates through the lists in whatever order they are retrieved to serialize/deserialize residues, the residues will be misaligned, causing decompression failure.
  - **Consequence for migration:** The architecture must be updated to clarify that the serialization order of residues is independent of YANG schema representation and must follow a deterministic sequence (such as the order of fields in the physical packet, or standard entries first followed by option entries).

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 5.2 | `*This constraint should be documented in [I-D.ietf-lpwan-architecture] to ensure interoperability` | Change reference from `[I-D.ietf-lpwan-architecture]` to `draft-ietf-schc-architecture-06` and clarify the exact section (e.g., Section 4.2.1.2 on Context or Section 4.2.2.1 on C/D). | REQUIRED FOR TERMINOLOGY MIGRATION | The LPWAN architecture draft was renamed and has been updated to draft-ietf-schc-architecture-06. |
| 2 | Section 5.4.3 | `This requirement should be explicitly documented in [I-D.ietf-lpwan-architecture] to clarify that:` | Change reference from `[I-D.ietf-lpwan-architecture]` to `draft-ietf-schc-architecture-06` (or its Section 4.2.1.2). | REQUIRED FOR TERMINOLOGY MIGRATION | Alignment with current IETF draft names and numbering. |
| 3 | Figure 1 | `A <-------> S1 <~~~~~~> S2 <-----> B` and `rule management between two SCHC end-points` | Change "SCHC end-points" to "SCHC Instances" (or "SCHC Endpoints" hosting Instances) and update text to align with -06 terminology. | REQUIRED FOR TERMINOLOGY MIGRATION | In -06, C/D operations and context sharing occur between SCHC Instances on Endpoints. |
| 4 | Section 1, 2.1, 2.2, etc. | Use of `SCHC end-points` and `SCHC nodes` | Update to "SCHC Endpoints" or "SCHC Instances" to match -06 terminology. | REQUIRED FOR TERMINOLOGY MIGRATION | Terminology alignment. |
| 5 | Section 5.4.2 | `Deprecation of Predefined CoAP Option FIDs` | Deprecate predefined CoAP option FIDs in RFC 9363. | OPTIONAL CLARIFICATION | Good engineering practice to avoid duplicate representations, but doesn't change core compression logic. |
| 6 | Section 5.2 | `Fields from the standard “entry” list MUST be serialized before those defined in the new “entry-option-space” list` | Retain as is but make sure it is clearly stated. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Technical requirement for residue serialization consistency. |

## Needed modifications to SCHC Architecture -06
| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.1.2 (Context) | Context definition and rules | Does not specify how the order of field descriptors is maintained during transmission or when multiple lists are used in a data model. | Add a new paragraph: "When a Context is represented by a Data Model (such as [RFC9363]), the data model MUST specify a deterministic ordering for the list of field descriptors (entries) to ensure consistent residue serialization. If the data model represents field descriptors across multiple lists or structures, it MUST define the relative processing order of these structures. The order of field descriptors MUST be preserved when the Context is transmitted or synchronized between Endpoints." | ARCHITECTURE GAP | Essential to ensure that S1 and S2 compress and decompress residues in the exact same sequence when using the augmented YANG model. |
| 2 | Section 4.2.2.1 (C/D) | C/D engine residue serialization | "generates the compressed SCHC Datagram. In [RFC8724], a packet whose header has been compressed is called a SCHC Packet." | Add a clarification note: "The C/D engine MUST serialize and deserialize residues in the deterministic order specified by the Context's data model, ensuring that the alignment of residues in the SCHC Packet corresponds to the sequence of matched field descriptors." | ARCHITECTURE GAP | Ensures that the C/D engine logic matches the data model's serialization requirements. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? Yes
- Is the gap required for this draft or merely useful generally? Required for this draft to ensure interoperable rule exchange when using multiple YANG lists, but generally useful for any future data model extensions.
- What is the single most important migration issue? Ensuring that both the C/D engine implementation and the rule management protocols (CORECONF) strictly preserve the relative ordering of field descriptors across both the standard `entry` list and the augmented `entry-option-space` list.
