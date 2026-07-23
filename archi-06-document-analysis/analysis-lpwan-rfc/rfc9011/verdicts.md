# Architectural alignment review: rfc9011

SOURCE CONFIRMED: Static Context Header Compression and Fragmentation (SCHC) over LoRaWAN (RFC 9011) — 8 sections / 1331 lines — obtained from /Users/apelov/Work/SCHC/archi/schc_drafts/rfc9011.txt
SOURCE CONFIRMED: Static Context Header Compression (SCHC) Architecture (draft-ietf-schc-architecture-06) — 9 sections / 1681 lines — obtained from /Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | Every concept in RFC 9011 (End Device, SCHC Gateway, RuleID in FPort, DevEUI, shared context, fragmentation parameters, timers, IID computation) maps directly and without semantic distortion to SCHC Architecture -06 constructs (Endpoint, Instance, Session, Domain, Context/SoR, SoV, Discriminator, Dispatcher). RFC 9011 is explicitly cited in -06 Appendix A.2.1 as a baseline LPWAN profile implementation. |
| Transition difficulty | Easy | The draft requires localized rewriting across Sections 3, 4, and 5 to introduce -06 terms (Endpoint, Instance, Session, Discriminator, SoR, SoV) and clarify the dual role of FPort, preventing a purely mechanical search-and-replace. | Mapping decisions are clear, consistent, and repeatable throughout the text. No section requires complex architectural re-engineering or changes to underlying protocol behavior. |
| SCHC Architecture adaptation need | None | Highest grade | SCHC Architecture -06 already contains all required architectural constructs and explicitly models RFC 9011 in Appendix A.2.1. Zero ARCHITECTURE GAP items exist. |

## Executive assessment

SCHC Architecture -06 can naturally and completely express the technical model, communication relationships, and operational behavior of RFC 9011. RFC 9011 defines a SCHC profile over LoRaWAN networks, specifying how SCHC header compression and fragmentation (RFC 8724) operate over LoRaWAN link-layer primitives. SCHC Architecture -06 explicitly incorporates RFC 9011 as its primary reference example for LPWAN deployments in Appendix A.2.1.

The principal conceptual mapping maps the LoRaWAN End Device to a SCHC Endpoint hosting a single SCHC Instance; the SCHC Gateway (LoRaWAN Application Server) to a SCHC Endpoint hosting one or more SCHC Instances; the LoRaWAN network topology to a SCHC Domain; the point-to-point association between Device and SCHC Gateway to an implicit SCHC Session; the pre-shared rules to a Context (Set of Rules); the runtime fragmentation state and timers to a Set of Variables (SoV); the LoRaWAN DevEUI to the primary SCHC Discriminator used by the SCHC Gateway Dispatcher; and the LoRaWAN FPort field to the SCHC RuleID field (which also serves as a secondary Discriminator element when a device communicates with multiple SCHC Gateways).

