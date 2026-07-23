# Architectural alignment review: rfc8724

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All concepts, relationships, scopes, and technical behaviors of RFC 8724 are naturally expressible in SCHC Architecture -06 without any reinterpretation of protocol mechanics. RFC 8724's implicit LPWAN model maps 1-to-1 onto -06's explicit logical components (Endpoint, Instance, Session, Domain, Dispatcher, Discriminator). |
| Transition difficulty | Easy | RFC 8724 uses LPWAN-specific architectural framing (Dev, NGW, RGW, App) throughout Sections 3, 4, 5, 6, and several paragraphs in Sections 7 and 8. Reframing these sections into Endpoints, Instances, Sessions, and Discriminators requires systematic rewording and local section updating (especially Section 3 and Section 5.2), which goes beyond a simple find-and-replace list. | Every mapping decision is clear, unambiguous, and 1-to-1 repeatable. No architectural redesign or complex technical judgment is needed—RFC 8724's implicit model maps directly onto Architecture -06's explicit entities without changing a single bit of wire format, state machine logic, or protocol requirement. |
| SCHC Architecture adaptation need | None | Highest grade | Zero ARCHITECTURE GAP items exist. All architectural concepts, definitions, roles, cardinalities, and framing required to express RFC 8724 are already fully present and formally defined in SCHC Architecture -06 (and explicitly exemplified in Appendix A.2.1). |

## Executive assessment
SCHC Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally, completely, and directly express RFC 8724 without any conceptual modification or protocol reinterpretation. RFC 8724 is the foundational specification of the Static Context Header Compression and fragmentation framework, created originally with Low-Power Wide Area Networks (LPWANs) in mind. SCHC Architecture -06 generalizes and formalizes the underlying architectural model implicitly present in RFC 8724.

The principal conceptual mapping maps RFC 8724's "Dev side" and "Network Infrastructure side" entities to SCHC **Endpoints** hosting SCHC **Instances** operating in a SCHC **Session** within a SCHC **Domain**. Lower-layer device identifiers (such as LoRaWAN DevEUI or L2/IPv6 addresses) map directly to SCHC **Discriminators**, which are consumed by the **Dispatcher** on the Endpoint to select the appropriate SCHC Instance. The static rule sets of RFC 8724 correspond directly to -06 **Contexts** containing a Set of Rules (SoR), while runtime fragmentation states (timers, bitmaps, window indices) correspond to the Set of Variables (SoV).

The principal migration difficulty is rated **Easy**: it involves updating RFC 8724's LPWAN-bound framing (Dev, NGW, RGW, App) to SCHC Architecture -06's generalized entity model (Endpoint, Instance, Session, Discriminator, Dispatcher). This migration is purely textual and architectural-framing work; zero wire formats, F/R state machines, CDA operations, or matching operator semantics change.

