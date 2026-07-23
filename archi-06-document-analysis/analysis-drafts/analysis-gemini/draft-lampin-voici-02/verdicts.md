# Architectural alignment review: draft-lampin-voici-02

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **Very High** | Highest grade | If it were High, some concepts would require explicit reinterpretation or minor structural changes. However, all features (multiplexing, integrity, metadata preservation) map naturally and directly to core components in -06. |
| **Transition difficulty** | **Easy** | If it were Very Easy, the transition would be purely mechanical. Here, some architectural framing and judgment are required to clarify that the wire "Session ID" is a link-local Discriminator component representing a logical Session. | If it were Medium, non-trivial edits across multiple sections and significant restructuring of the draft's technical model would be required. The draft already uses -06 terms (Instance, Endpoint, Dispatcher, Domain Manager). |
| **SCHC Architecture adaptation need** | **Trivial** | If it were None, zero changes to -06 would be required. Here, -06 must clarify that wire-carried Session IDs can be link-local Discriminators and that the Dispatcher can route to non-SCHC handlers. | If it were Medium, existing normative text or core architectural definitions in -06 would need to be reworded such that their meaning shifts. The gaps here are closed with purely additive, clarifying text. |

## Executive assessment
The Static Context Header Compression (SCHC) Architecture (`draft-ietf-schc-architecture-06`) can naturally express the concepts, relationships, and technical behavior of the VOICI link multiplexer (`draft-lampin-voici-02`). 

The principal conceptual mapping is that the VOICI header functions as an explicit **Control Header** parsed by the Endpoint's **Dispatcher** before passing the payload to either a **SCHC Instance** or a raw/non-SCHC handler. The VOICI Session ID maps to a **Discriminator** component representing the logical Session on a specific link segment, the Content Identifier (CI) maps to a Discriminator component routing to the correct handler, the Original EtherType/Port maps to **Metadata** carried in the Control Header to restore framing layers, and the CRC maps to the **Protection (Integrity)** service.

The principal migration difficulty is ensuring that the wire-carried "Session ID" in the VOICI header is conceptually framed as a link-local Discriminator rather than the Domain-unique Session ID defined by -06, which would otherwise conflict in multi-link or relay topologies.

A minor architecture gap exists in `draft-ietf-schc-architecture-06` because the Dispatcher is historically described as routing only to SCHC Instances, and Session IDs are defined as globally unique within a Domain. Clarifying that the Dispatcher can route to non-SCHC handlers (such as unprocessed traffic) and that the wire Session ID is a link-local Discriminator component resolves this gap. These changes are additive and do not alter the core architecture, resulting in a **Trivial** adaptation verdict.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **VOICI (Link Multiplexer)** | A transport encapsulation providing multiplexing, mechanism identification, and integrity over a link. | Intermediary layer between link/carrier layer and handlers | Link segment | Replaced by SCHC protocol numbers on the wire | 1 per link interface; multiplexes multiple Sessions and mechanisms | Optional in deployments where lower layers already provide multiplexing. |
| **Session ID (SID)** | A variable-length identifier (0-65535) distinguishing logical communication sessions on a link. | VOICI header and dispatcher | Local to the link and to the Content Mechanism | SID field (derived from SSS or as a LEB128 integer) | 1 per Session on a link; multiple SIDs can coexist on a link | Assigned by Network Gateway, negotiated, or managed by Domain Manager. Relays can remap SIDs. |
| **Content Identifier (CI)** | A 2-bit field (extendable) identifying the mechanism used to process the payload. | VOICI Header (base byte) | Datagram-local | CI field | 1 CI per Datagram; maps to 1 Content Mechanism | Initial values: 0 (Raw), 1 (SCHC), 2 (Reserved), 3 (Extended CI). |
| **Extended CI** | An extension mechanism for Content Identifiers larger than 2 bits. | VOICI Header | Datagram-local | Extended CI value | 1:1 with Datagram if CI=3 | Encoded in SSS or as LEB128 following flag byte. |
| **Original EtherType/Port** | Optional field carrying the original protocol identifier (EtherType, Next Header, or UDP port) replaced by the carrier. | VOICI Header | Datagram-local | 1-byte or 2-byte field | 1 per Datagram (optional, if O=1) | Used by receiver to restore the original framing layer after decompression. |
| **CRC** | Optional 16-bit integrity check (CRC-16/CCITT-FALSE) over the header and payload. | VOICI Header | Datagram-local | 2-byte field | 1 per Datagram (optional, if I=1) | Protects against data corruption on links without lower-layer integrity. |
| **VOICI dispatcher** | Receives packets, parses the header, dispatches payload based on SID and CI, and restores original headers. | Endpoint network stack | Endpoint-local | N/A | 1 per Endpoint | Serves as the central demultiplexing coordinator. |
| **Content Mechanism / Handler** | The destination processor for the payload (e.g. SCHC Instance or Raw path). | Endpoint | Endpoint-local | CI / Extended CI | 1 handler per CI value | Example: SCHC Instance for CI=1, Raw path for CI=0. |
| **Domain Manager** | Manages the Domain, assigning SIDs and distributing configurations. | Management plane | Domain-wide | N/A | 1 per Domain | Distributes Contexts and configurations to Endpoints. |
| **Carrier Header** | The transport protocol carrying VOICI traffic, e.g. EtherType, IP Protocol Number, or UDP port. | Underlying network stack | Link-local or peer-to-peer | SCHC protocol numbers | 1 carrier layer per packet | Identifies VOICI-encapsulated traffic on the wire. |

