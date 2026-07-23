# Architectural alignment review: rfc9442

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All concepts, roles, communication patterns, rule structures, and fragmentation mechanisms in RFC 9442 map directly or compositely to SCHC Architecture -06 without changing technical behavior or requiring architectural reinterpretation. |
| Transition difficulty | Easy | A small amount of local rewriting and architectural reframing is required in Section 3.1 (Network Architecture) to explicitly define Endpoints, Instances, Sessions, Dispatchers, and Discriminators, preventing it from being purely mechanical string substitution (Very Easy). | The mapping decisions are straightforward, direct, and repeatable across all sections, preserving all normative wire formats, bit-level header structures, tile sizes, timers, and state machine transitions without requiring structural reframing or complex redrafting. |
| SCHC Architecture adaptation need | None | Highest grade | SCHC Architecture -06 already contains explicit definitions and LPWAN deployment models (Section 4, Section 5, Appendix A.2.1) that encompass all protocol mechanisms, metadata callbacks, and profile structures defined in RFC 9442. Zero architecture gaps exist. |

## Executive assessment
SCHC Architecture -06 can naturally and completely express all technical, protocol, and deployment aspects of RFC 9442 ("Static Context Header Compression (SCHC) over Sigfox Low-Power Wide Area Network (LPWAN)"). RFC 9442 defines a technology-specific SCHC profile for Sigfox LPWAN networks, specifying parameter choices, fragmentation modes, header bit layouts, and message formats within the SCHC framework (RFC 8724).

The native conceptual model of RFC 9442—consisting of the Sigfox Device, Network SCHC C/D + F/R, Sigfox Cloud (NGW), Radio Gateways (RGW/BS), RuleIDs, callback metadata (Device ID), fragmentation sessions, and timers—maps cleanly into the SCHC Architecture -06 technical model:
1. The Sigfox Device and Network SCHC C/D + F/R map to SCHC Endpoints hosting SCHC Instances executing in Device and Network roles respectively.
2. The Sigfox Device ID passed via core network callback API acts as the lower-layer Discriminator used by the Dispatcher on the Network SCHC Endpoint to route incoming Datagrams to the correct SCHC Instance.
3. Pre-configured static compression/fragmentation rules form the Context and Set of Rules (SoR).
4. Active fragmentation state (FCN, W, bitmaps, tile buffers, RCS, Inactivity Timer, Retransmission Timer) corresponds directly to the per-session Set of Variables (SoV) within a SCHC Session.

Transitioning RFC 9442 to -06 terminology and architectural framing is rated as **Easy**. The technical behavior, normative requirements, wire formats, sequence numbers, and bit layouts remain 100% intact. Updating the draft requires reframing Section 3.1 ("Network Architecture") and substituting terms throughout Section 3 to explicitly introduce Endpoints, Instances, Sessions, Dispatchers, Discriminators, SoR, and SoV.