No SCHC Architecture -06 gaps exist for RFC 8724 (`SCHC Architecture adaptation need: None`). Appendix A.2.1 of Architecture -06 already provides a validated architectural mapping for RFC 8724 LPWAN deployments.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Dev (Device) | LPWAN host or end-device (sensor, actuator) running applications and hosting SCHC mechanisms. | Dev physical node | Node-local | Dev identifier (DevEUI, L2 address, DevIID) | 1 Dev per LPWAN link instance; 1 Dev : N Apps | Primary constrained entity in LPWAN architecture. |
| Radio Gateway (RGW) | Boundary node of the constrained wireless link forwarding frames between Dev and NGW. | Access Network infrastructure | Link-local | L2 wireless channel / MAC address | N Devs : 1 RGW : 1 NGW | Transparent or forwarding node; does not execute SCHC processing. |
| Network Gateway (NGW) | Interconnection node between RGWs and the IP Internet; routes or tunnels packets to SCHC processing. | Network Infrastructure side | Access domain / network side | IP address / Tunnel ID / Dev ID | 1 NGW : M RGWs : N Devs | May host SCHC entities directly or tunnel to external SCHC entities. |
| Application Server (App) | End host on the Internet running application-level protocols (e.g. CoAP/UDP) with Dev. | Internet / Cloud infrastructure | Global IP network | IPv6 Address / AppIID / Port | 1 Dev : N Apps; 1 App : M Devs | End-to-end peer for upper-layer traffic, outside SCHC sublayer. |
| SCHC C/D | SCHC entity performing Header Compression and Decompression. | Co-located on Dev and Network side (NGW or Server) | Peer-pair (Dev <-> Network) | RuleID (within Dev Context) | 1 SCHC C/D per Dev side; 1 Network SCHC C/D handles N Devs | Operates on static Context containing Field Descriptors and Rules. |
| SCHC F/R | Optional SCHC entity performing Fragmentation and Reassembly of SCHC Packets. | Co-located with SCHC C/D on Dev and Network side | Peer-pair (Dev <-> Network) | RuleID (F/R Rule range) + DTAG | 1 SCHC F/R per Dev side; 1 Network SCHC F/R handles N Devs | Supports No-ACK, ACK-Always, ACK-on-Error reliability modes. |
| Context | Set of static Rules stored at both ends to compress/decompress headers or fragment/reassemble packets. | Shared between Dev and Network SCHC entities | Dev link / peer-pair scope | Provisioned Context ID / Dev association | 1 Context per Dev (or shared rule set across Devs) | Must be pre-provisioned or learned out-of-band; strictly static. |
| Rule | Structured description of C/D actions (Field Descriptors) or F/R parameters, identified by a RuleID. | Stored within a Context | Context-local | RuleID | 1 Context : N Rules | Contains Field Descriptors (FID, FL, FP, DI, TV, MO, CDA) or F/R mode. |
| RuleID | Short identifier representing a Rule in compressed headers or F/R message headers. | Carried in SCHC Packet / Fragment header | Context-local (per Dev link) | RuleID bit field | 1 RuleID : 1 Rule (within a Context) | RuleID space shared between C/D and F/R rules within a Context. |
| Profile | Technology-specific document specifying parameter choices (RuleID size, F/R modes, L2 word, timers). | Deployment-wide specification | Technology domain | Profile name / specification reference | 1 Profile : N Devices / Deployments | Specifies mandatory choices from RFC 8724 Appendix D options. |
| SCHC Packet | A packet whose header has been compressed by SCHC C/D (or tagged with a no-compression RuleID). | Exchanged between SCHC C/D entities | Sublayer transfer unit | RuleID + Compression Residue | 1 IPv6 Datagram -> 1 SCHC Packet | Input to SCHC F/R if size > L2 MTU. |
| SCHC Fragment | A piece of a SCHC Packet transmitted over L2 by SCHC F/R. | Exchanged between SCHC F/R entities | Link transfer unit | RuleID + DTAG + W + FCN | 1 SCHC Packet -> N SCHC Fragments | Contains payload tiles, integrity check (MIC), and control headers. |
| Compression Residue | Remaining header bits sent beyond RuleID after applying CDA actions. | In SCHC Packet header | Packet-local | Positioned after RuleID | 0 to K bits depending on CDA | May be bit-aligned; padded to L2 Word at frame boundary if needed. |
| DevIID / AppIID | IPv6 Interface Identifiers for the Dev and App interfaces. | IPv6 Header / SCHC Context | Link / Network scope | 64-bit IPv6 IID | 1 Dev : 1 DevIID; 1 App : 1 AppIID | Handled by specialized DevIID/AppIID CDAs in compression rules. |
| F/R State & Parameters | Runtime state (Tiles, Windows, Bitmaps, Timers, Retransmission Counters, MIC state). | SCHC F/R sublayer instance | Session / Transmission scope | Window index (W), Fragment Count (FCN), DTAG | Per active fragmentation transaction | Maintained independently for Uplink and Downlink transfers. |

## Native architectural model
RFC 8724 defines Static Context Header Compression and fragmentation (SCHC), a generic framework created primarily to enable IPv6 and transport-layer communication over Low-Power Wide Area Networks (LPWANs). LPWAN technologies are characterized by severely constrained payload sizes, low data rates, star-oriented topologies, and asymmetric battery-conserving energy profiles. To achieve extreme header compression efficiency without the overhead of dynamic context synchronization protocols (such as RoHC), RFC 8724 relies on static context information stored in advance at both ends of the constrained link.

The architectural environment described in RFC 8724 comprises four principal entities: Devices (Dev), Radio Gateways (RGW), Network Gateways (NGW), and Application Servers (App). Devices are constrained end-nodes running embedded applications. RGWs are access points forwarding radio frames over the constrained link. NGWs connect the LPWAN access infrastructure to the IP network. Application Servers are end hosts on the Internet communicating with applications on the Device using standard IP protocols (such as IPv6, UDP, and CoAP).