## Native architectural model

The native architectural model of `draft-lampin-voici-02` defines a Link Multiplexer (VOICI) that operates directly above a carrier transport layer. VOICI is designed to support constrained links where multiple communication sessions, compression mechanisms, or uncompressed payloads must share the same physical or logical interface. 

The core entity is the VOICI module, which functions as both an encapsulator on the sender side and a dispatcher on the receiver side. When a packet is prepared for transmission, the VOICI module replaces the original protocol identifier (such as an EtherType, IPv6 Next Header, or UDP destination port) with a corresponding SCHC carrier identifier. If the receiver needs to restore the original protocol layer, the VOICI module preserves the original identifier in the VOICI Control Header and sets the Original EtherType/Port flag (O).

Multiplexing is achieved using a Session ID (SID), which is a variable-length integer (0-65535) locally significant to the link segment and the Content Mechanism. The Session ID space is not globally unique; instead, relays or gateways operating at link segment boundaries can remap Session IDs as packets traverse different segments of the network. This local scoping ensures that Session ID representation on the wire remains extremely small, reducing to a single byte in the common case.

Content identification is handled by the Content Identifier (CI) field, which determines how the payload is encoded. This allows the receiver's VOICI dispatcher to route the payload to the correct handler (e.g., a SCHC Instance for compression, or a raw dispatch path for uncompressed management traffic) without inspecting the payload itself. New mechanisms can be registered with new CI values, and an Extended CI mechanism allows for more than 4 mechanisms.

For links that do not guarantee data integrity, VOICI provides optional integrity protection via an Integrity flag (I) and a 2-byte CRC. When enabled, the CRC covers the VOICI header and the entire payload. This is especially relevant when upper-layer protocol (ULP) checksums are elided to reduce overhead.

