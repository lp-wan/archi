# Evidence Notes: draft-ietf-6lo-schc-15dot4-13

## analysis-gemini
Verdicts: {'conceptual': 'High', 'transition': 'Medium', 'adaptation': 'Trivial'}

### Executive assessment

Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express almost all of the technical behaviors, protocol stacks, and deployment configurations of the draft under study (`draft-ietf-6lo-schc-15dot4-13`). The principal conceptual mapping translates the draft's "SCHC Data end point" to an -06 "SCHC Instance", and the draft's "SCHC Control Header end point" to a combination of -06's Dispatcher and Instance configurations. The network-wide single or multiple endpoint models map to profile-specific configurations of the Dispatcher and Instance counts.

The principal migration difficulty lies in resolving the non-standard terminology of "end points" (used as two words in the draft to represent Instances or Sessions) to match -06's strict separation between "Endpoint" (logical host) and "Instance" (processing entity). Furthermore, architectural framing is needed to represent the nested multiple Strata in the transition protocol stacks and the role of intermediate routers in PRO.

An architectural gap exists in -06 regarding the Pointer-based Route-Over (PRO) mode, where intermediate nodes (6LRs) inspect and modify the compressed packet residue without possessing the Session Context. This gap is classified as **Trivial** and is resolved by proposing a minor additive clarification to Section 4.2.5.1 of -06, allowing a Control Header to contain pointers to residues for intermediate node operations.

### Architectural risk points

- **Risk: PRO Layering Violation and Residue Modification**
  - **Why it matters**: In Pointer-based Route-Over (PRO), intermediate routers (6LRs) must parse the PRO Header and locate specific field residues (Hop Limit and Destination Address) inside the SCHC Datagram residue using a Bit Pointer. This requires 6LRs to inspect and modify the compressed payload of the adaptation layer, coupling the network routing plane directly with the bit-level layout of the compressed packet's residue. It violates the end-to-end opacity of the SCHC Datagram.
  - **Consequence for migration**: Migration requires coordinating the Rule design on the endpoints (which must Swap source/destination descriptors to place the destination address at a predictable offset in the residue) with the routing logic on the 6LRs. If the Rule layout changes, the Bit Pointer logic must be updated, increasing the risk of routing failures.
- **Risk: Overloaded "end point" Terminology**
  - **Why it matters**: The draft uses the term "end point" (two words) to refer to the C/D Instances or Dispatcher targets (e.g. "SCHC Data end point", "SCHC Control Header end point") and refers to "Single-end point networks" and "Multiple-end point networks". However, SCHC Architecture -06 defines "Endpoint" (one word) as a logical host entity that can contain multiple Instances. Citing -06 while using mismatched terminology will confuse implementers and spec authors.
  - **Consequence for migration**: The draft must be carefully edited to replace "end point" with "Instance" or "Dispatcher" when referring to processing components, and reserve "Endpoint" for the logical host entity, to ensure clear alignment with -06.
- **Risk: Implicit Role Assignment in Mesh Topologies**
  - **Why it matters**: SCHC C/D relies on asymmetric roles (Dev and App) for Rule matching and compression. In a mesh topology (P2P), nodes have equal capabilities, meaning roles cannot be derived from network topology. The draft states that each C/D entity must know its role before communication occurs, but leaves the exact mechanism out of scope, relying on "prior knowledge".
  - **Consequence for migration**: If peer nodes in a mesh network disagree on their roles (e.g. both assume they are the "Dev" or both "App" for a shared Rule), header decompression will fail. A clear role negotiation or assignment mechanism must be defined.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3.2, 3.2.1, 3.2.2, 3.2.3 | "SCHC Data end point", "SCHC Control Header end point" | Rename "SCHC Data end point" to "SCHC Data Instance" or "SCHC Instance", and "SCHC Control Header end point" to "SCHC Control Header Instance" or "Dispatcher context". | REQUIRED FOR TERMINOLOGY MIGRATION | To align with SCHC Architecture -06, which defines "Endpoint" as the logical host and "Instance" as the C/D processing component. |