SCHC operates as an adaptation layer located between upper network layers (IPv6) and lower link layers (LPWAN technology). It comprises two distinct functional sublayers: the Compression/Decompression (C/D) sublayer and the Fragmentation/Reassembly (F/R) sublayer. SCHC C/D and SCHC F/R entities exist on both the Dev side and the Network Infrastructure side. On the Network Infrastructure side, SCHC entities may be integrated into the NGW or hosted on an external server connected to the NGW via an IP tunnel.

The core mechanisms of SCHC C/D depend on a Context, defined as a set of static Rules. A Rule describes how header fields of a specific protocol stack are matched and compressed using Field Descriptors. Each Field Descriptor specifies a Field Identifier (FID), Field Length (FL), Field Position (FP), Direction Indicator (DI), Target Value (TV), Matching Operator (MO), and Compression/Decompression Action (CDA). When a packet matches a Rule, known header fields are elided or compressed into a short RuleID and an optional Compression Residue, producing a SCHC Packet. If no compression Rule matches, a reserved no-compression RuleID is prepended to the original uncompressed packet.

SCHC F/R is an optional sublayer invoked when a SCHC Packet exceeds the maximum payload size of the underlying Layer 2 technology. SCHC F/R divides the SCHC Packet into payload tiles and transmits them across multiple SCHC Fragments. It supports three distinct reliability modes: No-ACK (unreliable transmission), ACK-Always (window-by-window feedback), and ACK-on-Error (selective retransmission of missing tiles). F/R messages utilize header fields including RuleID, Datagram Tag (DTAG), Window (W), Fragment Count (FCN), and a Message Integrity Code (MIC).

Identifiers in RFC 8724 are tightly scoped. The RuleID identifies a specific C/D or F/R rule within the Context associated with a given Dev. On the Dev side, RuleID selection and Context lookup are implicit because the Dev typically maintains a single SCHC Context. On the Network Infrastructure side, because the network serves thousands of Devices, the SCHC entity must first identify the sending or receiving Dev using lower-layer metadata or network identifiers (such as LoRaWAN DevEUI, link-layer address, or IP address) before indexing the appropriate Dev Context and matching the RuleID.