No modifications to SCHC Architecture -06 are required (**None**). SCHC Architecture -06 already explicitly models LPWAN deployments in Appendix A.2.1 and Section 9.2 (citing RFC 9442), naturally accommodating all Sigfox profile choices (such as DTag size T=0, variable-length RuleIDs, Compound ACKs, and callback API metadata discriminators).

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Sigfox Device | Physical LPWAN end-device running applications and SCHC C/D & F/R functions. Transmits/receives Sigfox L2 frames over radio. | Physical end-device | Device-local | Sigfox Device ID (32-bit unique identifier in Sigfox L2 header) | 1 device hosts 1 SCHC C/D & F/R function; communicates with 1 Network SCHC function. | Contains APP1, APP2, APP3; supports Uplink (0-12B) and device-driven Downlink (8B). |
| Radio Gateway (RGW) / Sigfox BS | Base station receiving Uplink radio transmissions and forwarding them to NGW; relays Downlink frames to device. | Radio network infrastructure | Link-local / cell coverage | Station ID / Radio channel | Many RGWs receive frames from 1 Device (spatial diversity); RGWs connect to 1 NGW. | Transparent to SCHC layer; passes raw L2 frames. |
| Network Gateway (NGW) / Sigfox Cloud | Core network collecting frames from RGWs, performing triple diversity de-duplication, generating metadata, and invoking callback/API. | Sigfox Cloud core network | Global / Network-wide | Device ID, Message Sequence Number | 1 NGW connects to all RGWs globally; forwards messages to Network SCHC C/D + F/R. | Generates metadata (Timestamp, RSSI, Temp, Battery, Geolocation). |
| Network SCHC C/D & F/R | Processing function that decompresses/re-assembles Uplink messages and compresses/fragments Downlink messages. | Cloud or edge server (collocated with NGW or remote via secure tunnel) | Administrative domain / network backend | Device ID (from callback API) | 1 Network SCHC entity handles N Sigfox Devices; shares Rules with each Device. | Communicates with LPWAN Application Servers over external IP network. |
| Application Server (App) | End application destination/source for uncompressed IPv6/UDP/CoAP packets. | External IP network | Global / Application-level | IP address, UDP port | 1 or more Apps per Sigfox Device. | Communicates via standard IP-based network. |
| SCHC Rules | Pre-configured static rules for header compression/decompression and fragmentation/reassembly parameters. | Stored at Sigfox Device and Network SCHC C/D & F/R | Shared between Device and Network SCHC | RuleID (3-bit, 6-bit, or 8-bit) | Set of Rules per device; multiple devices can share identical Rule sets. | Provisioned out-of-band, via NETCONF/RESTCONF/CORECONF, or pre-provisioned at manufacturing. |
| RuleID | Identifier carried at start of SCHC header indicating compression/fragmentation rule. First bits also demultiplex header size. | SCHC Header (leftmost bits) | Per-device Rule set | RuleID value (3 bits for standard, 6 bits for extended Option 1, 8 bits for Option 2) | 1 RuleID maps to 1 Rule definition. | RuleID=0b111 in standard rules signals Two-byte Header mode. |
| DTag | Datagram Tag field in SCHC fragmentation header. In RFC 9442, DTag size is 0 bits (T=0). | SCHC Fragmentation Header | Per-device | None (T=0) | Not used; session interleaving achieved via distinct RuleIDs. | Fixed at 0 bits to save header overhead in short Sigfox payloads. |
| SCHC Message (Fragment / ACK / Abort) | Unit of exchange between Device and Network SCHC, carried in Sigfox L2 payload. | Sigfox L2 Payload | Communication link | RuleID (+ W, FCN, RCS if fragmentation) | 1 SCHC Message fits in 1 Sigfox frame payload (UL 0-12B, DL 8B). | Types: Regular Fragment, All-1, SCHC ACK, Compound ACK, Sender-Abort, Receiver-Abort. |
| Active Fragmentation Session | State machine handling reassembly, tile buffering, window counters, and timers during fragmented transfers. | Maintained at Device and Network SCHC | Per active transfer / per device | RuleID (+ Device ID at Network) | 1 active fragmentation session per RuleID per device. | State variables: W, FCN, RCS, bitmap, Inactivity Timer, Retransmission Timer, MAX_ACK_REQUESTS. |
| Callback / API Metadata | Parameters provided by Sigfox Cloud to Network SCHC alongside message payload. | NGW-to-Network SCHC interface | Network-local | Device ID, Message Sequence Number | 1 metadata tuple per received Uplink message. | Includes Device ID, Seq Num, Payload, Timestamp, RSSI, Temp, Battery, Geolocation. |
| Downlink Request Flag | L2 protocol flag in Uplink message requesting a Downlink reception window opportunity. | Sigfox L2 Header / SCHC ACK-on-Error FCN=All-0/All-1 | Link-local | Flag bit | Set on specific Uplink fragments (All-0, All-1) to trigger Downlink SCHC ACK. | Sigfox Downlink is strictly device-driven; opens fixed reception window on device. |

## Native architectural model
The native architectural model of RFC 9442 is built around a star-topology LPWAN network connecting constrained Sigfox Devices to central Application Servers through the Sigfox Cloud infrastructure and a dedicated SCHC processing function.

