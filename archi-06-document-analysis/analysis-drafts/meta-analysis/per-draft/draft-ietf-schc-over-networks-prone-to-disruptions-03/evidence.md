# Evidence Notes: draft-ietf-schc-over-networks-prone-to-disruptions-03

## analysis-gemini
Verdicts: {'conceptual': 'Medium', 'transition': 'Medium', 'adaptation': 'Significant'}

### Executive assessment

SCHC Architecture -06 can only partially express the concepts and technical model of [draft-ietf-schc-over-networks-prone-to-disruptions-03](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-over-networks-prone-to-disruptions-03.txt). While the basic cellular Zero Energy (ZE) topologies and LPWA caching/timer behaviors map naturally to -06, the draft introduces two key concepts that cannot be naturally expressed without architectural stretching or modification.

The principal conceptual mapping is:
- **Zero Energy Device (Dev) / DtS-IoT End-device** → [Endpoint](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L195-L199) hosting a [SCHC Instance](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L201-L205).
- **Operator Platform / SCHC Gateway** → Network [Endpoint](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L195-L199) hosting a peer [Instance](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L201-L205).
- **Latency-Mapping Profiles** → [Rules](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L207) with varying timer and window variables within the [Set of Rules (SoR)](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L212-L214) of the shared [Context](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt#L215-L218).
- **LEO Satellite as SCHC Proxy** → **Missing/Gap** (an intermediate node performing segment-level F/R actions without terminating the Session or reassembling the packet is not defined in -06).
- **Payload Compression (SenML)** → **Partial/Gap** (using C/D on structured application payloads rather than protocol headers).

The principal migration difficulty is recharacterizing the LEO Satellite SCHC Proxy and the payload compression within -06's end-to-end Session and header-centric terminology. Migrating the draft requires significant architectural judgment to address the split-session F/R behavior and its associated data loss risks.

An Architecture gap exists. The most significant gap is the lack of intermediate nodes or proxies that participate in the F/R state machine (sending local ACKs/retransmissions) without terminating the C/D Session or reassembling the packet. Expressing this requires a Significant adaptation of -06 to define a Proxy or Split-Session role. There is also a Trivial gap regarding payload compression, as -06's definition of C/D is strictly limited to headers.

### Architectural risk points

- **Risk:** Split-Session Fragmentation Reliability (LEO Satellite Proxy)
  - **Why it matters:** The LEO satellite proxy intercepts fragments, stores them, and returns a local SCHC ACK to the end-device before the fragments reach the SCHC GW. If the satellite fails (e.g. burns up, experiences power loss, or suffers memory corruption) before forwarding the buffered fragments, the data is lost. However, because the end-device received a successful ACK, it will have deleted its local buffer and assumed delivery, resulting in silent data loss.
  - **Consequence for migration:** Migrating the draft requires either accepting this silent data loss risk and documenting it, or redesigning the mechanism to maintain end-to-end reliability (which increases transfer delay). Alternatively, -06 must define a new proxy role with explicit reliability semantics.

- **Risk:** RuleID and Context Synchronization in Receive Path
  - **Why it matters:** In cellular ZE networks, devices use configuration IDs to select Contexts. The draft lacks a standardized method for negotiating or synchronizing these configuration IDs. If the device and the Operator Platform's SCHC Instance become desynchronized, the receiver will apply the wrong rules, causing parsing failures or silent corruption.
  - **Consequence for migration:** The draft must explicitly define how configuration IDs map to -06 Contexts/Instance Configurations and how the Dispatcher resolves the correct active Context.

- **Risk:** Payload Compression Parser Complexity
  - **Why it matters:** Parsing and compressing key-value JSON payloads (SenML) requires a complex parser. ZE devices (especially Type A/B) are highly constrained and typically cannot afford the CPU/memory footprint of a full JSON parser and compression engine, contradicting their Zero Energy nature.
  - **Consequence for migration:** The draft must address how constrained devices can implement payload compression or recommend a binary pre-parsing step (e.g., using CBOR) before SCHC processing.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4.4.1 | "LEO Satellite as a SCHC Proxy... locally acknowledges SCHC regular fragments... splitting the SCHC connection..." | Recharacterize the proxy as a split-session F/R relay with segment-local state, and explicitly document the reliability risk (data loss if the satellite fails after acknowledging but before forwarding). | REQUIRED FOR CONCEPTUAL ALIGNMENT | Standard SCHC does not support split-session F/R without end-to-end reassembly. The draft must align with the end-to-end assumptions of -06 or define this behavior explicitly. |
| 2 | Section 4.1 / 4.2 / 4.4 | Device (Dev) and network gateway roles (e.g., "endpoint where SCHC is terminated in the network"). | Rewrite the roles to use -06 terminology: the Device hosts a "SCHC Endpoint" and "SCHC Instance", and the network-side terminator hosts a peer "SCHC Endpoint" and "Instance" participating in a "Session". | REQUIRED FOR TERMINOLOGY MIGRATION | Align terminology with -06's Endpoint, Instance, and Session model. |
| 3 | Section 4.2.3.3 | "This section describes how the SCHC framework may be used to compress payload, in addition to the headers for which it was initially designed. ... a section of the context MUST be dedicated to the payload..." | Rephrase to describe this as extending the "Stratum" of the SCHC Instance to the application layer, using a custom payload "Parser" in the Context. | REQUIRED FOR TERMINOLOGY MIGRATION | Integrates payload compression into -06's Stratum and Parser concepts rather than using ad-hoc context divisions. |
| 4 | Section 4.2.3.1 / 4.2.3.2 | "Context provisioning... Context updating... pre-configured configurations... addressed individually with a configuration ID." | Map the configuration IDs to -06 Context Identifiers/Instance Configurations, and define how the Dispatcher uses them as Discriminators to select the active Instance. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Integrates context selection into the -06 routing/dispatch architecture. |
| 5 | Section 3.1.2.1 | "unique identifier that is associated with the SCHC flow." | Clarify that the unique identifier serves as the "Discriminator" used by the "Dispatcher" on the Operator Platform. | REQUIRED FOR TERMINOLOGY MIGRATION | Align flow identifiers with -06 Dispatcher/Discriminator. |
| 6 | Section 4.2.1 | "Best Effort Transfer Interval (BETI)... paces fragment transmission." | Clarify that BETI is a pacing parameter managed locally by the F/R engine and stored in the Instance Configuration, rather than a shared Context parameter. | OPTIONAL CLARIFICATION | Clarifies that pacing is node-local configuration and does not require negotiation or shared context. |
| 7 | Section 1.1 / 1.2 | "This document normatively references [RFC5234] and has more information in 3GPPdocA and 3GPPdocB. (REPLACE)" | Remove placeholder "(REPLACE)" and update references. | EDITORIAL | Purely textual/editorial cleanup. |
| 8 | Appendix A | "This becomes an Appendix (REPLACE)" | Remove placeholder or populate Appendix A. | EDITORIAL | Purely textual/editorial cleanup. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 | C/D (Compression/Decompression) | "C/D: SCHC function that performs the Compression and Decompression of headers." | Expand definition: "C/D: SCHC function that performs the Compression and Decompression of protocol headers and/or structured application payload fields (e.g. key-value formats) defined by a profile." | ARCHITECTURE GAP | The draft applies C/D to SenML application payloads; -06 must clarify that C/D can apply to structured payloads. |
| 2 | New Section / Section 4.2 | SCHC Proxy / Segmented Session | None (no proxy concept exists). | Introduce the concept of a "SCHC Proxy" or "Split-Session F/R Relay" where an intermediate node intercepts F/R packets, stores them, and generates local ACKs/retransmissions without terminating the C/D session or performing full packet reassembly. | ARCHITECTURE GAP | The draft's DtS-IoT model relies on a LEO satellite acting as a SCHC Proxy that splits the F/R session. |
| 3 | Section 4.2.2.4 | Dispatcher routing | "Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator and admission rules..." | Clarify that the Discriminator can also be resolved from out-of-band management configuration or platform-level flow identifiers. | OPTIONAL CLARIFICATION | Supports the Operator Platform onboarding flow described in the draft. |

### Prose description of architectural gaps and required conceptual changes

The SCHC Architecture -06 requires significant adaptations to naturally express the technical model of [draft-ietf-schc-over-networks-prone-to-disruptions-03](file:///Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-over-networks-prone-to-disruptions-03.txt). The two primary architectural gaps are:

1. **Intermediate SCHC Proxy Role (Significant Gap):** 
   The draft's Direct-to-Satellite IoT (DtS-IoT) mechanism (Section 4.4.1) relies on a LEO Satellite acting as a "SCHC Proxy." This proxy intercepts fragmentation packets in the uplink, buffers them, and generates local SCHC ACKs back to the end-device. In the downlink, it performs local retransmissions of lost fragments. This effectively splits the F/R state machine into two hop-by-hop segments. 
   Under the current SCHC Architecture -06, a SCHC Session is strictly end-to-end between two Instances, and the F/R function is responsible for reassembling the original SCHC Packet. -06 lacks any concept of an intermediate relay, proxy, or split-session state machine that can manipulate fragments and generate feedback without fully terminating the Session or reassembling the packet. To naturally express this, -06 must be adapted to define a "SCHC Proxy" or "Split-Session F/R Relay" role, along with the rules governing fragment-level feedback delegation and the associated reliability trade-offs (e.g. the risk of silent data loss if the proxy fails after acknowledging but before forwarding).

2. **Payload Compression (Trivial Gap):**
   The draft's Section 4.2.3.3 describes "Payload Compression" where the SCHC engine is used to compress structured key-value payloads (SenML) rather than network headers. In contrast, -06's Terminology and C/D definitions are strictly limited to "headers." To naturally accommodate this, -06 must be clarified to state that the C/D engine and Parser can target structured application payload fields in addition to protocol headers, extending the "Stratum" concept to the application layer.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Mostly**
- Can the migration be performed mechanically? **No**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **The proxy gap is required for this draft's DtS-IoT section; the payload compression gap is useful generally for structured payloads.**
- What is the single most important migration issue? **The LEO Satellite SCHC Proxy, which splits the F/R state machine (local ACKs/retransmissions) without terminating the C/D session, violating -06's end-to-end Session model and introducing data loss risks that must be explicitly resolved.**

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

SCHC Architecture -06 **can naturally express** the draft under study. The draft describes SCHC deployments over disruption-prone networks (cellular Zero-Energy / Ambient IoT devices and Direct-to-Satellite IoT), and its technical model — a constrained device and a network-side SCHC termination sharing a static context, with delay-adapted F/R parameters, an optional on-path SCHC proxy, object (rather than IP-packet) transport, payload compression, and pre-provisioned parameter sets selected by identifiers — decomposes cleanly onto -06's Endpoint / Instance / Context / Session / Domain / Discriminator / Instance Configuration / SoV model.

The **principal conceptual mapping**: the draft's device-side and network-side SCHC entities (Dev, Proxy, SCHC Gateway, Application Server) each become an Endpoint hosting one or more Instances; the draft's "SCHC connection / session / flow" vocabulary resolves onto the -06 Session (with the draft's per-object "session" being an F/R exchange *within* a Session); the SCHC Proxy becomes an intermediate Endpoint whose Instances participate in two Sessions sharing the same Context — a decomposition the draft itself already articulates ("Local acknowledgments split the SCHC connection"); the onboarding/device identifier becomes a Discriminator used by the Dispatcher; "configuration ID" / "context groups" become Domain-scoped Contexts or groups of F/R Rules; BETI/TC/MAX_OBJECT_SIZE become Instance Configuration parameters; configured timers become F/R Rule parameters with runtime state in the SoV.

The **principal migration difficulty** is resolving the draft's overloaded connectivity vocabulary ("SCHC session", "SCHC connection", "SCHC flow", "endpoint" used both for a platform API endpoint and a SCHC termination) into distinct -06 concepts, and rewriting the Proxy passages as a two-Session structure.

An **Architecture gap exists but is Trivial**: -06 should (a) make explicit that the Stratum may extend to the application layer, so that an object is a legitimate unit admitted to an Instance, and (b) state explicitly that an Endpoint may be deployed on an intermediate node participating in Sessions toward each side (proxy/relay). Both are additive clarifications of relationships -06 already implies; they are proposed in `schc-architecture-edits.md`.

### Architectural risk points

- **Risk:** Session-semantics overload around the Proxy. The migrated text must not imply that -06 *defines* proxy behavior (local ACK, responsibility transfer); -06 only expresses the structure (intermediate Endpoint, two Sessions, shared Context). The behavior belongs to the profile/protocol (draft-munoz-schc-over-dts-iot).
  **Why it matters:** Readers could take reliability delegation as an architectural property of Sessions, corrupting the -06 Session concept.
  **Consequence for migration:** The File 3 diff phrases the split structurally and leaves the responsibility rule as profile behavior; Edit 2 says explicitly "This document does not define such proxy procedures."

- **Risk:** The draft's "session/connection/flow" triple maps onto one -06 term (Session) plus one non-term (F/R exchange). A mechanical rename of every "session" would produce statements that are false in -06 vocabulary (e.g., a "Session" that starts and ends with one object).
  **Why it matters:** This is the highest-volume source of migration error.
  **Consequence for migration:** Each occurrence classified individually in File 3; this is what keeps Transition at Easy rather than Very Easy.

- **Risk:** Configuration ID scope is unstated (who assigns it, where it is unique, where it is carried — data path or provisioning plane only?).
  **Why it matters:** In -06, identifiers for Instances, Contexts, and Sessions are unique within the Domain; an unscoped identifier cannot be placed in the model.
  **Consequence for migration:** REQUIRED FOR CONCEPTUAL ALIGNMENT edit scoping it to the Domain; the per-Context vs. per-Rule-group ambiguity is flagged for the authors rather than silently resolved.

- **Risk:** Object transport remains a protocol extension beyond RFC 8724 even after migration. The architecture names its placement (application-layer Stratum) but does not make it interoperable.
  **Why it matters:** Migration to -06 vocabulary must not be mistaken for RFC 8724 conformance of the object-transport mode.
  **Consequence for migration:** The migrated text keeps the draft's own caveat ("different from what has been specified by [RFC8724]") verbatim.

- **Risk:** §4.4.1.1 text/figure inconsistency: the text says the SCHC gateway "responds **to the end device** with an SCHC ACK", while Figure 11 shows that ACK terminating at the LEO satellite (the end device already got the local ACK).
  **Why it matters:** Under the two-Session mapping the GW's ACK peer is the Proxy; the text as written contradicts both the figure and the proxy mechanism it describes.
  **Consequence for migration:** One REQUIRED FOR CONCEPTUAL ALIGNMENT edit resolving the text in favor of the figure. This is the only place where migration touches a technical statement, and it aligns the text with the draft's own figure rather than changing intended behavior.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §4.4.1 | "Local acknowledgments split the SCHC connection between the end-device and SCHC Gateway." | Recast structurally: the Proxy is an Endpoint hosting Instance(s); local acknowledgments split the end-to-end exchange into two Sessions sharing the same Context (same Domain): Dev↔Proxy and Proxy↔Gateway | REQUIRED FOR CONCEPTUAL ALIGNMENT | -06 has no "SCHC connection"; the split the draft already describes must be expressed as Session decomposition |
| 2 | §4.4.1.1, Phase 2 | "The SCHC gateway receives the tiles and responds to the end device with an SCHC ACK message." | "…responds to the SCHC Proxy with a SCHC ACK message (see Figure 11)." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Under the two-Session structure the GW's Session peer is the Proxy; Figure 11 already shows the ACK terminating at the LEO satellite — resolves a text/figure inconsistency in favor of the figure |
| 3 | §4.2.3.2 | "a set of pre-configured configurations that are addressed individually with a configuration ID … use three context groups" | Identify the parameter sets as Contexts (or groups of F/R Rules within a Context) whose identifiers are unique within the Domain; state who assigns them (Domain management) | REQUIRED FOR CONCEPTUAL ALIGNMENT | The identifier's scope and assigner are unstated; -06 requires Domain-scoped identification of Contexts. The per-Context vs. per-Rule-group ambiguity should be resolved by the authors |
| 4 | §3.1.2.1 and §4.2.1 | Onboarding identifier "associated with the SCHC flow"; "If the Proxy has several devices attached, it must recognize which one is sending" | State that this identifier serves as the Discriminator used by the Dispatcher on the network-side/Proxy Endpoint to route SCHC Datagrams to the appropriate Instance/Session | REQUIRED FOR CONCEPTUAL ALIGNMENT | Gives the identifier its -06 role and scope; matches -06's own LPWAN example (device identity as Discriminator) |
| 5 | §4 (first paragraph) | "SCHC would become a simple transport protocol for the whole object instead of only fragmenting IP packets" | Add the architectural framing: the Instances' Stratum is the application layer and the unit admitted to the Instance is the object itself (keeping the draft's RFC 8724 caveat verbatim) | REQUIRED FOR CONCEPTUAL ALIGNMENT | Anchors object transport to the (clarified) Stratum concept instead of the "imaginary jumbo IP package" device (which may be kept as an intuition) |
| 6 | §3.1.2 (last paragraph) | "how to configure the SCHC fragmentation and reassembly entities. A Dev using SCHC and the endpoint where SCHC is terminated in the network with the relevant context information…" | "how to configure the SCHC Instances that perform fragmentation and reassembly. The Dev and the network each host a SCHC Endpoint whose Instances share the relevant Context…" | REQUIRED FOR TERMINOLOGY MIGRATION | "Entities"/"endpoint where SCHC is terminated" → Instance/Endpoint/Context |
| 7 | §3.1.2 | "the set up of the contexts and rules" | "the provisioning of the Contexts (and their Sets of Rules)" | REQUIRED FOR TERMINOLOGY MIGRATION | Context/SoR are the -06 terms |
| 8 | Global (§3.2.2 Fig. 8 caption, §4, §4.4.2 Fig. 12 caption) | "SCHC session" meaning one object transfer; "SCHC connection"; "SCHC flow" | "Session" where the standing relationship is meant; "F/R exchange within a Session" (or "fragmented SCHC Packet exchange") where a single transfer is meant | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves the overloaded vocabulary; prevents redefining the -06 Session |
| 9 | §4.1 | "Dev … needs a middle host called proxy that will maintain the connection state" | Dev, Proxy, and Application Server each host a SCHC Endpoint; the Proxy maintains the Session state (SoV) across disruptions and participates in Sessions toward both sides sharing the same Context | REQUIRED FOR TERMINOLOGY MIGRATION | Endpoint/Instance/Session/SoV framing of the general architecture |
| 10 | §4.2.1 | "provide pacing information to the SCHC device"; MAX_OBJECT_SIZE/BETI/TC configuration | Name MAX_OBJECT_SIZE, BETI, and TC as parameters of the Dev Instance's Instance Configuration | REQUIRED FOR TERMINOLOGY MIGRATION | These are node-local operating parameters = Instance Configuration in -06 |
| 11 | §4.2.2 | "the compressor entity is in the cellular network" | "the compressing Instance is hosted on an Endpoint in the cellular network" | REQUIRED FOR TERMINOLOGY MIGRATION | Instance/Endpoint vocabulary |
| 12 | §4.2.3.1, §4.2.3.3 | "context" (lowercase, various); "common context is shared between sender and receiver" | "Context … shared between the sending and receiving Instances"; consistent capitalization of Context/Rules | REQUIRED FOR TERMINOLOGY MIGRATION | -06 defined terms |
| 13 | §4.2.3.2 | Timer values "can be also set according to the scheduling calculation…" | Add: configured values are F/R Rule parameters of the Context; running timers/counters are per-Session state in the Set of Variables (SoV) | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the draft's implicit static-vs-runtime split explicit using SoR/SoV |
| 14 | §4.4.2 | "the end-device (fragmenter) and the SCHC gateway (reassembler) use a Forward Error Correction mechanism (FEC)" | Add that the FEC function is a SCHC function of the corresponding Instances (e.g., realized as a SCHClet) indicated in their Instance Configuration | REQUIRED FOR TERMINOLOGY MIGRATION | Places FEC in the -06 function/SCHClet model without defining the protocol |
| 15 | §2 | Conventions and Definitions | Add a paragraph adopting the terminology of draft-ietf-schc-architecture (Endpoint, Instance, Context, Session, Domain, Discriminator, Dispatcher, Instance Configuration, SoR, SoV) | REQUIRED FOR TERMINOLOGY MIGRATION | Anchors all subsequent term usage |
| 16 | §4.2.1 / §4.1 | Proxy with several devices attached | Optionally note that this corresponds to the -06 LPWAN deployment example: one shared Instance with one Session per Device, or one Instance per Session | OPTIONAL CLARIFICATION | Helps implementers; not required for migration |
| 17 | §4.1 / §4.4 | Domain membership implicit | Optionally state that the Dev, Proxy, and Gateway Instances share Contexts and hence belong to a single Domain | OPTIONAL CLARIFICATION | Makes the implicit single-Domain assumption visible |
| 18 | §1 | "…has more information in 3GPPdocA and 3GPPdocB. (REPLACE)" | Replace placeholder with real references | EDITORIAL | Placeholder text |
| 19 | §3 (first paragraph) | "## ZE-Devices based in cellular Zero Energy (ZE) devices…" | Remove the stray "## ZE-Devices based in cellular" markdown artifact | EDITORIAL | Formatting artifact |
| 20 | §3.1.2.1 | "the device might not have the capability to onboard itself to and endpoint" | "…to onboard itself to the platform" | EDITORIAL | Typo; also removes a collision with the -06 term Endpoint |
| 21 | §4.4.1 | "retransmits locally the regular SCHC fragments that losses between SCHC Proxy and end-device" | "…the SCHC regular fragments lost between the SCHC Proxy and the end-device" | EDITORIAL | Grammar |
| 22 | §4.4.2 | "More details over the implementation in draft-munoz-schc-over-dts-iot" | Add a proper informative reference | EDITORIAL | Reference formatting |
| 23 | Appendix A | "This becomes an Appendix (REPLACE)" | Replace placeholder | EDITORIAL | Placeholder text |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §3 Terminology — Stratum | Stratum / unit admitted to an Instance | "A background concept that identifies a portion of the network protocol stack targeted by SCHC, i.e., the contiguous layers within which SCHC processing can be applied. The Stratum defines the scope of the protocol headers that the SCHC Rules in the associated Context can address." | Append: the Stratum may extend up to and include the application layer; in that case the unit admitted to an Instance is an application-layer data unit (e.g., an object), and SCHC F/R can provide segmented, delay-tolerant transport of that unit, using protocol mechanisms defined by [RFC8724] and its extensions | ARCHITECTURE GAP (Trivial — additive clarification) | The draft's central mechanism (SCHC as object transport) is only implicitly expressible; -06's packet-oriented wording leaves the naturalness in doubt |
| 2 | §4.2.3 Session | Intermediary Endpoints / proxy deployments | Session section describes Sessions among Instances of a Domain; no intermediate Endpoint is mentioned anywhere in -06 | Append a paragraph: an Endpoint may be deployed on an intermediate node, its Instances participating in distinct Sessions toward each side, all sharing the same Context (same Domain); a profile may define proxy behavior (e.g., local acknowledgments) on that basis; this document does not define such procedures | ARCHITECTURE GAP (Trivial — explicit statement of an already-implied relationship) | The draft's SCHC Proxy (§4.1, §4.4.1) needs this deployment shape to be stated, not merely permitted by silence |
| 3 | §6 Operational considerations | Long-disruption operation | §6 covers error handling and Context consistency only | Optionally note that in disruption-prone deployments F/R timers may span days to months and Session state (SoV) must persist across connectivity gaps | OPTIONAL CLARIFICATION | Useful generally; NOT required — profiles can already set arbitrary timer values, so this does not affect the adaptation verdict |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Mostly** — the sole technical-text change is §4.4.1.1 Phase 2 (ACK destination), which aligns the text with the draft's own Figure 11 rather than altering intended behavior.
- Can the migration be performed mechanically? **Mostly** — a small number of identified locations (Proxy split, configuration-ID scope, session-vs-transfer wording) need one-time mapping decisions; all other edits are mechanical renames.
- Does the draft expose a SCHC Architecture -06 gap? **Yes** — a Trivial one (two additive clarifications: application-layer Stratum/object as admitted unit; intermediary/proxy Endpoints).
- Is the gap required for this draft or merely useful generally? **Required for this draft** (object transport and the SCHC Proxy are its two central mechanisms) — and also useful generally for any store-and-forward or over-the-top SCHC deployment.
- What is the single most important migration issue? Resolving the overloaded "SCHC session / connection / flow" vocabulary and recasting the SCHC Proxy as two -06 Sessions sharing one Context, without importing the proxy's reliability-delegation behavior into the meaning of the -06 Session concept.