RFC 8724 assumes static provisioning of Contexts and Rules prior to operation. Dynamic context creation, dynamic rule negotiation, and out-of-band context management protocols are explicitly out of scope of RFC 8724. Technology-specific operational choices—such as RuleID length, F/R reliability modes, timer values, L2 Word alignment, and tile sizes—are defined in separate technology profiles.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Dev (Device) | LPWAN host/end-device hosting SCHC C/D and F/R mechanisms. | Endpoint hosting Instance (Device Role) | Direct | Node-local | 1 Dev -> 1 Endpoint (hosting 1 Instance in basic LPWAN profile) | None. -06 generalizes Dev to an Endpoint capable of hosting multiple Instances. | Natural direct mapping; Appendix A.2.1 of -06 explicitly confirms this. |
| Network Infrastructure SCHC Entity | Network-side entity performing C/D and F/R for devices. | Endpoint hosting Instance(s) (Gateway/Infrastructure Role) | Direct | Network domain | 1 Network Endpoint hosting N Instances (or 1 shared Instance handling N Sessions) | None. -06 formalizes single-Instance vs multi-Instance gateway choices. | Fully supported in -06 Section 4.2.2 and Appendix A.2.1. |
| Radio Gateway (RGW) / NGW | LPWAN infrastructure forwarding frames and providing device identification. | Lower-layer Network / Dispatcher link interface | Direct | Access network | N Devs : 1 NGW | None. NGW API provides lower-layer context used by Dispatcher. | NGW device metadata serves as Discriminator input. |
| Application Server (App) | Internet host communicating with Dev applications over IPv6/UDP. | External Host / Application above SCHC Instance | Direct | Global network | 1 Dev : N Apps | None. External entity operating above SCHC Stratum. | Outside SCHC processing sublayer boundary. |
| Context | Set of static Rules used for C/D and F/R. | Context (Set of Rules + Data Model / Parser metadata) | Direct | Domain / Shared between Instances | Shared between 2+ Instances in a Session | None. -06 adds explicit Data Model/Parser metadata reference to Context. | Exact conceptual match. |
| Rule | Structured C/D or F/R descriptor identified by RuleID. | Rule | Direct | Context-local | 1 Context : N Rules | None. | Identical definition in both documents. |
| RuleID | Identifier for a C/D or F/R Rule. | RuleID | Direct | Instance / Context scope | 1 RuleID : 1 Rule | None. | Identical definition in both documents. |
| Profile | Technology-specific setting of SCHC parameters. | Deployment Profile | Direct | Technology / Deployment Domain | 1 Profile : N Instances | None. | -06 Section 5 explicitly references RFC 8724 Appendix D profiles. |
| Dev-Network Link / Communication | Logical point-to-point communication path between Dev and Network SCHC entities. | Session (Implicit Point-to-Point SCHC Session) | Direct | Session scope | 1 Dev <-> Network pair = 1 Session | None. -06 formalizes the relationship as a Session between Instances. | Exact semantic match. |
| Dev Identifier (DevEUI, IPv6 Address, L2 ID) | Lower-layer value used on network side to select Dev Context. | Discriminator | Direct | Endpoint / Dispatcher scope | 1 Dev ID -> 1 Instance / Session | None. -06 explicitly defines lower-layer IDs (DevEUI, IP, port) as Discriminators. | Natural direct match; Section 4.2.2.4 & Appendix A.2.1 of -06. |
| SCHC C/D Engine | Functional sublayer compressing and decompressing headers. | C/D Function executed within Instance | Direct | Instance-local | 1 C/D engine per Instance | None. | -06 Section 4.2.2.1 defines C/D component inside Instance. |
| SCHC F/R Engine | Functional sublayer fragmenting and reassembling packets. | F/R Function executed within Instance | Direct | Instance-local | 1 F/R engine per Instance | None. | -06 Section 4.2.2.2 defines F/R component inside Instance. |
| NGW Context Lookup & Dispatching | Logic on network side routing incoming frame to correct Dev Context. | Dispatcher | Direct | Endpoint-local | 1 Dispatcher per Endpoint | None. Dispatcher routes Datagrams to Instances based on Discriminator. | Exact functional match. |
| Collection of Dev Contexts at Network side | Repository of static contexts managed on network infrastructure. | Domain / Context Repository | Direct | Domain scope | 1 Domain : N Contexts | None. -06 formalizes domain management and context repositories. | Natural direct match. |
| F/R Runtime State (Timers, Bitmaps, Counters) | Per-session state required during fragmentation and reassembly. | Set of Variables (SoV) | Direct | Session scope | 1 SoV per active Session | None. -06 explicit term for per-session runtime parameters. | Exact concept match. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Context is shared between Dev and Network SCHC entity for a specific Dev link. | Context is shared between two or more Instances participating in a Session within a Domain. | Direct | Complete alignment. -06 formalizes domain-wide sharing and management. |
| Ownership of Set of Rules (SoR) | SoR is contained within the static Context shared by Dev and Network side. | SoR is contained within Context held by Instances. | Direct | Complete alignment. |
| Ownership of Set of Variables (SoV) | Runtime state (timers, bitmaps, window indices) maintained per fragmentation transaction. | SoV contains runtime parameters and per-session variables maintained by the Instance/Session. | Direct | Complete alignment. -06 gives explicit name (SoV) to RFC 8724's runtime state. |
| Endpoint <-> SCHC Instance | Dev is a single physical/logical node with one implicit SCHC processing block. | Endpoint is a logical host that MAY execute multiple independent Instances. | Direct | Complete alignment. LPWAN Dev is a 1-Instance Endpoint; Gateway is a multi-Instance Endpoint. |
| SCHC Instance <-> Session | Dev SCHC entity engages in point-to-point communication with Network SCHC entity. | Session is a communication session between two or more Instances sharing a Context. | Direct | Complete alignment. RFC 8724 LPWAN communication is an implicit P2P Session. |
| Sharing of Context between Sessions/Instances | Network side may use same rule set across multiple Devs if provisioned identically. | Domain allows multiple Instances/Sessions to share the same Context and SoR while maintaining separate SoVs. | Direct | Complete alignment. -06 explicitly details this in Appendix A.2.1 Tables 1 and 2. |
| RuleID scope | RuleID is unique within the Context associated with a specific Dev link. | RuleID is unique within the Context used by an Instance. | Direct | Complete alignment. |
| Discriminator scope | Dev identity (DevEUI, MAC, IP) provided by LPWAN API/L2 used by NGW to select Dev context. | Discriminator is lower-layer or external context used by Dispatcher to route Datagram to correct Instance. | Direct | Complete alignment. |
| Control Header processing scope | RFC 8724 does not define explicit Control Headers (carried directly in L2 payload). | Control Header carries optional metadata/discriminators before/after RuleID; optional for LPWAN. | Direct | Complete alignment. Basic LPWAN uses direct framing without Control Headers. |
| Domain membership and boundaries | Implicit network infrastructure domain managing set of provisioned device contexts. | Domain is a logical grouping of Instances sharing a common set of Contexts under a Domain Manager. | Direct | Complete alignment. -06 provides explicit architectural boundaries for RFC 8724 deployments. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk:** Implicit 1-to-1 binding between physical Device, single Context, and single SCHC processing engine in RFC 8724 narrative.
  - **Why it matters:** Early RFC 8724 implementations might hardcode assumptions that an endpoint only ever has one Context or one Instance, making multi-tenant or multi-Domain deployment difficult without refactoring.
  - **Consequence for migration:** The migration text should explicitly introduce Endpoint, Instance, and Dispatcher terminology in Section 3 and Section 5 of RFC 8724 to clarify that a Dev is logically an Endpoint hosting an Instance, preventing implementation coupling.