In this architecture, the Sigfox Device is a constrained endpoint hosting application code (e.g., APP1, APP2, APP3), an IP/UDP protocol stack, and a SCHC Compression/Decompression (C/D) and Fragmentation/Reassembly (F/R) module. The device communicates over a long-range wireless link with distributed Sigfox Base Stations, also referred to as Radio Gateways (RGWs). The RGWs act as transparent L2 relays, forwarding received radio signals over an internal network to the cloud-based Sigfox Core Network, known as the Network Gateway (NGW).

The NGW provides central coordination, triple diversity processing (combining message copies received across time, frequency, and space by multiple RGWs), and L2 framing validation (checking the 8-bit L2 CRC). When a valid L2 frame is received, the NGW invokes a callback/API to forward the payload and associated metadata (Device ID, Message Sequence Number, Timestamp, RSSI, etc.) to the Network SCHC C/D + F/R function.

The Network SCHC C/D + F/R function is the peer entity to the Sigfox Device's SCHC module. It may be physically collocated with the NGW or hosted on a remote server connected via a secure IP tunnel. The Network SCHC entity maintains synchronized static SCHC Rules for each device. Upon receiving a compressed/fragmented SCHC message, it decompresses headers and reassembles fragments before forwarding uncompressed IPv6 packets to one or more LPWAN Application Servers (App) across an external IP network.

Communication between the Sigfox Device and the Network SCHC function is bidirectional but highly asymmetric. Uplink transmissions are asynchronous and carry payloads up to 12 bytes. Downlink transmissions carry fixed 8-byte payloads and occur only when explicitly requested by the device via a Downlink request flag in a preceding Uplink frame. Consequently, Downlink SCHC ACK messages and Receiver-Aborts can only be transmitted during these device-driven Downlink opportunities.

Static context information—consisting of SCHC Rules—is pre-configured on both the Sigfox Device and the Network SCHC function prior to operation (e.g., via NETCONF, RESTCONF, CORECONF, or factory provisioning). RuleIDs in the SCHC header identify the active rule. To maximize payload efficiency over short 12-byte Uplink and 8-byte Downlink frames, RFC 9442 uses variable-length RuleIDs (3 bits, 6 bits, or 8 bits) where the leading bits implicitly select both the RuleID space and the fragmentation header structure.

