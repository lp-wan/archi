# Evidence Notes: draft-ietf-schc-universal-option-01

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

The Static Context Header Compression (SCHC) Architecture -06 can naturally express the concepts, relationships, and assumptions of `draft-ietf-schc-universal-option-01`. The principal conceptual mapping involves treating the hierarchical option representation (composed of a `space-id` and an `option-id`) as a composite Field Identifier within a Rule's field descriptor in the Context/Data Model. The main migration difficulty lies in updating references from the old architecture draft (`[I-D.ietf-lpwan-architecture]`) to `draft-ietf-schc-architecture-06` and performing minor mechanical updates to terminology (e.g., replacing "end-point" with "Endpoint"/"Instance" and "Rule management" with "Context management"). A trivial architecture gap exists because the current -06 text lacks explicit guidelines on preserving field descriptor ordering and residue serialization sequences when a Context is represented by multiple lists in a data model (like `entry` and `entry-option-space`). This gap is easily resolved by adding minor clarifications to the Context and C/D engine specifications in the architecture.

### Architectural risk points

- **Risk:** Lack of standardized entry ordering and residue serialization constraints when multiple YANG lists are used.
  - **Why it matters:** YANG lists are unordered by default. If S1 and S2 retrieve rules from different repositories or via CORECONF, the lists may be reordered. If the C/D engine iterates through the lists in whatever order they are retrieved to serialize/deserialize residues, the residues will be misaligned, causing decompression failure.
  - **Consequence for migration:** The architecture must be updated to clarify that the serialization order of residues is independent of YANG schema representation and must follow a deterministic sequence (such as the order of fields in the physical packet, or standard entries first followed by option entries).

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 5.2 | `*This constraint should be documented in [I-D.ietf-lpwan-architecture] to ensure interoperability` | Change reference from `[I-D.ietf-lpwan-architecture]` to `draft-ietf-schc-architecture-06` and clarify the exact section (e.g., Section 4.2.1.2 on Context or Section 4.2.2.1 on C/D). | REQUIRED FOR TERMINOLOGY MIGRATION | The LPWAN architecture draft was renamed and has been updated to draft-ietf-schc-architecture-06. |
| 2 | Section 5.4.3 | `This requirement should be explicitly documented in [I-D.ietf-lpwan-architecture] to clarify that:` | Change reference from `[I-D.ietf-lpwan-architecture]` to `draft-ietf-schc-architecture-06` (or its Section 4.2.1.2). | REQUIRED FOR TERMINOLOGY MIGRATION | Alignment with current IETF draft names and numbering. |
| 3 | Figure 1 | `A <-------> S1 <~~~~~~> S2 <-----> B` and `rule management between two SCHC end-points` | Change "SCHC end-points" to "SCHC Instances" (or "SCHC Endpoints" hosting Instances) and update text to align with -06 terminology. | REQUIRED FOR TERMINOLOGY MIGRATION | In -06, C/D operations and context sharing occur between SCHC Instances on Endpoints. |
| 4 | Section 1, 2.1, 2.2, etc. | Use of `SCHC end-points` and `SCHC nodes` | Update to "SCHC Endpoints" or "SCHC Instances" to match -06 terminology. | REQUIRED FOR TERMINOLOGY MIGRATION | Terminology alignment. |
| 5 | Section 5.4.2 | `Deprecation of Predefined CoAP Option FIDs` | Deprecate predefined CoAP option FIDs in RFC 9363. | OPTIONAL CLARIFICATION | Good engineering practice to avoid duplicate representations, but doesn't change core compression logic. |
| 6 | Section 5.2 | `Fields from the standard “entry” list MUST be serialized before those defined in the new “entry-option-space” list` | Retain as is but make sure it is clearly stated. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Technical requirement for residue serialization consistency. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.1.2 (Context) | Context definition and rules | Does not specify how the order of field descriptors is maintained during transmission or when multiple lists are used in a data model. | Add a new paragraph: "When a Context is represented by a Data Model (such as [RFC9363]), the data model MUST specify a deterministic ordering for the list of field descriptors (entries) to ensure consistent residue serialization. If the data model represents field descriptors across multiple lists or structures, it MUST define the relative processing order of these structures. The order of field descriptors MUST be preserved when the Context is transmitted or synchronized between Endpoints." | ARCHITECTURE GAP | Essential to ensure that S1 and S2 compress and decompress residues in the exact same sequence when using the augmented YANG model. |
| 2 | Section 4.2.2.1 (C/D) | C/D engine residue serialization | "generates the compressed SCHC Datagram. In [RFC8724], a packet whose header has been compressed is called a SCHC Packet." | Add a clarification note: "The C/D engine MUST serialize and deserialize residues in the deterministic order specified by the Context's data model, ensuring that the alignment of residues in the SCHC Packet corresponds to the sequence of matched field descriptors." | ARCHITECTURE GAP | Ensures that the C/D engine logic matches the data model's serialization requirements. |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? Yes
- Is the gap required for this draft or merely useful generally? Required for this draft to ensure interoperable rule exchange when using multiple YANG lists, but generally useful for any future data model extensions.
- What is the single most important migration issue? Ensuring that both the C/D engine implementation and the rule management protocols (CORECONF) strictly preserve the relative ordering of field descriptors across both the standard `entry` list and the augmented `entry-option-space` list.

