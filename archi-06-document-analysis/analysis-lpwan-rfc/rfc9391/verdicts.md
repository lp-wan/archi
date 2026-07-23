# Architectural alignment review: rfc9391

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All concepts, functional roles, processing layers, and parameter constraints in RFC 9391 map naturally and directly to SCHC Architecture -06 concepts (Endpoint, Instance, Session, Stratum, Context, Discriminator, Dispatcher, Profile) without requiring technical reinterpretation or architectural reframing. |
| Transition difficulty | Easy | A Very Easy transition applies to purely mechanical string replacements. Updating RFC 9391 requires localized rewriting across multiple sections to introduce -06 concepts (Endpoint, Instance, Stratum, Session, Discriminator) and clarify layer placement and dispatching. | The architectural mapping decisions across all sections of RFC 9391 are clear, direct, and repeatable. No section requires complex architectural judgment or redesign of protocol behavior. |
| SCHC Architecture adaptation need | None | Zero ARCHITECTURE GAP items were identified. SCHC Architecture -06 already contains all required concepts (including Stratum for layer placement, Instance Configuration for feature selection, and Dispatcher/Discriminator for routing) needed to express RFC 9391 naturally. | Lowest grade |

## Executive assessment
SCHC Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally, fully, and elegantly express all technical concepts, architectural roles, deployment scenarios, and protocol parameters defined in RFC 9391 ("Static Context Header Compression over Narrowband Internet of Things"). 

The principal conceptual mapping maps 3GPP physical/functional nodes (Dev-UE, Application Server, RGW-eNB, NGW-MME) to SCHC **Endpoints**, which host SCHC **Instances** operating at specific **Strata** (Application/NIDD layer, PDCP layer for Radio Link, and NAS layer for DoNAS). Communications between peer Instances constitute SCHC **Sessions** within a 3GPP operator **Domain**. 3GPP bearer IDs, IP tunnels, and northbound API calls provide lower-layer metadata used as **Discriminators** by the **Dispatcher** to route SCHC Datagrams to the correct Instance. Technology-specific parameters (L2 Word = 8 bits, MAX_PACKET_SIZE = 1358/1600 bytes, RuleID sizes 2–8 bits, tile sizes, and timers) form a standard **SCHC Profile** for NB-IoT.

The principal migration difficulty is rated **Easy**. While the technical model remains 100% stable, migrating RFC 9391 to -06 terminology requires localized rewriting across Sections 3, 4, 5, 5.1.1, 5.2.1, 5.2.2, 5.2.3, and Appendices to replace generic "SCHC entity" references with explicit SCHC Endpoints, Instances, Strata, Sessions, and Dispatchers.