- **Risk:** Overloading of Dev identifier (DevEUI / L2 address) as both link identifier and implicit Instance selector on the network gateway.
  - **Why it matters:** On the Network Gateway, routing incoming packets to the correct context requires an explicit dispatch step using the device identifier.
  - **Consequence for migration:** Migration requires explicitly identifying the LPWAN device identifier as a **Discriminator** evaluated by the **Dispatcher**, fully aligning RFC 8724's gateway dispatch logic with Section 4.2.2.4 of Architecture -06.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3 (LPWAN Architecture) | Describes Dev, RGW, NGW, and App purely as physical/network entities with implicit SCHC handling. | Reframe Dev and NGW as SCHC Endpoints hosting SCHC Instances that execute C/D and F/R functions within a SCHC Session. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns RFC 8724 LPWAN architectural overview with SCHC Architecture -06 entity definitions. |
| 2 | Section 4 (Terminology) | Defines basic SCHC terms (SCHC C/D, SCHC F/R, Context, Rule, Profile) without architectural entities. | Add explicit definitions for Endpoint, Instance, Session, Domain, Dispatcher, Discriminator, and Set of Variables (SoV). | REQUIRED FOR TERMINOLOGY MIGRATION | Establishes common vocabulary with SCHC Architecture -06. |
| 3 | Section 5.2 (Functional Mapping) | Maps SCHC C/D and F/R directly to Dev and Network Infrastructure side. | Update functional mapping to show Endpoints hosting Instances exchanging SCHC Datagrams in a Session, with NGW using a Dispatcher. | REQUIRED FOR TERMINOLOGY MIGRATION | Clarifies logical execution model and packet dispatching on network gateways. |
| 4 | Section 6 (RuleID) | "The scope of the RuleID ... is the link between the SCHC C/D in a given Dev and the corresponding SCHC C/D in the Network Infrastructure side." | Reframe scope statement: "The scope of the RuleID is the Context shared between Instances in a Session. On the Network side, a Discriminator selects the Instance." | REQUIRED FOR TERMINOLOGY MIGRATION | Clarifies distinction between Instance/Session demultiplexing (via Discriminator) and Rule selection (via RuleID). |
| 5 | Section 8.2.2 (F/R Protocol Elements) | Refers to fragmentation timers, counters, bitmaps, and window state as informal protocol elements. | Explicitly group per-session fragmentation runtime parameters under the term Set of Variables (SoV). | OPTIONAL CLARIFICATION | Provides precise architectural categorization for F/R runtime state. |
| 6 | Global document text | Uses "Dev side" and "Network Infrastructure side" interchangeably for processing roles. | Consistently clarify when referring to physical Dev/NGW nodes vs logical Instance roles (Device role / Gateway role). | EDITORIAL | Improves document precision without changing technical meaning. |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required for rfc8724.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable
- What is the single most important migration issue? Reframing LPWAN-specific role names (Dev, NGW, App) into SCHC Architecture -06 abstractions (Endpoint, Instance, Session, Discriminator, Dispatcher) while maintaining absolute compatibility with existing RFC 8724 wire formats and state machines.

No modification to SCHC Architecture -06 is required.