The principal migration effort is straightforward and mostly mechanical, requiring updating terminology in Sections 3, 4, and 5 to explicitly frame components around Endpoints, Instances, Sessions, Discriminators, Contexts, and Sets of Variables. No architectural gaps exist in SCHC Architecture -06, and no modifications to the reference architecture are required.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| End Device (Device) | Sensor/actuator executing SCHC C/D and SCHC F/R over a constrained LoRaWAN radio link | Constrained physical device | Device-local / Link-local | DevEUI (64-bit EUI), DevAddr (32-bit L2 address) | 1 Device ↔ 1 DevEUI; 1 Device ↔ 1 or more SCHC Gateways | Maps to LoRaWAN End Device specification |
| Radio Gateway (RGW) | Physical radio base station forwarding L2 frames between Device and NGW | Infrastructure node | Link-local radio boundary | None (L2 relay) | N Devices ↔ 1 RGW ↔ 1 NGW | Transparent to SCHC layer |
| Network Gateway (NGW) | LoRaWAN Network Server handling L2 MAC, joining, and routing frames to Application Servers | Core network server | LoRaWAN network domain | DevAddr to DevEUI mapping | N RGWs ↔ 1 NGW ↔ M SCHC Gateways | Translates DevAddr into DevEUI |
| SCHC Gateway | LoRaWAN Application Server executing SCHC C/D and SCHC F/R; acts as first-hop IP router | Application Server node | Domain-local / Network edge | Application Server identity / IP address | 1 SCHC Gateway ↔ N Devices | Decompresses packets and forwards to IP internet |
| Join Server (LPWAN-AAA) | Key management entity delivering security keys (AppKey, AppSKey) during join procedure | Security server | Domain / Administrative domain | DevEUI, AppKey | 1 Join Server ↔ N Devices / NGWs | Out of band for SCHC payload processing |
| Set of Rules | Pre-provisioned compression and fragmentation rules shared prior to communication | Device & SCHC Gateway | Session / Peer-pair | RuleID (8-bit) | 1 Set of Rules shared between Device & SCHC Gateway | Includes C/D rules, F/R rules (FPortUp/FPortDown), No-comp rule |
| RuleID | 8-bit identifier specifying which SCHC rule applies to a packet or fragment | SCHC Message header (carried in FPort) | Context-local / Session-local | 8-bit integer [1..223] | 1 RuleID ↔ 1 Rule | Carried directly in LoRaWAN FPort field |
| FPort | LoRaWAN frame port field (8 bits) carrying application payload type | LoRaWAN L2 MAC Header | Link-local frame header | FPort value [1..223] | 1 FPort ↔ 1 RuleID | Concatenated with payload to re-form SCHC Message |
| DevEUI | IEEE 64-bit extended unique identifier assigned by manufacturer | Device hardware / NGW | Global / Domain-wide | 64-bit EUI | 1 DevEUI ↔ 1 Device | Used by NGW to identify device to SCHC Gateway |
| Interface Identifier (IID) | 64-bit IPv6 interface identifier derived dynamically via AES-CMAC(AppSKey, DevEUI) | Device & SCHC Gateway | IPv6 link-local / Session-local | 64-bit IID | 1 IID per L2 session (re-derived on join) | Prevents tracking and address scanning |
| Fragmentation Parameters | Profile settings for ACK-on-Error (uplink) and ACK-Always (downlink): M, N, T=0, tile size, timers | Device & SCHC Gateway F/R engines | Session-local | RuleID (FPortUp=20, FPortDown=21) | Fixed per profile direction | Uplink: M=2, N=6, tile=10B; Downlink: M=1, N=1, variable tile |
| Application Server (App) | Ultimate IP endpoint on the Internet receiving decompressed IPv6/UDP packets | Remote IP host | Global IP network | IPv6 Address / UDP Port | N Apps ↔ 1 SCHC Gateway | Communicates via standard IP after SCHC decompression |

## Native architectural model

The native conceptual model of RFC 9011 defines a profile for executing Static Context Header Compression and Fragmentation (SCHC, RFC 8724) over LoRaWAN wireless networks. The architecture follows a star-of-stars topology typical of LPWAN deployments, comprising End Devices, LPWAN Radio Gateways (RGW / Gateway), a LPWAN Network Gateway (NGW / Network Server), a SCHC Gateway (LoRaWAN Application Server executing SCHC C/D and F/R), a LPWAN Join Server (LPWAN-AAA Server), and target Application Servers on the Internet.

In this model, the End Device is a constrained wireless host executing application flows over IPv6 or IPv6/UDP. To transmit data efficiently over the constrained LoRaWAN radio link, the End Device incorporates SCHC Compression/Decompression (SCHC C/D) and SCHC Fragmentation/Reassembly (SCHC F/R) functional layers. At the opposite end of the LoRaWAN network, the SCHC Gateway (Application Server) hosts matching SCHC C/D and SCHC F/R layers. The point-to-point IP link between the End Device and the SCHC Gateway constitutes a single IP hop, with the SCHC Gateway acting as the first-hop IP router for the End Device.