Fragmentation in RFC 9442 supports Uplink No-ACK mode (single-byte header), Uplink ACK-on-Error mode (single-byte or two-byte headers), and Downlink ACK-Always mode (single-byte header). The DTag size is fixed at 0 bits (T=0) across all modes because concurrent transfer sessions are distinguished by allocating separate RuleIDs. Reliability is ensured using SCHC Compound ACKs (RFC 9441) and Reassembly Check Sequences (RCS) tailored to Sigfox L2 word boundaries (1 byte).

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Sigfox Device | Physical node executing application, C/D, and F/R functions | Endpoint hosting a SCHC Instance (Device role) | Composite | Aligned (Endpoint and Instance reside on the device node) | Aligned (1 device Endpoint hosting 1 Instance) | None; physical device host mapped to logical Endpoint + Instance. | Device role implicitly derived from LPWAN star topology. |
| Network SCHC C/D & F/R | Network-side entity executing C/D and F/R functions | Endpoint hosting SCHC Instance(s) (Network role) | Composite | Aligned (Network backend scope) | Aligned (1 Network Endpoint hosting 1 shared Instance or N per-device Instances) | None. | -06 explicitly describes this in Appendix A.2.1. |
| Sigfox Cloud / NGW | Core network routing frames and forwarding callback metadata | Lower-layer network infrastructure & Dispatcher source | Direct | Aligned (Network layer below SCHC) | Aligned (Central network gateway) | None. | Provides lower-layer context (Device ID) for dispatching. |
| Radio Gateway (RGW) | L2 base station relaying radio frames | Lower-layer relay | Direct | Aligned (Link layer relay) | Aligned (N RGWs per NGW) | None. | Outside SCHC architectural boundary. |
| SCHC Rules / Context | Static pre-configured compression and fragmentation rules | Context (containing Set of Rules - SoR) | Direct | Aligned (Shared between Instances) | Aligned (1 Context per device session / shared across domain) | None. | Static context provisioned out-of-band. |
| Device ID | Unique 32-bit device identifier in Sigfox L2 header & callback API | Discriminator | Direct | Aligned (Used at Network Endpoint for routing) | Aligned (Unique per device Instance) | None. | Used by Dispatcher on Network Endpoint to route Datagrams to Instance. |
| RuleID | Field in SCHC header selecting compression/fragmentation rule | RuleID | Direct | Aligned (Evaluated within Instance Context) | Aligned (1 RuleID per Rule within SoR) | None. | Leading bits also demultiplex header structure (Instance Configuration matching/parsing policy). |
| DTag = 0 bits | Omission of DTag field in SCHC fragmentation header | Profile-specific constraint on Context / SoR | Profile-specific | Aligned (Profile parameter choice per RFC 8724 / -06 Sec 5) | Aligned (T=0 for all sessions) | None. | Permitted by RFC 8724 and -06 profile specifications; interleaving done via RuleIDs. |
| SCHC Message | Encapsulated C/D payload or F/R message in Sigfox L2 payload | SCHC Datagram | Direct | Aligned (Unit of exchange between Instances) | Aligned (1 Datagram per L2 frame payload) | None. | Carries RuleID followed by rule-dependent fields/payload. |
| Active Fragmentation Session State | Dynamic state variables (W, FCN, RCS, bitmaps, timers) | Session & Set of Variables (SoV) | Composite | Aligned (Per-session dynamic state) | Aligned (1 SoV per active Session) | None. | SoV maintains runtime counters and timers while Context (SoR) remains static. |
| Callback / API Metadata | Device ID, timestamp, RSSI, sequence number passed to Network SCHC | Lower-layer API context for Dispatcher & Instance | Profile-specific | Aligned (Interface between NGW and SCHC Endpoint) | Aligned (Passed per incoming Datagram) | None. | Fits naturally into -06 Dispatcher admission criteria and Instance input metadata. |
| Downlink Request Flag | L2 flag indicating device readiness for Downlink frame | Lower-layer control signal / Profile-specific F/R trigger | Profile-specific | Aligned (Link-local reception window control) | Aligned (Triggered on All-0 / All-1 fragments) | None. | Constrains when Network Instance can transmit Downlink SCHC ACK / Receiver-Abort. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Pre-configured on both Sigfox Device and Network SCHC C/D + F/R for each device. | Stored in Context Repository / Domain, shared between Instances participating in a Session. | Direct | Full alignment. Context (SoR) is shared statically between Device and Network Instances. |
| Ownership of Set of Rules (SoR) | SoR defines C/D and F/R rules stored in device context. | SoR is the collection of Rules contained within a Context. | Direct | Full alignment. |
| Ownership of Set of Variables (SoV) | Dynamic fragmentation state (timers, bitmaps, window numbers, RCS) maintained per active transfer. | SoV contains runtime parameters and session variables owned by a Session. | Direct | Full alignment. Cleanly separates static Context (SoR) from dynamic transfer state (SoV). |
| Endpoint <-> SCHC Instance | Sigfox Device hosts 1 SCHC C/D + F/R function; Network SCHC hosts 1 entity for multiple devices. | Endpoint hosts 1 or more Instances. Device Endpoint has 1 Instance; Network Endpoint can host 1 shared Instance or N per-device Instances. | Direct | Full alignment. Both multi-Instance and single-shared-Instance models are supported in -06. |
| SCHC Instance <-> Session | 1 active communication relationship per device between Device SCHC and Network SCHC. | Session is a communication session between Instances sharing a Context. | Direct | Full alignment. |
| Sharing of Context between Sessions/Instances | Multiple devices may use the same standard SCHC profile rules while maintaining isolated transfer state. | Multiple Instances/Sessions in a Domain can share the same Context (SoR) while keeping distinct SoVs. | Direct | Full alignment. |
| RuleID scope | Scope is local to the device's rule set / context. | Scope is local to the Context associated with an Instance. | Direct | Full alignment. |
| Discriminator scope | Device ID in Sigfox header / callback API uniquely identifies device at Network SCHC. | Discriminator uniquely identifies the target Instance for the Dispatcher at the Endpoint. | Direct | Full alignment. Device ID serves directly as the Discriminator at the Network Endpoint. |
| Control Header processing scope | No explicit SCHC Control Header used; Sigfox L2 header carries Device ID, SCHC payload starts with RuleID. | Optional Control Header before/after RuleID for routing/metadata. | Direct | Full alignment. RFC 9442 uses lower-layer framing without a SCHC Control Header, which is a standard -06 configuration. |
| Domain membership and boundaries | All Sigfox devices and Network SCHC operating under a network deployment form an operational domain. | Domain is a logical grouping of Instances sharing Contexts, managed by a Domain Manager. | Direct | Full alignment. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk:** Network SCHC Endpoint implementation choices (shared Instance with per-session SoV vs. per-Device Instances).
  - **Why it matters:** RFC 9442 describes the Network SCHC C/D + F/R function as a single logical entity communicating with NGW. In SCHC Architecture -06, this can be realized either as a single shared SCHC Instance maintaining per-Session SoVs (Table 1 in -06 Appendix A.2.1) or as multiple SCHC Instances (one per device/Session) managed by an Instance Manager (Table 2 in -06 Appendix A.2.1).
  - **Consequence for migration:** Clarify in Section 3.1 that both implementation options are fully compliant with SCHC Architecture -06 and produce identical wire behavior over the Sigfox L2 network.