## analysis-claude
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

SCHC Architecture -06 can naturally express draft-ietf-schc-universal-option-01. The draft is, architecturally, a Data-Model document: it extends the RFC 9363 YANG model with an `entry-option-space` list keyed by a protocol namespace (`space-id`) and the protocol's native option identifier (`option-id`), so that Rules can describe options unknown to the deployed implementation. Everything below the Rule boundary (FID, space-id, option-id, entries, TV/MO/CDA, SIDs, CBOR, CORECONF) sits at a granularity that -06 deliberately delegates to the Data Model named in the Context's metadata — a natural, defined use of the -06 Context concept, not an escape hatch.

The principal conceptual mapping is: the draft's "SCHC endpoint / SCHC node" (S1, S2) → an -06 Endpoint hosting an Instance, the communicating pair forming a Session; the draft's "Rules they share" → a shared Context (Set of Rules); the draft's "rule mngt" between endpoints → Context management/synchronization (Domain Manager function or an Instance-executed dynamic Context update, both of which -06 provides).

The principal migration difficulty is small: resolving the overloaded "endpoint" per occurrence and redirecting the two references to the obsolete [I-D.ietf-lpwan-architecture] to the -06 architecture.

An architecture gap exists but is Trivial: -06 must state explicitly, in its Context-consistency considerations, that entry order within a Rule is part of the Context and is preserved by Context distribution and synchronization (residue serialization depends on it). This is exactly the statement the draft asks the architecture to carry. The corresponding edit is proposed in `schc-architecture-edits.md`.

### Architectural risk points

- **Risk:** Run-time Rule derivation vs. the static-Context foundation. The draft's scenario (S1 derives a new Rule and communicates it to S2) must be expressed as a management-plane Context update; -06 explicitly retains RFC 8724's assumptions that the Context is provisioned before use and that *no negotiation takes place between the compressing and decompressing entities*, while permitting dynamic Context update mechanisms.
  **Why it matters:** If the draft (or a successor) were read as requiring in-band Rule negotiation between the communicating Instances, it would collide with a stated foundation of -06 rather than a peripheral detail.
  **Consequence for migration:** The migrated text should frame Rule derivation and installation as Context management (Domain Manager or authorized dynamic update), which the current draft text supports; no technical change is needed, but the framing must be deliberate.

- **Risk:** Silent reordering of entries during Context synchronization. YANG lists are unordered unless marked "ordered-by user"; a management pipeline (CORECONF store, intermediate tooling) could legally reorder entries, changing residue interpretation without any visible Context mismatch.
  **Why it matters:** Both Instances would believe they hold "the same Context" (same entries, same keys) yet decompress incorrectly — a failure -06's current Context-consistency text does not warn against.
  **Consequence for migration:** Requires the Trivial -06 clarification (entry order is part of the Context) plus the draft's own "ordered-by user" requirement on the Data Model; with both in place the risk is closed.