The management plane assumes that Session IDs are allocated by a Domain Manager or Network Gateway during provisioning, or negotiated dynamically between peers. The configuration indicating whether VOICI is used is part of the Endpoint's static configuration. Security considerations focus on preventing session hijacking, flag bit manipulation, and denial-of-service attacks by validating Session IDs and enforcing optional CRC checks.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **VOICI (Link Multiplexer)** | A transport encapsulation providing multiplexing, mechanism identification, and integrity over a link. | **Control Header** and **Dispatcher** / encapsulation layer (Sec 4.2.2.4, 4.2.5.1) | Composite | Aligned | Aligned | None | Represents a concrete implementation of the Control Header and Dispatcher architecture. |
| **Session ID (SID)** | A variable-length identifier (0-65535) distinguishing logical communication sessions on a link. | **Discriminator** component representing the logical **Session** (Sec 4.2.3, 4.2.2.4) | Composite | Partial | Aligned | -06 Session IDs are Domain-unique, while VOICI SIDs are link-local on the wire. | To align, the wire SID must be treated as a link-local representation (Discriminator component) that maps to a Domain-unique Session. |
| **Content Identifier (CI)** | A 2-bit field (extendable) identifying the mechanism used to process the payload. | **Discriminator** component (Sec 4.2.2.4) | Direct | Aligned | Aligned | -06 does not explicitly define multi-mechanism selectors in its Dispatcher. | Handled by treating CI as part of the admission rules in the Instance Configuration. |
| **Extended CI** | An extension mechanism for Content Identifiers larger than 2 bits. | **Discriminator** component (Sec 4.2.2.4) | Direct | Aligned | Aligned | None | A larger representation of the CI. |
| **Original EtherType/Port** | Optional field carrying the original protocol identifier replaced by the carrier. | **Metadata in the Control Header** (Sec 4.2.5.1) | Direct | Aligned | Aligned | None | Sec 4.2.5.1 explicitly lists "save the initial value of the EtherType field" as a Control Header service. |
| **CRC** | Optional 16-bit integrity check (CRC-16/CCITT-FALSE) over the header and payload. | **Protection (Integrity)** field in the **Control Header** (Sec 4.2.5.1) | Direct | Aligned | Aligned | None | Matches the "Protection (Integrity)" service of the Control Header. |
| **VOICI dispatcher** | Receives packets, parses the header, dispatches payload based on SID and CI, and restores original headers. | **Dispatcher** (Sec 4.2.2.4) | Direct | Aligned | Aligned | -06 Dispatcher routes only to SCHC Instances, while VOICI routes to non-SCHC paths too. | Clarification needed in -06 (Trivial gap). |
| **Content Mechanism / Handler** | The destination processor for the payload (e.g. SCHC Instance or Raw path). | **SCHC Instance** (for CI=1) (Sec 4.2.1) | Direct | Aligned | Aligned | None | Non-SCHC handlers (CI=0) are out of scope for the SCHC architecture but handled by the same Dispatcher. |
| **Domain Manager** | Manages the Domain, assigning SIDs and distributing configurations. | **Domain Manager** (Sec 3, 4.1.2) | Direct | Aligned | Aligned | None | Identical role. |
| **Carrier Header** | The transport protocol carrying VOICI traffic. | Underlying network stack / transport layer | Direct | Aligned | Aligned | None | Aligns with the link or transport layer. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Resides within the Content Mechanism (e.g. SCHC Instance) for CI=1. | Shared between Instances participating in a Session; belongs to the Domain. | Fully aligned | None. |
| **Ownership of Set of Rules** | Part of the Content Mechanism (SCHC Instance). | Part of the Context shared by Instances. | Fully aligned | None. |
| **Ownership of Set of Variables** | Implicitly per Session within the Content Mechanism. | Per-Session runtime variables/state. | Fully aligned | None. |
| **Endpoint↔SCHC Instance** | Endpoint can host multiple Instances (one per Tenant/Domain or Session). | Endpoint can host multiple Instances. | Fully aligned | None. |
| **SCHC Instance↔Session** | A Gateway Instance can handle multiple Sessions (Table 1) or one Instance per Session (Table 2). | A Session is between two or more Instances. A Domain can have multiple Sessions. An Instance can participate in multiple Sessions (e.g. -06 Table 1 Gateway hosts "one shared Instance" for "one Session per Device"). | Fully aligned | None. |
| **Sharing of Context between Sessions/Instances** | Multiple Sessions/Instances can share a Context (pre-configured or fetched). | Supported (multiple Instances share Context in a Domain; root can share rules with multiple partial leaf contexts). | Fully aligned | None. |
| **RuleID scope** | Contained in the payload of VOICI (when CI=1). Local to the SCHC Instance Context. | RuleID is part of the Datagram; selects a Rule in the Context associated with the Instance. | Fully aligned | None. |
| **Discriminator scope** | Session ID + CI carried in VOICI header. Local to the link segment; can be remapped by relays. | Information element used by Dispatcher to route Datagrams. Session ID is defined as unique within the Domain. | Partial | The VOICI Session ID must be understood as a link-local representation (wire Discriminator) that maps to a Domain-unique Session or Instance ID. |
| **Control Header processing scope** | Parsed by VOICI module to extract SID and CI for dispatching. | Parsed by Dispatcher to route before interpreting Context-dependent portions. | Fully aligned | None. |
| **Domain membership and boundaries** | Managed by Domain Manager; Session IDs are assigned per Domain or negotiated. | Instances share Contexts within a Domain. | Fully aligned | None. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| **Session ID** | SCHC -06 Session ID | -06 defines Session ID as unique within the Domain. VOICI defines Session ID as local to the link and to the Content Mechanism, permitting remapping by relays. If a Domain spans multiple links, a VOICI Session ID on the wire is not globally unique in the Domain. | **Discriminator component** that represents the Session on a specific link segment. | To align with -06's uniqueness requirements for Session ID, the VOICI Session ID must be viewed as a link-local Discriminator component. The actual logical Session ID remains Domain-unique, but its wire representation is translated at link boundaries. |
| **Content Identifier (CI)** | Discriminator component | -06 does not define multi-mechanism selectors in its Dispatcher; it assumes all Datagrams are routed to SCHC Instances. Does mapping to a Discriminator violate -06's scope? | **Discriminator component** (selecting the processing path/Instance). | The mapping is valid because -06's Dispatcher uses the Discriminator to route packets based on "admission rules". Clarifying that the Dispatcher can also bypass SCHC for raw/non-SCHC traffic makes this natural. |

## Architectural risk points