Communication over the LoRaWAN radio link relies on LoRaWAN MAC frames. Frames transmitted by an End Device (uplink) pass through one or more Radio Gateways (RGWs) to the Network Gateway (NGW). The NGW handles MAC-level validation, deduplication, and device addressing. Over the air, devices are addressed using a 32-bit network address (DevAddr), which is translated by the NGW into a unique 64-bit IEEE Device EUI (DevEUI). The NGW forwards the payload to the appropriate SCHC Gateway using the DevEUI as the device identifier.

SCHC payload framing over LoRaWAN is achieved by embedding the 8-bit SCHC RuleID directly into the LoRaWAN Frame Port (FPort) field. The SCHC C/D and F/R layers concatenate the 8-bit FPort with the LoRaWAN frame payload to recompose the full SCHC Message. Recommended default RuleIDs are allocated for specific functions: RuleID 20 (FPortUp) for uplink ACK-on-Error fragmentation, RuleID 21 (FPortDown) for downlink ACK-Always fragmentation, and RuleID 22 for uncompressed traffic fallback, with remaining values [1..219] available for compression rules.

To support multiple application servers, an End Device communicating with several distinct SCHC Gateways uses separate, non-overlapping sets of FPort values allocated for each SCHC Gateway instance. The set of rules and fragmentation parameters must be pre-provisioned and shared between the End Device and the corresponding SCHC Gateway prior to communication; dynamic context exchange is explicitly out of scope.

For IPv6 address generation, RFC 9011 specifies a cryptographic method to compute the 64-bit Interface Identifier (IID). The IID is derived by taking the first 64 bits of an AES-128-CMAC computed over the DevEUI using the LoRaWAN Application Session Key (AppSKey). Because AppSKey is re-keyed whenever the device completes a LoRaWAN join procedure, the IPv6 IID updates dynamically over time, mitigating location tracking and address scanning risks.