No SCHC Architecture -06 gap exists (adaptation need is **None**). -06 already includes all necessary architectural abstractions—most notably the concept of **Stratum** (to capture SCHC operation at PDCP, NAS, or Application layers) and **Instance Configuration** (to express enabling C/D while disabling F/R when RLC handles segmentation).

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Dev-UE | Device User Equipment (mobile terminal) | User Equipment / Device | Endpoint node | IMEI, IMSI, MSISDN, IP address, Bearer ID | 1 per physical device; communicates 1:1 or 1:N | May act as simple sensor or capillary gateway. |
| Application Server (AS) | Remote end-to-end application destination | External Network / Application | End-to-end peer node | IP address, URI, API endpoint ID | 1 per application service; communicates with N Dev-UEs | Terminating node for end-to-end NIDD SCHC. |
| SCHC Entity (NIDD) | Application-layer header compressor/fragmenter | Dev-UE & AS Application Layer | End-to-end peer pair (Dev-UE <-> AS) | RuleID (2-8 bits), IP Tunnel / API Context | 1 pair per end-to-end application flow | Operates over transparent NIDD pipe. |
| SCHC Entity (Radio Link) | PDCP-layer header compressor | Dev-UE & RGW-eNB PDCP Layer | Radio Link (Dev-UE <-> RGW-eNB) | Radio Bearer ID / LCID, RuleID (2-8 bits) | 1 pair per active radio bearer | F/R disabled (delegated to RLC). |
| SCHC Entity (DoNAS) | NAS-layer header compressor | Dev-UE & NGW-MME NAS Layer | Control Plane (Dev-UE <-> NGW-MME) | NAS Security Context ID, RuleID (2-8 bits) | 1 pair per NAS signaling association | F/R disabled (delegated to RLC/RRC). |
| RGW-eNB | Radio Gateway - evolved Node B (Base Station) | 3GPP Radio Access Network (RAN) | Link-local radio access node | eNB ID, Cell ID | 1 eNB serves multiple UEs | Hosts network-side SCHC entity for Radio Link. |
| NGW-MME | Mobility Management Entity in core network | 3GPP Core Network (EPC) | Control plane domain node | MME ID, MME Code/Group | 1 MME serves multiple UEs/eNBs | Hosts network-side SCHC entity for DoNAS. |
| NGW-SCEF | Service Capability Exposure Function | 3GPP Core Network Edge | Operator boundary / API gateway | SCEF ID, API Endpoint ID | 1 SCEF serves multiple ASs/UEs | Relays NIDD traffic via APIs or IP tunnels. |
| NGW-PGW | Packet Data Network Gateway | 3GPP Core Network Edge | Core network edge node | APN, PGW IP address | 1 PGW serves multiple UEs/ASs | Relays NIDD traffic via IP tunneling. |
| Static Context | Pre-installed rules and parameter tables | Co-located with SCHC entities | Peer pair / Session | Context ID, RRC Config Index | Shared between peer SCHC entities | App-provisioned (NIDD) or RRC-provisioned (Radio/DoNAS). |
| RuleID | Header field selecting matching rule | SCHC Datagram header | Context / Session | 2 to 8 bits | 1 per SCHC Datagram | Sized 2 to 8 bits for NB-IoT. |
| MAX_PACKET_SIZE | Maximum MTU size for SCHC datagrams | SCHC parametrization | Deployment / Session | 1358 bytes (NIDD) / 1600 bytes (Radio/DoNAS) | 1 constant per scenario | 1358 B avoids backbone fragmentation. |
| SCHC Fragmentation | Optional F/R functions and parameters | SCHC entity | Peer pair / Session | RuleID, DTag, FCN, W, RCS, MAX_ACK_REQ | Configured per profile | Enabled in NIDD; disabled in Radio & DoNAS. |
| L2 Word & Padding | Alignment unit (8 bits) and padding rule | Framing logic | Deployment wide | Fixed constant = 8 bits | 1 per profile | NB-IoT requires byte alignment. |

## Native architectural model

RFC 9391 specifies the application and integration of Static Context Header Compression and fragmentation (SCHC), as defined in RFC 8724 and RFC 8824, within 3rd Generation Partnership Project (3GPP) Narrowband Internet of Things (NB-IoT) networks. The document addresses the challenges of transporting IP and non-IP traffic over highly constrained cellular radio links and core network architectures.

The document is structured into two distinct architectural parts: a normative part specifying end-to-end SCHC operation over 3GPP Non-IP Data Delivery (NIDD) services, and an informational part describing potential integration of SCHC into internal 3GPP protocol layers (specifically the Radio Link PDCP layer and the Non-Access Stratum signaling layer).

In the normative NIDD scenario, SCHC entities reside at the application layer within the Device User Equipment (Dev-UE) and the Application Server (AS). The 3GPP cellular infrastructure (including radio access, core mobility management, and exposure gateways) functions strictly as a transparent Layer 2 transport mechanism. Compression and optional fragmentation occur end-to-end prior to submission to the 3GPP network. Consequently, intermediate 3GPP network nodes do not possess context information or parse SCHC headers, treating all SCHC payloads as generic Non-IP data.

NIDD packets are delivered between the 3GPP core network edge and the Application Server using either IP tunneling (via the Network Gateway Packet Data Network Gateway, NGW-PGW) or northbound RESTful API calls / IP tunneling (via the Network Gateway Service Capability Exposure Function, NGW-SCEF). Static context initialization for NIDD is managed directly by the application layer, potentially utilizing initial IP bootstrap transmissions prior to switching to compressed NIDD transport.