- **Risk:** Session ID uniqueness scoping mismatch.
  - **Why it matters:** If an implementer assumes that the 16-bit Session ID in the VOICI header is the Domain-unique Session ID from -06, they will fail to support relay topologies where SIDs are remapped, or multi-link domains where SID ranges overlap.
  - **Consequence for migration:** The draft must clearly distinguish the *wire/link-local Session ID* (which acts as a local Discriminator) from the *logical/Domain-unique Session* it represents.
- **Risk:** Out-of-scope dispatching to non-SCHC handlers.
  - **Why it matters:** The SCHC Architecture is centered on SCHC. Integrating VOICI as the link multiplexer means the Dispatcher must handle traffic that bypasses SCHC (CI=0) or uses other protocols (CI=3). If the Dispatcher is tightly coupled to SCHC Instances, carrying non-SCHC traffic will break.
  - **Consequence for migration:** The implementation model for the Dispatcher must be decoupled from the SCHC C/D engine, allowing the Dispatcher to operate as a generic link multiplexer as defined by VOICI.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 2.1, Requirement 1 (Session identification) | "The identifier (Session ID) is locally significant to the link." | Clarify that the wire Session ID serves as a link-local Discriminator component representing a logical Session, which itself has a Domain-unique identity. | REQUIRED FOR CONCEPTUAL ALIGNMENT | To align with SCHC Architecture -06 where Session IDs are unique within a Domain, the draft should clarify that the wire-carried Session ID is a link-local representation (Discriminator) that maps to the Domain-unique Session. |
| 2 | Section 5.1 (Fields - Session ID) | "The Session ID space (0-65535) is local to the link over which VOICI is carried and to the Content Mechanism." | Add a note: "In the context of the SCHC Architecture [SCHC-ARCH], the Session ID carried in the VOICI header acts as a link-local Discriminator. The Dispatcher maps this link-local Discriminator (possibly combined with lower-layer identifiers) to a logical Session whose identifier is unique within the Domain." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Clarifies the relationship between the link-local wire ID and the Domain-unique architectural Session. |
| 3 | Section 4 (Integration within SCHC framework) | "uses the Session ID and CI field to route the Datagram to the correct processing handler, strips its own header, and optionally restores..." | Explicitly use the term "Dispatcher" from SCHC Architecture -06 and describe the routing in terms of "Instance selection" using the Session ID and CI as a "Discriminator". | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the VOICI module's routing function with the terminology of the Dispatcher and Discriminator in -06. |
| 4 | Section 7 (Content Mechanism Identification) | "VOICI at the receiver uses the CI and Session ID values to dispatch the Datagram to the correct handler..." | Rephrase to state that the Dispatcher uses the CI and Session ID as a compound Discriminator to select the target Instance (for SCHC) or non-SCHC handler. | REQUIRED FOR TERMINOLOGY MIGRATION | Connects the dispatching mechanism to -06's concept of compound Discriminators and Dispatcher routing. |
| 5 | Section 12.2 (Informative References) | `[SCHC-ARCH] ... draft-ietf-schc-architecture-05` | Update reference to `draft-ietf-schc-architecture-06`. | EDITORIAL | Reference update to the latest version under study. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.2.4 (Multiple Instances) | Session ID and Discriminator Scope | "A Session Identifier, or Session ID, may be used as a Discriminator to route the Datagrams to the correct Instance... Identifiers for Instances, Contexts, and Sessions are unique within the scope of their Domain." | Add clarifying paragraph: "While logical Session Identifiers are unique within their Domain, the wire representation of a Session ID (e.g. in a Control Header) may be local to a specific link segment. In such deployments, the wire Session ID acts as a link-local Discriminator component that is mapped by the Dispatcher (possibly in combination with lower-layer context) to the Domain-unique Session or Instance. Intermediaries such as gateways or relays may remap these link-local identifiers at segment boundaries." | ARCHITECTURE GAP | Enables natural expression of link-local Session IDs and relay-based remapping as specified in `draft-lampin-voici-02`. |
| 2 | Section 4.2.2.4 (Multiple Instances) | Dispatcher routing scope | "Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator and admission rules..." | Clarify that the Dispatcher can route to either SCHC Instances or non-SCHC handlers: "The Dispatcher may also be responsible for demultiplexing traffic when a link carries a mix of SCHC-compressed datagrams and other traffic (e.g., uncompressed packets or packets compressed via other mechanisms). In such cases, the Dispatcher uses the Discriminator (such as a Content Identifier in a Control Header) to route the datagram either to a SCHC Instance or to the appropriate non-SCHC handling path." | ARCHITECTURE GAP | Supports the multi-mechanism dispatching model of VOICI. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft but also useful generally for multi-mechanism environments.**
- What is the single most important migration issue? **Reframing the link-local "Session ID" on the wire as a link-local Discriminator component representing the logical end-to-end Session.**