SCHC fragmentation over LoRaWAN operates with an L2 word size of 1 byte. Uplink fragmentation uses ACK-on-Error mode with a 2-byte SCHC header (FPort + 1 byte containing 2-bit window W and 6-bit tile index FCN), 10-byte tiles, 4-byte RCS, DTag size T=0, and recommended 12-hour retransmission/inactivity timers. Downlink fragmentation uses ACK-Always mode for unicast with a 10-bit header (FPort + 1-bit W + 1-bit FCN), variable tile size matching available MTU, DTag T=0, and device class-specific timers (Class A, B, C). Multicast downlink fragmentation uses No-ACK mode.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| End Device | Constrained physical node hosting SCHC processing | Endpoint hosting a single Instance | Direct | Aligned (Device-local) | Aligned (1:1) | None | Architectural role maps directly to Endpoint/Instance |
| SCHC Gateway | LoRaWAN Application Server executing SCHC C/D and F/R | Endpoint hosting SCHC Instance(s) | Direct | Aligned (Domain/Server) | Aligned (1:N or 1:1 per session) | None | Acts as SCHC Endpoint at network edge |
| SCHC C/D & F/R | Functional logic executing header compression and fragmentation | Instance / SCHC Functions | Direct | Aligned (Instance-local) | Aligned (1:1 per execution context) | None | Core SCHC processing engine within Endpoint |
| Device ↔ SCHC Gateway Association | Point-to-point communication path sharing a Context | Session | Direct | Aligned (Peer-pair / Session-local) | Aligned (1:1 per active path) | None | Implicit P2P Session without explicit signaling |
| LoRaWAN Network Domain | Administrative network boundary grouping devices and servers | Domain | Direct | Aligned (Domain-wide) | Aligned (1 Domain contains N Instances) | None | Managed by Domain Manager concepts |
| Set of Rules | Pre-provisioned rules for compression and fragmentation | Context / Set of Rules (SoR) | Direct | Aligned (Shared between Instances) | Aligned (1 Context shared per Session) | None | Defines SoR and optional Data Model/Parser |
| Fragmentation Timers & State | Retransmission/inactivity timers, window indices, ACK state | Set of Variables (SoV) | Direct | Aligned (Session-local) | Aligned (1 SoV per Session) | None | Runtime state managed per Session |
| DevEUI | 64-bit IEEE device identifier passed from NGW to SCHC Gateway | Discriminator | Direct | Aligned (Domain / Interface) | Aligned (1 DevEUI selects 1 Instance/Session) | None | Primary Discriminator for Dispatcher at SCHC Gateway |
| FPort | 8-bit LoRaWAN frame port field carrying RuleID (and selecting gateway set) | RuleID / Secondary Discriminator | Direct | Aligned (Datagram header) | Aligned (1 FPort ↔ 1 RuleID) | None | Carries RuleID; FPort range serves as Discriminator for multi-gateway |
| RuleID | 8-bit rule selector | RuleID | Direct | Aligned (Context-local) | Aligned (1 RuleID selects 1 Rule in SoR) | None | Direct 1:1 correspondence |
| IID Computation | Cryptographic derivation of IPv6 IID from AppSKey and DevEUI | Profile-specific mechanism / Variable | Profile-specific | Aligned (Session / Link-local) | Aligned (1 IID per Session lifetime) | None | Defined in technology profile per RFC 8724 App D |
| F/R Parameters (M, N, T, tiles) | Reliability modes and header parameterization | Profile-specific parameterization | Profile-specific | Aligned (Instance Configuration / Context) | Aligned (Fixed per profile direction) | None | Configured in Instance Configuration as per -06 Sec 5 |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Shared between End Device and SCHC Gateway prior to communication | Shared between Instances participating in a Session within a Domain | Fully Aligned | Pre-provisioned Context matches static deployment model |
| Ownership of Set of Rules | Part of shared Context; static during communication | Part of Context (SoR); immutable per Session | Fully Aligned | Compression and fragmentation rules remain synchronized |
| Ownership of Set of Variables | Runtime state (timers, retransmission counters, window state) maintained locally per direction | Runtime state (SoV) associated with a Session | Fully Aligned | Per-session runtime state is cleanly isolated |
| Endpoint↔SCHC Instance | 1:1 on End Device; 1:N on SCHC Gateway | Endpoint hosts 1 or more Instances | Fully Aligned | Architecture explicitly models single-Instance device and multi-Instance server |
| SCHC Instance↔Session | 1:1 on Device; 1:N or 1:1 per Device on SCHC Gateway | 1 Instance per Session or 1 shared Instance handling N Sessions | Fully Aligned | Tables 1 and 2 in -06 Appendix A.2.1 explicitly match both SCHC Gateway models |
| Sharing of Context between Sessions/Instances | Same Set of Rules used across all device sessions on a SCHC Gateway | Multiple Sessions/Instances can share the same Context/SoR | Fully Aligned | Context reusability across instances is fully supported |
| RuleID Scope | 8-bit value carried in FPort; unique within the pre-shared Context | Evaluated within the Context of the selected Instance | Fully Aligned | RuleID interpretation is strictly Context-scoped |
| Discriminator Scope | DevEUI (64-bit) at LPWAN/API interface; FPort range for multi-gateway routing | Used by Dispatcher to route Datagrams to the target Instance | Fully Aligned | DevEUI acts as primary Discriminator; FPort set acts as secondary Discriminator |
| Control Header processing scope | Not applicable (RFC 9011 carries RuleID directly in FPort without an extra Control Header) | Optional framing element for multiplexing/metadata | Not applicable | RFC 9011 requires no Control Header |
| Domain membership and boundaries | LoRaWAN network domain comprising Devices, NGW, and Application Servers | Logical grouping of Instances sharing a common set of Contexts | Fully Aligned | LoRaWAN network ecosystem maps directly to a SCHC Domain |