In the informational Radio Link scenario, SCHC header compression is integrated into the Packet Data Convergence Protocol (PDCP) sublayer of the 3GPP User Plane radio stack between the Dev-UE and the Radio Gateway evolved Node B (RGW-eNB). This positioning mirrors the placement of Robust Header Compression (ROHC, RFC 5795) in standard 3GPP architectures. Static context configuration and lifecycle management are controlled via 3GPP Radio Resource Control (RRC) signaling.

In the informational Data over Non-Access Stratum (DoNAS) scenario, SCHC header compression is integrated into the Non-Access Stratum (NAS) control-plane protocol layer between the Dev-UE and the Network Gateway Mobility Management Entity (NGW-MME). DoNAS allows small user data payloads to be piggybacked directly within NAS signaling messages, avoiding the overhead of establishing full Access Stratum security and user-plane radio bearers.

A key architectural distinction between the NIDD and internal 3GPP scenarios lies in the use of SCHC fragmentation. In the NIDD scenario, end-to-end SCHC fragmentation (using No-ACK or ACK-on-Error modes) is enabled for packets exceeding the recommended 3GPP backbone MTU of 1358 bytes. Conversely, in the Radio Link and DoNAS scenarios, SCHC fragmentation is explicitly disabled because the underlying 3GPP Radio Link Control (RLC) sublayer inherently provides reliable segmentation, reassembly, and ARQ in Acknowledged Mode (AM) or Unacknowledged Mode (UM).