| 2 | Section 3.2.2, 3.2.3 | "Single-end point networks", "Multiple-end point networks" | Rename to "Single-Instance networks" and "Multiple-Instance networks" (or "Single-Instance Domains" and "Multiple-Instance Domains"). | REQUIRED FOR TERMINOLOGY MIGRATION | To align with -06, as the distinction is based on the number of Instances hosted per Endpoint, not the number of Endpoints. |
| 3 | Section 6.1 (paragraph 4) | "the Field Descriptors of the IPv6 destination address... MUST appear before the Field Descriptors of the IPv6 source address" | Reframe this as a profile-specific constraint on the Rule design for PRO, rather than a general update to RFC 8724. | REQUIRED FOR CONCEPTUAL ALIGNMENT | RFC 8724 mandates that Field Descriptors appear in the order they exist in the header. Changing this globally violates RFC 8724; it should be constrained only to Contexts used with PRO. |
| 4 | Section 3.5.2 & 3.5.3 | Implicit Instance allocation on 6LBR (root). | Explicitly state that the 6LBR (root) hosts multiple SCHC Instances, each participating in a Session with a specific 6LN. | OPTIONAL CLARIFICATION | Clarifies the cardinality of Instances and Sessions on the root node to align with the -06 model. |
| 5 | Section 12.1 | `[I-D.ietf-schc-architecture]` citation to version -05. | Update reference to point to `draft-ietf-schc-architecture-06`. | EDITORIAL | To reference the current and correct version of the architecture draft. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.5.1 (Control Header for Advanced Use Cases) | Control Header | Currently describes Control Header services as: Multiplexing, Protection, Metadata. | Add a new bullet point: "* Routing/inspection pointers: carry pointers (e.g. Bit Pointers) to locate specific fields or residues within the Datagram, allowing intermediate routing nodes to inspect or modify these fields without possessing the Session's decompression Context." | ARCHITECTURE GAP | Required to naturally express and validate the PRO (Pointer-based Route-Over) forwarding model defined in the draft under study. |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **No**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft's PRO mode, but useful generally for other pointer-based routing profiles.**
- What is the single most important migration issue? **The alignment of the draft's "end point" terminology with -06's "Instance/Endpoint" model, and the conceptual framing of the PRO pointer-based residue modification within -06's end-to-end Session model.**

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

SCHC Architecture -06 **can naturally express** draft-ietf-6lo-schc-15dot4-13. The draft was written against architecture **-05** and already builds on architecture vocabulary (SCHC Stratum, Discriminator, SCHC Control Header, SCHC Datagram, SoR); its wire formats, storage requirements, and the SRO/TRO/PRO/Mesh-Under modes carry over unchanged.

The **principal conceptual mapping** is the decomposition of the -05 term family the draft still uses: a node's "SCHC Data end point" maps to an -06 **Instance with its Context (SoR)**; the group of end points that "share a Rule" (the E1/E2 identifiers in Figures 9/11/14/16) maps to **Instances sharing a Context, communicating within a Session**; "Single/Multiple-end point networks" map to deployments where Endpoints host **one vs. several Instances**; the "SCHC Control Header end point" reduces to the profile-defined **SoR used for Control Header C/D**, exactly as -06 4.2.5.1 requires (decodable before any Context-dependent part). The draft's compressed Control Header design coincides with -06 Appendix A.1 almost verbatim.

The **principal migration difficulty** is bounded and local: rewriting Section 3.2 around Instances, disambiguating the overloaded word "end point", and rewording the "SCHC Instance ID" definition, which currently conflates the -06 notions of Instance, Session, and Context identifier.

An **Architecture gap exists but is Trivial**: -06 should (1) state that an Instance's Role may be determined per Session, and (2) define Context "compatibility" as scoped to the Rules used within a Session. Both are additive clarifications proposed in `schc-architecture-edits.md`.

### Architectural risk points