- **Risk:** Overloaded "endpoint". The draft's "SCHC endpoint" denotes at different moments the -06 Endpoint (the hosting entity), the Instance (the executing entity), and the implementation.
  **Why it matters:** A mechanical one-word replacement would either imply one Instance per Endpoint (an unstated 1:1 constraint -06 does not have) or misattribute per-Session processing obligations (entry ordering binds the *Instances of a Session*, not physical nodes).
  **Consequence for migration:** Each occurrence must be resolved individually (done in File 3); this is the main reason Transition difficulty is Easy rather than Very Easy.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §1, goals bullet | "Simplify Rule management between SCHC endpoints" | "Simplify Rule and Context management between SCHC Endpoints" | REQUIRED FOR TERMINOLOGY MIGRATION | Use -06 capitalized terms; Rule management is Context management in -06 |
| 2 | §2.2, first paragraph and Figure 1 caption | "rule management between two SCHC endpoints" / "Rule Management between two SCHC end-points" | "Rule management between two SCHC Endpoints whose Instances share a Context" / caption "Rule Management between two SCHC Endpoints" | REQUIRED FOR TERMINOLOGY MIGRATION | Resolve "end-point" into -06 Endpoint/Instance model |
| 3 | §2.2, scenario bullet | "SCHC nodes S1 and S2 compress and decompress the traffic using Rules they share." | "SCHC Endpoints S1 and S2 each host a SCHC Instance; the two Instances compress and decompress the traffic within a Session, using a shared Context (Set of Rules)." | REQUIRED FOR TERMINOLOGY MIGRATION | Map "Rules they share" to the -06 Context/Session model; local rewrite, semantics unchanged |
| 4 | §2.2, problem bullet | "how to identify this new option in the Rule and communicate this identifier to S2" | "…so that, when the updated Context is distributed to S2 (e.g., by the Domain Manager or a dynamic Context update mechanism), S2 can understand which option is involved…" | REQUIRED FOR TERMINOLOGY MIGRATION | Frames Rule communication as Context distribution/update per -06, preserving the draft's ambiguity about the managing entity |
| 5 | §2.3, second bullet | "making Rule exchange between them problematic" | "making the exchange of Rules (Context synchronization) between them problematic" | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns "Rule exchange" with the -06 Context-synchronization concept |
| 6 | §3.3, advantages paragraph | "enabling different SCHC implementations to exchange rules for any option" | "enabling different SCHC implementations to exchange Rules (synchronize Contexts) for any option" | REQUIRED FOR TERMINOLOGY MIGRATION | Same as #5 |
| 7 | §5.2 | "both SCHC endpoints must process entries in the same order" | "all Instances participating in a Session must process entries in the same order" | REQUIRED FOR TERMINOLOGY MIGRATION | The obligation binds the Instances of a Session in -06 terms; also generalizes correctly to N>2 |
| 8 | §5.2 | "*This constraint should be documented in [I-D.ietf-lpwan-architecture] to ensure interoperability" | "This constraint is stated in the Context consistency considerations of [I-D.ietf-schc-architecture]: the order of entries is part of the Context and is preserved by Context distribution and synchronization." | REQUIRED FOR TERMINOLOGY MIGRATION | Redirects the obsolete architecture reference to -06 §6.2 (assumes the Trivial edit of `schc-architecture-edits.md` is accepted) |
| 9 | §5.3, third bullet | "It allows for cleaner Rule exchange between SCHC endpoints" | "It allows for cleaner Rule exchange between SCHC Endpoints (Context synchronization within a Domain)" | REQUIRED FOR TERMINOLOGY MIGRATION | -06 terms; names the Domain scope of Context sharing |
| 10 | §5.4.3 | "When transmitting Rules from one endpoint to another, the order of Field Descriptors must be preserved" | "When a Context is distributed or synchronized between Instances, the order of Field Descriptors must be preserved" | REQUIRED FOR TERMINOLOGY MIGRATION | Rule transmission = Context distribution/synchronization in -06 |
| 11 | §5.4.3 | "This requirement should be explicitly documented in [I-D.ietf-lpwan-architecture] to clarify that:" and "The order of entries should not be changed when transmitted between endpoints" | Reference redirected to [I-D.ietf-schc-architecture]; "…when a Context is transmitted between Endpoints" | REQUIRED FOR TERMINOLOGY MIGRATION | Same as #8; normative strength ("should not") preserved |
| 12 | §5.4.3, second bullet | "must be processed in a consistent sequence across all implementations" | "must be processed in a consistent sequence across all Instances" | REQUIRED FOR TERMINOLOGY MIGRATION | Precision: the processing entity is the Instance |
| 13 | §6.2, Informative References | [I-D.ietf-lpwan-architecture] (draft-ietf-lpwan-architecture-02, 2022) | Replace with [I-D.ietf-schc-architecture] (draft-ietf-schc-architecture-06) | REQUIRED FOR TERMINOLOGY MIGRATION | The referenced document is superseded by the document under comparison |
| 14 | §2.2 scenario | Two-endpoint example presented without qualification | Add a sentence noting the topology is illustrative and the mechanism applies equally when a Context is shared by more than two Instances or across multiple Sessions | OPTIONAL CLARIFICATION | Prevents readers inferring a 2-party constraint; not required for migration |
| 15 | §5.1 | "values provided by the SCHC Working Group" (space-id) | Clarify the allocation mechanism (e.g., IANA registry established by the 9363 revision) | OPTIONAL CLARIFICATION | Identifier-authority precision; not architecture-related |
| 16 | Running header | "Internet-Draft SCHC for CoAP" | "Internet-Draft SCHC Universal Options" (or similar) | EDITORIAL | Header inherited from another document |
| 17 | Appendix A, module description | Description text speaks of "compound-ack behavior for Ack On Error" / "RFC YYYY: OAM" | Replace with a description of the option-space augmentation | EDITORIAL | Copy-paste from an unrelated module; misleading but not architectural |
| 18 | Appendix A, identity space-id-coap | description "Field ID base type for IPv6 headers described in RFC 8200" | Describe as the CoAP option space (RFC 7252) | EDITORIAL | Wrong description/reference on a key identity |
| 19 | §5.1 / Appendix D title / §D.4 | "diffently", "Syntatic", "minize", "fith" | Spelling fixes | EDITORIAL | Typos |
| 20 | Appendix A, organization/contact | lpwan WG name and list | Update to the SCHC WG | EDITORIAL | Stale metadata |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §6.2 Context consistency | Context / Set of Rules — order of Field Descriptors within a Rule | §6.2 recommends deploying "the same Context (with identical SoR)" and discusses compatible partial Contexts; nothing states that the order of entries within a Rule is part of the Context or must survive Context distribution | Add one paragraph stating that the order of the Field Descriptors (entries) within a Rule is part of the Context; that residue serialization follows that order; that Context distribution and synchronization must preserve it; and that when a Rule representation contains several lists of entries (e.g., a Data Model and its augmentations), the Context must define a single deterministic processing order (exact text in `schc-architecture-edits.md`) | ARCHITECTURE GAP | The draft normatively points to the architecture for exactly this statement (§5.2, §5.4.3); the relationship is implied by "identical SoR" but a YANG-based Context store may legally reorder entries, so the implication is insufficiently explicit. Additive clarification only — no existing text changes meaning |
| 2 | §3 Terminology, "Context" | Context metadata | "Metadata may, for example, refer to a data model or a parser compatible with the rule format." | Optionally extend the example list with "or the ordering conventions for the entries of a Rule" | OPTIONAL CLARIFICATION | Convenience cross-link only; item 1 alone closes the gap |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (a handful of sentence-level rewrites; all mapping decisions clear and repeatable)
- Does the draft expose a SCHC Architecture -06 gap? **Yes** (Trivial: entry-order preservation as part of Context consistency)
- Is the gap required for this draft or merely useful generally? **Required for this draft** — the draft explicitly directs the architecture to document the ordering constraint, so migration cannot complete cleanly without a landing place in -06; the clarification is additionally useful for any Data-Model-based Context distribution
- What is the single most important migration issue? Redirecting the draft's two interoperability pointers from the obsolete [I-D.ietf-lpwan-architecture] to -06's Context-consistency model, which first requires -06 to state explicitly that entry order within a Rule is part of the shared Context.