RFC 9391 defines technology-specific parameter constraints tailored to NB-IoT physical transport characteristics. The L2 Word size is defined as 8 bits (1 octet) to match 3GPP byte-alignment requirements. RuleID field sizes are specified as configurable from 2 bits (yielding 4 rules for ultra-constrained single-purpose devices) up to 8 bits (yielding 256 rules for complex multi-protocol devices or capillary gateways). Specific 8-bit and 16-bit fragmentation header structures are recommended based on whether physical Transport Block (TB) sizes are below or above 304 bits.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Dev-UE | Device User Equipment hosting SCHC application or stack layer | Endpoint | Direct | Node-local / Endpoint-local | 1 Dev-UE = 1 Endpoint hosting 1 or more Instances | None | Simple Dev-UE hosts 1 Instance; capillary gateway Dev-UE hosts multiple Instances. |
| Application Server (AS) | Remote application endpoint communicating with Dev-UE over NIDD | Endpoint | Direct | Node-local / Endpoint-local | 1 AS = 1 Endpoint hosting N Instances | None | Acts as peer SCHC Endpoint for end-to-end NIDD scenario. |
| RGW-eNB | Radio Base Station hosting network-side PDCP SCHC layer | Endpoint | Direct | Node-local (RAN Base Station) | 1 eNB = 1 Endpoint hosting N Instances | None | Network-side Endpoint for Radio Link informational scenario. |
| NGW-MME | Core network node hosting network-side NAS SCHC layer | Endpoint | Direct | Node-local (Core Network Node) | 1 MME = 1 Endpoint hosting N Instances | None | Network-side Endpoint for DoNAS informational scenario. |
| SCHC Entity (NIDD) | Application-layer compressor/decompressor and fragmenter | Instance | Direct | Peer-pair / Session scope | 1 Instance per Dev-UE app flow on Dev-UE and AS | None | Stratum = Application / IP payload. Executes C/D and F/R functions. |
| SCHC Entity (Radio Link) | PDCP-layer header compressor/decompressor | Instance | Direct | Link-local (Dev-UE <-> eNB) | 1 Instance per radio bearer on Dev-UE and eNB | None | Stratum = PDCP layer. C/D enabled, F/R disabled in Instance Configuration. |
| SCHC Entity (DoNAS) | NAS-layer header compressor/decompressor | Instance | Direct | Control-plane link (Dev-UE <-> MME) | 1 Instance per NAS control association | None | Stratum = NAS layer. C/D enabled, F/R disabled in Instance Configuration. |
| Application / PDCP / NAS Layer | Protocol stack layer targeted by SCHC | Stratum | Direct | Layer-scope within protocol stack | 1 Stratum per Instance | None | RFC 9391 defines SCHC operation at 3 distinct layers, exactly matching -06 Stratum. |
| End-to-end or peer communication | Active communication between SCHC entities sharing a Context | Session | Direct | Session scope (between Instances) | 1 Session between 2 Instances | None | NIDD Session (Dev-UE <-> AS), Radio Session (Dev-UE <-> eNB), NAS Session (Dev-UE <-> MME). |
| Static Context | Set of Rules and metadata shared between peer SCHC entities | Context | Direct | Shared between Instances in a Session | 1 Context per Session/Instance pair | None | In NIDD, provisioned by app layer; in Radio/DoNAS, provisioned via RRC. |
| RuleID | Header field selecting matching rule | RuleID | Direct | Context / Session scope | 1 RuleID per SCHC Datagram (2..8 bits) | None | Configurable field size (2 to 8 bits) as permitted by -06 and RFC 8724. |
| 3GPP Network / Operator Domain | Administrative network boundary managing context and bearers | Domain | Direct | Administrative / Operator domain | 1 Domain contains multiple Endpoints and Instances | None | Managed via Domain Manager / Instance Manager concepts. |
| NIDD IP Tunnel / API Call / 3GPP Bearer ID | Multiplexing metadata used to deliver packets to correct SCHC entity | Discriminator | Direct | Transmission / Dispatcher scope | 1 Discriminator value per Session / Instance routing decision | None | Dispatcher uses external 3GPP context (bearer ID, tunnel ID, API session) to route datagrams to Instance. |
| NIDD / Radio Link / DoNAS parametrization | Technology-specific operational rules, MTUs, and fragment parameters | SCHC Profile / Instance Configuration | Profile-specific | Deployment / Profile scope | 1 Profile per 3GPP deployment scenario | None | Follows -06 Section 5 deployment profile model (L2 Word = 8 bits, MAX_PACKET_SIZE, RuleID size, etc.). |
| Disabling SCHC Fragmentation in Radio Link & DoNAS | Choice to delegate packet segmentation to RLC sublayer | Instance Configuration | Profile-specific | Instance scope | 1 Configuration setting per Instance | None | -06 Section 4.2.1.1 explicitly allows Instance Configuration to specify required SCHC features (C/D only). |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Shared between peer SCHC entities (Dev-UE & AS/eNB/MME) | Shared between Instances participating in a Session within a Domain | Full alignment | Context is stored in Instances and provisioned via app/RRC (Domain/Instance Manager). |
| Ownership of Set of Rules (SoR) | Part of Static Context shared between peer entities | Part of Context associated with an Instance | Full alignment | SoR defines C/D and F/R rules for the Instance. |
| Ownership of Set of Variables (SoV) | Maintained per active SCHC connection (e.g. fragmentation state, timers) | Maintained per Session within an Instance | Full alignment | In NIDD F/R, SoV tracks retransmission timers, window counters, etc. |
| Endpoint ↔ SCHC Instance | 1 Dev-UE host has 1 (simple) or multiple (capillary gateway/multi-strata) SCHC entities | 1 Endpoint can host 1 or multiple Instances | Full alignment | Natural mapping for both simple IoT devices and complex gateway nodes. |
| SCHC Instance ↔ Session | 1 SCHC entity pair handles 1 communication flow | Instances interact via a Session | Full alignment | 1:1 relationship for point-to-point NIDD, Radio, or NAS flows. |
| Context sharing | Context shared between Dev-UE and network/app peer | Context shared across Instances in a Session within a Domain | Full alignment | No unauthorized cross-session leakage; scope is clear. |
| RuleID scope | Unique within static context (2-8 bits) | Unique within Context / Session | Full alignment | Standard SCHC RuleID scoping. |
| Discriminator scope | Derived from 3GPP bearer ID, IP tunnel, or API session ID | Used by Dispatcher to route datagrams to correct Instance | Full alignment | External 3GPP context naturally acts as Discriminator for the Dispatcher. |
| Control Header scope | Not explicitly used in RFC 9391 (standard SCHC header suffices) | Optional header for advanced routing/metadata | Full alignment | RFC 9391 does not require Control Headers; standard SCHC framing is sufficient. |
| Domain membership & boundaries | 3GPP operator network and associated application servers | Logical grouping of Instances sharing Contexts under a Domain Manager | Full alignment | 3GPP management system acts as Domain Manager / Instance Manager. |

## Challenged mappings

No mapping classification changed during the adversarial pass.

## Architectural risk points