- **Risk:** PRO lets Context-free on-path nodes read and *modify* bits inside the compression residue (Hop Limit, ECN) of a SCHC Datagram.
  **Why it matters:** -06's implicit model is that Datagram content between Instances is interpreted only via the shared Context; PRO's safety rests entirely on profile-imposed Rule-design constraints (destination-fields-first ordering, no match-mapping for destination fields, one Rule per direction). If a future architecture revision asserted Datagram immutability or Context-only interpretation, PRO would conflict.
  **Consequence for migration:** The migrated text must present PRO 6LR behavior as operation on profile-defined framing, not as SCHC processing by an Instance; no architecture change is required today, but the framing must be kept explicit.

- **Risk:** In PRO/Mesh-Under Single-Instance networks, correctness of RuleID interpretation depends on delivery guarantees (routing on the destination residue / Mesh originator address), not on Context agreement.
  **Why it matters:** A misrouted, multicast, or spoofed Datagram carrying a reused RuleID would be decompressed with the wrong Rule with no architectural detection; -06's Context-consistency section does not contemplate deliberate cross-Session RuleID collisions.
  **Consequence for migration:** Expressible once compatibility is defined as Session-scoped (File 2, Edit 2); the residual risk is a property of the draft's design, to be kept visible in its Security Considerations, not a mapping failure.

- **Risk:** The "SCHC Instance ID" field name vs. its "identifies the session" definition.
  **Why it matters:** -06 distinguishes Instance ID, Session ID, and Context ID, all usable as Control-Header multiplexing content; keeping the conflated definition would import an ambiguity into -06 vocabulary and could mislead implementers about what must be unique where.
  **Consequence for migration:** One REQUIRED FOR CONCEPTUAL ALIGNMENT rewording (kept as Instance-selecting, matching -06 A.1); no wire-format change.

- **Risk:** SRO's in-flight decompression/recompression leaves Session membership of routers implicit.
  **Why it matters:** Whether a forwarding router is a participant of the A↔B Session or terminates per-hop Sessions affects, in principle, where per-Session state (SoV, Role) would live. Because this profile uses stateless C/D only and no SCHC F/R, the choice has no operational consequence here, but it would surface if SCHC F/R were later allowed end-to-end.
  **Consequence for migration:** No text change strictly required; an optional clarification in the draft avoids future ambiguity.

- **Risk:** Assignment and uniqueness scope of the SCHC Instance ID are unstated (management is out of scope).
  **Why it matters:** -06 requires Instance/Context/Session identifiers to be unique within their Domain; the draft neither names a Domain nor an assigner.
  **Consequence for migration:** Preserved as an explicit provisioning assumption (already out of scope in the draft); no mapping failure, but the migrated text should not accidentally claim Domain-wide management that the draft does not provide.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §4.1.2 | "This field is an unsigned integer that identifies the session between SCHC end points in two or more peer nodes using a common SoR." | "This field is an unsigned integer that identifies the SCHC Instance, and thus the Context, that applies to the SCHC Data. The Instances of two or more peer nodes that share that Context (and thus a common SoR) within a Session use the same SCHC Instance ID value." | REQUIRED FOR CONCEPTUAL ALIGNMENT | The current sentence conflates -06 Instance, Session, and Context selection; the mechanism is -06 A.1's Instance-ID multiplexing and must be stated as such |