## Challenged mappings

No mapping classification changed during the adversarial pass.

## Architectural risk points

- **Risk:** Dual architectural role of LoRaWAN FPort as both RuleID carrier and Instance Discriminator in multi-gateway deployments.
  - **Why it matters:** When an End Device communicates with multiple SCHC Gateways, FPort values are partitioned into distinct ranges per gateway. In this scenario, the FPort value serves both as an input to the Dispatcher (to select the SCHC Gateway Instance) and as the RuleID (to select the Rule within the Instance's Context).
  - **Consequence for migration:** In the migration text, FPort must be explicitly described as carrying the RuleID, while noting that its value range may function as a secondary Discriminator element for the Dispatcher when extrinsic lower-layer context (such as DevEUI alone) is insufficient to disambiguate target Instances.

- **Risk:** Dynamic re-derivation of IPv6 Interface Identifier (IID) upon LoRaWAN rejoin events.
  - **Why it matters:** RFC 9011 derives the IPv6 IID dynamically using AES-CMAC over DevEUI with AppSKey, which changes every time the device rejoins the network. While SCHC Contexts are static, the effective IPv6 IID update is driven by L2 session key rotation.
  - **Consequence for migration:** The IID derivation algorithm must be clearly classified as a technology profile execution rule and Session variable (SoV) update, ensuring implementers do not confuse dynamic IID updates with static Context modifications.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3, Figure 1 & Figure 2 | Legacy LPWAN architecture block diagrams showing SCHC C/D and F/R blocks | Update architectural narrative and figures to explicitly reference SCHC Endpoints, Instances, Sessions, and Domains | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns RFC 9011's overview diagrams with SCHC Architecture -06 structural concepts |
| 2 | Section 4, intro & sub-sections | References to LPWAN entities mapped to RFC 8724 terms | Reframe mapping to state that End Device acts as SCHC Endpoint/Instance, SCHC Gateway acts as SCHC Endpoint/Instance, DevEUI acts as Discriminator, and device-gateway path acts as Session | REQUIRED FOR TERMINOLOGY MIGRATION | Establishes explicit alignment with SCHC Architecture -06 terminology |
| 3 | Section 5.1 & 5.2 | "LoRaWAN FPort and RuleID" / RuleID management | Clarify that FPort carries the 8-bit RuleID within the SCHC Datagram, and that non-overlapping FPort ranges act as a secondary Discriminator for Instance selection in multi-gateway deployments | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves potential confusion regarding FPort's dual role as RuleID and Discriminator |
| 4 | Section 5.6 & sub-sections | Description of fragmentation timers and window state | Clarify that runtime fragmentation parameters, timers, and window indices constitute the Set of Variables (SoV) associated with the SCHC Session | REQUIRED FOR TERMINOLOGY MIGRATION | Maps runtime fragmentation state to -06 Set of Variables (SoV) concept |
| 5 | Section 1, Introduction | Reference to RFC 8724 alone | Add informative reference to draft-ietf-schc-architecture-06 for architectural framing | OPTIONAL CLARIFICATION | Provides readers with direct reference to the overarching SCHC Architecture |
| 6 | Section 2, Terminology | List of terms from RFC 8724 | Add definitions for Endpoint, Instance, Session, Domain, Discriminator, Dispatcher, SoR, and SoV from SCHC Architecture -06 | OPTIONAL CLARIFICATION | Ensures self-contained terminology consistency within the document |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|

No modification to SCHC Architecture -06 is required.

## Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? The single most important migration issue is updating Sections 3, 4, and 5 of RFC 9011 to systematically adopt SCHC Architecture -06 terminology (Endpoint, Instance, Session, Domain, Discriminator, Dispatcher, Set of Rules, Set of Variables) and clarifying the dual role of the LoRaWAN FPort field as both the RuleID carrier and a secondary Discriminator element in multi-gateway topologies.

No modification to SCHC Architecture -06 is required.