- **Risk:** Ambiguity between 3GPP physical/functional node identity and SCHC Endpoint/Instance identity.
  - **Why it matters:** In 3GPP terminology, Dev-UE, RGW-eNB, NGW-MME, and NGW-PGW are network nodes with 3GPP-specific identifiers (IMEI, eNB ID, MME ID). Implementers might equate a 3GPP node directly to a single SCHC entity, missing that a single 3GPP node can host multiple SCHC Instances operating across different strata (e.g., PDCP, NAS, or Application) or serving multiple peers.
  - **Consequence for migration:** The migrated text must clearly explain that 3GPP nodes act as SCHC Endpoints that host SCHC Instances, each executing specific SCHC operations at a defined Stratum.

- **Risk:** Conflation of simple device topology with Capillary Gateway multi-instance operation.
  - **Why it matters:** RFC 9391 covers both simple NB-IoT end-devices (single application flow) and capillary gateways (aggregating multiple local devices/protocols). Capillary gateways require larger RuleID spaces (up to 8 bits) and multiple SCHC rule sets/Instances.
  - **Consequence for migration:** The migration framing should explicitly show how a capillary gateway acts as an Endpoint hosting multiple Instances (or handling multiple Sessions), where the Dispatcher uses protocol/device metadata as a Discriminator.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3 | Terminology defined according to RFC 8724, RFC 8376, TR 23.720 | Add definitions for SCHC Endpoint, SCHC Instance, Session, Domain, Stratum, Discriminator, and Dispatcher referencing draft-ietf-schc-architecture-06 | REQUIRED FOR TERMINOLOGY MIGRATION | Establishes explicit alignment with SCHC Architecture -06 terminology base. |
| 2 | Section 5 | SCHC entities placed in Dev-UE, RGW-eNB, NGW-CSGN | Frame Dev-UE, RGW-eNB, NGW-MME, and Application Server as SCHC Endpoints hosting SCHC Instances | REQUIRED FOR CONCEPTUAL ALIGNMENT | Clarifies distinction between 3GPP physical/functional nodes and logical SCHC processing entities. |
| 3 | Section 5.1.1 & 5.1.1.1 | SCHC entities placed almost on top of the stack for NIDD | Define NIDD as an end-to-end SCHC Session between Dev-UE Instance and AS Instance at the Application Stratum | REQUIRED FOR CONCEPTUAL ALIGNMENT | Uses the formal Stratum and Session concepts from -06. |
| 4 | Section 5.1.1.1 | Transmission using IP tunneling or SCEF API calls | Specify IP tunnel IDs or API session metadata as Discriminators used by the Dispatcher | REQUIRED FOR TERMINOLOGY MIGRATION | Connects lower-layer 3GPP transport delivery to -06 Dispatcher/Discriminator architecture. |
| 5 | Section 5.2.1 & 5.2.1.1 | Placing SCHC entities in PDCP sublayer | Define Radio Link SCHC as an Instance hosted in Dev-UE and RGW-eNB Endpoints at the PDCP Stratum, with F/R disabled in Instance Configuration | REQUIRED FOR CONCEPTUAL ALIGNMENT | Expresses PDCP layer operation as a Stratum and F/R bypass as an Instance Configuration parameter. |
| 6 | Section 5.2.2 & 5.2.2.1 | Placing SCHC entities in NAS layer | Define DoNAS SCHC as an Instance hosted in Dev-UE and NGW-MME Endpoints at the NAS Stratum, with F/R disabled in Instance Configuration | REQUIRED FOR CONCEPTUAL ALIGNMENT | Expresses NAS layer operation as a Stratum and F/R bypass as an Instance Configuration parameter. |
| 7 | Section 5.1.1.2 & 5.2.3 | Parameter descriptions for SCHC over NB-IoT | Frame parameter sets (L2 Word = 8 bits, MAX_PACKET_SIZE, RuleID size, timers) as a SCHC Profile for NB-IoT | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns parametrization with -06 Section 5 (Deployment Profiles). |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? Framing 3GPP nodes as SCHC Endpoints hosting SCHC Instances operating at distinct Strata (NIDD/Application, Radio Link/PDCP, and DoNAS/NAS) with clear Discriminator/Dispatcher routing.

No modification to SCHC Architecture -06 is required.