| 2 | §3.2.2, §3.2.3 | Single/Multiple-end point networks defined via "SCHC Data end point" and "SCHC Control Header end point" (concepts absent from -06) | Redefine as Single-Instance / Multiple-Instance networks: each node hosts one vs. several SCHC Instances, each Instance with its Context (SoR); the Control-Header SoR is stated directly, without an "end point" entity | REQUIRED FOR CONCEPTUAL ALIGNMENT | The -05 end-point entity model must be re-expressed through the -06 Instance/Context decomposition; behavior unchanged |
| 3 | §3.2 intro | Concept list citing "SCHC Control Header end point", "SCHC Data end point" to the architecture | Cite the -06 concepts actually used: Endpoint, Instance, Session, Context, SoR, Stratum, Discriminator | REQUIRED FOR TERMINOLOGY MIGRATION | -06 does not define the -05 terms |
| 4 | §3.5.1–3.5.4 text and Figures 8–16 (captions, "Nodes \| End point" columns, E1/E2 narrative) | "SCHC Data end point called E1", "SCHC Datagram Instance called E1", "same end point identifier ... for two end points that share a Rule", "Single-/Multiple-end point network" | "SCHC Instance (and its Context) denoted E1"; "the same identifier ... for the Instances of different nodes that share a Context"; rename network classes; column header "Instance" | REQUIRED FOR TERMINOLOGY MIGRATION | Uniform application of the mapping; also fixes the internal drift ("SCHC Datagram Instance") |
| 5 | §3.4, §3.5, §3.5.2, App. A.2/A.3 | "endpoints"/"endpoint" used for communicating nodes ("between those two endpoints", "involve the 6LR itself as an endpoint") | "nodes" / "as a communicating node" | REQUIRED FOR TERMINOLOGY MIGRATION | Avoids collision with -06 "Endpoint" (a logical SCHC entity) |
| 6 | §4.1.2, §4.1.3 | "determines the SCHC Data end point to be used to decompress"; "compressed by using a SCHC Data end point" | "identifies the SCHC Instance, and thus the Context, to be used to decompress"; "compressed by a SCHC Instance" | REQUIRED FOR TERMINOLOGY MIGRATION | Same mapping |
| 7 | §5 | "SCHC may also need a Discriminator to identify the SoR to be used for header decompression" | "...a Discriminator, used by the Dispatcher to select the appropriate SCHC Instance, and thus the Context (with its SoR)..." | REQUIRED FOR TERMINOLOGY MIGRATION | -06 Discriminator selects the Instance; the SoR follows from it |
| 8 | §5.1, §5.2 (incl. Figures 30–36 labels and notes) | "SCHC Stratum end point", "SoR of the SCHC Stratum end point", figure label "SCHC Stratum Header" | "the Instance at that SCHC Stratum", "SoR of the Instance at that SCHC Stratum", label "SCHC Control Header" | REQUIRED FOR TERMINOLOGY MIGRATION | Removes the -05 end-point term and the draft-internal "Stratum Header"/"Control Header" inconsistency |
| 9 | §6.1, §6.2 | "each SCHC C/D entity needs to know its role (Dev or App) ... for each node it communicates with" | "each SCHC Instance needs to know its role (Dev or App), for each Session it participates in, ..." | REQUIRED FOR TERMINOLOGY MIGRATION | Maps to the -06 Role (per Session, per File 2 Edit 1); the per-peer requirement is unchanged |
| 10 | §3.5.4 | "determine the SCHC Data end point needed to decompress ... based on the packet's originator address" | "determine the SCHC Instance (and thus the Context) ... ; in that case, the originator address is used as a Discriminator" | REQUIRED FOR TERMINOLOGY MIGRATION | Names the -06 mechanism already in use |
| 11 | §12.1 and all citations | Normative reference `draft-ietf-schc-architecture-05`; inline cites `[draft-ietf-schc-architecture]`, `[draft-ietf-schc-arch]` | Reference -06; unify inline citations to `[I-D.ietf-schc-architecture]` | REQUIRED FOR TERMINOLOGY MIGRATION | The migration target is -06 |
| 12 | §3.5.1 | "all nodes in the SCHC-Lo network MAY share the same SoR" | Add: "(i.e., their Instances share a common Context and form a single Domain)" | OPTIONAL CLARIFICATION | Makes the natural Domain mapping of the SRO shared-SoR case explicit |
| 13 | §3.5.3 | PRO 6LR behavior (reads/edits residue without Rules) | Add a note that PRO 6LRs operate on the PRO Header framing and the pointer-designated bit ranges, and are not SCHC Instances | OPTIONAL CLARIFICATION | Prevents misreading PRO routers as SCHC processing entities |
| 14 | §3.5.3 / §3.5.4 | RuleID reuse across disjoint pairs | Add a pointer to Context compatibility per Session (Section 6.2 of the architecture, as clarified) | OPTIONAL CLARIFICATION | Anchors the reuse feature to the architectural notion that legitimizes it |
| 15 | §8 | 6LoWPAN F/R used instead of SCHC F/R | Optionally note that, in -06 terms, the Instance Configuration Manifest includes C/D only | OPTIONAL CLARIFICATION | Explicit but derivable |
| 16 | §4.1.1 | "a SCHC Sratum header ('SCHC Hdr' in Figure 17...))" | "a SCHC Control Header ('SCHC Hdr' in Figure 17...)" — fixes the typo, the wrong term, and the doubled parenthesis | EDITORIAL | "Sratum" is a typo and the field in question is the Control Header |
| 17 | §3.5 | "Straightfoward Route-Over" | "Straightforward Route-Over" | EDITORIAL | Typo |
| 18 | §3.5.4, Figure 16 narrative | "the Rules that need to be stored by the nodes in PRO" | "...in Mesh-Under" | EDITORIAL | The paragraph describes Figure 16, a Mesh-Under example |
| 19 | §3.2.3 first line | "In Multiple-endpoint networks" | Consistent class name | EDITORIAL | Internal consistency (subsumed by #2/#4) |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | 4.2.1.1 (Instance Configuration — Role) | Role of the Instance | Role is listed as an Instance Configuration parameter ("Role of the Instance (e.g., Upside or Downside...)"); per-Session role is only implied ("all Instances of a Session are aware of their role") and the Role model is deferred to future work (B.2) | Add a paragraph stating that when an Instance participates in several Sessions, its Role may differ per Session, and the role-determination method must make each Instance aware of its role in each Session | ARCHITECTURE GAP (Trivial) | draft-ietf-6lo-schc-15dot4 §6.1/§6.2 requires a node to know its Dev/App role *per peer* while hosting a single Instance; without the clarification, expressing this needs one Instance per peer, which the draft's Single-Instance model contradicts |
| 2 | 6.2 (Context consistency) | Compatible Contexts / "share a common Context" | "...it is possible for one or more Instances to have only a subset of the SoR, as long as the Contexts of the Instances participating in a given session remain compatible." — "compatible" is undefined and only the subset case is illustrated | Define compatibility as scoped to the Session: Contexts are compatible for a Session when every Rule used within it is bound to the same RuleID and definition in each participant's Context; RuleIDs may denote unrelated Rules in Contexts of Instances that share no Session, provided the deployment guarantees delivery only to holders of the Rule used | ARCHITECTURE GAP (Trivial) | Required to naturally express PRO/Mesh-Under RuleID reuse across disjoint peer pairs (draft §3.5.3/§3.5.4), where per-node Contexts are overlap-divergent, not subsets |
| 3 | 4.2.5 (Datagram Format) / Terminology | Datagram vs. Payload | "It may be followed by a Payload." alongside "A Datagram may be an unfragmented SCHC Packet" (a SCHC Packet includes the payload) | Optionally state explicitly that the Payload, when present, is part of the Datagram | OPTIONAL CLARIFICATION (not a gap) | The draft's figures bracket the user payload inside the SCHC Datagram; the -06 text already supports this reading via the SCHC Packet equivalence — clarification only improves explicitness |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes** — every change is terminological or a conceptual reformulation; no wire format, storage requirement, or normative behavior changes.
- Can the migration be performed mechanically? **Mostly** — four mapping decisions (end point → Instance/Context/Session; Instance ID semantics; network-class renaming; "endpoint" disambiguation) must be made once, after which application is repetitive; Section 3.2 needs rewritten prose rather than substitution.
- Does the draft expose a SCHC Architecture -06 gap? **Yes** — a Trivial one (two additive clarifications: per-Session Role; Session-scoped Context compatibility). See `schc-architecture-edits.md`.
- Is the gap required for this draft or merely useful generally? **Required for this draft** (per-peer Dev/App roles in mesh topologies, §6.1/§6.2; RuleID reuse across disjoint pairs, §3.5.3/§3.5.4), and also generally useful for any peer-to-peer or mesh SCHC deployment.
- What is the single most important migration issue? **Replacing the -05 "SCHC Data end point / SCHC Control Header end point" concept family with the -06 Instance/Context/Session decomposition — in particular the "SCHC Instance ID" field, whose current definition ("identifies the session ... using a common SoR") conflates what -06 separates and must be reworded to the Instance-selecting semantics of -06 Appendix A.1.**