- **Risk:** Reliance on lower-layer callback API metadata for Instance dispatching.
  - **Why it matters:** In RFC 9442, the Network SCHC function receives the SCHC message from the Sigfox NGW via an API callback containing metadata (Device ID, Sequence Number, RSSI, etc.). The SCHC Datagram itself does not contain a device identifier.
  - **Consequence for migration:** In -06 terms, the Device ID supplied in the API metadata acts as an external lower-layer Discriminator. The Network Endpoint's Dispatcher uses this Discriminator to select the target Instance before passing the SCHC Datagram for processing. This reliance on lower-layer context is explicitly supported by -06 Section 4.2.2.4 and Appendix A.2.1.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3.1 | Sigfox Device and Network SCHC C/D + F/R described as monolithic functions | Reframe Sigfox Device as a SCHC Endpoint hosting a SCHC Instance (Device role) and Network SCHC as an Endpoint hosting SCHC Instance(s) (Network role) | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns network architecture description with SCHC Architecture -06 concepts. |
| 2 | Section 3.1 & 3.2 | Device ID delivered via NGW callback API | Frame Device ID as the lower-layer Discriminator used by the Network Endpoint Dispatcher to route datagrams to the correct Instance | REQUIRED FOR TERMINOLOGY MIGRATION | Adopts -06 Dispatcher/Discriminator terminology for Instance demultiplexing. |
| 3 | Section 3.3 & 3.5 | Contexts and rules configuration / fragmentation state | Clarify that pre-configured static context constitutes the Context and Set of Rules (SoR), while active fragmentation state/timers form the per-session Set of Variables (SoV) | REQUIRED FOR TERMINOLOGY MIGRATION | Differentiates static context (SoR) from dynamic session state (SoV) per -06 terminology. |
| 4 | Section 3.4 | "RuleIDs can be used to differentiate data traffic classes..." | Note that RuleIDs are evaluated within the Context of an Instance, and Instance Configuration defines matching policy | OPTIONAL CLARIFICATION | Explicitly connects rule selection to -06 Instance Configuration. |

## Needed modifications to SCHC Architecture -06
| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? Reframing Section 3.1 ("Network Architecture") to explicitly map Sigfox network nodes and callback metadata to SCHC Architecture -06 concepts (Endpoint, Instance, Session, Dispatcher, Discriminator, SoR, and SoV) without altering any normative wire formats, bit-level headers, or fragmentation protocol state machines.
