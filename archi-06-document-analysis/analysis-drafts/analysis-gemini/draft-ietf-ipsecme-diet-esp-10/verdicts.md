# Architectural alignment review: draft-ietf-ipsecme-diet-esp-10

## Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | High | The multi-stage pipelining of three separate compressors (IIPC, CTEC, EEC) with encryption interleaved between them is not a standard single-stage SCHC model, requiring explicit interpretation as coordinated SCHClets within a single Instance. Additionally, the elision of the RuleID and the trial-decryption routing represent minor conceptual shifts. | Almost all core concepts (rules, field descriptors, MSB/LSB operators, static context, field parsing) map naturally to the SCHC model, and the technical behavior remains completely expressible. |
| **Transition difficulty** | Easy | It requires non-trivial architectural mapping decisions, such as modeling the three compressors as SCHClets, and rewriting sections describing context ownership to align with the IPsec SA model. | The required edits are highly localized, clear, and repeatable, and do not require changing the underlying protocol flow or encryption mechanisms. |
| **SCHC Architecture adaptation need** | Trivial | The core concepts of SCHC Architecture -06 (Instance, Context, Session, Rule, SCHClet) remain fully stable and do not need to be redesigned. | The normative statement "A Datagram starts with a RuleID" and the role of the Dispatcher as a simple routing engine are too restrictive for Diet-ESP, requiring explicit additive clarifications. |

## Executive assessment
SCHC Architecture -06 can naturally express the technical model of `draft-ietf-ipsecme-diet-esp-10` with minor clarifications. The principal conceptual mapping involves representing the three Diet-ESP compressors (IIPC, CTEC, EEC) as coordinated SCHClets within a single SCHC Instance owned by the IPsec Security Association (SA). The principal migration difficulty lies in updating the terminology to use SCHC Architecture -06 terms consistently and handling the elision of the RuleID and trial-decryption demultiplexing. Two trivial architecture gaps exist in -06 regarding: (1) allowing the RuleID to be implicit (elided) when uniquely determined by out-of-band context (like the SA), and (2) clarifying that the Dispatcher may delegate routing to the security stack to perform trial decryption when the Discriminator is compressed and ambiguous.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **Inner IP packet (IIP)** | The original IP packet to be protected by ESP. | End Host / Network Stack | End-to-end (local to the endpoints) | Traffic Selectors (TS) | Many IIPs map to one SA. | Composed of Inner IP header and transport header/payload. |
| **Clear Text ESP Packet (CTE)** | The plaintext packet containing the payload data (including the IIPC-processed packet), ESP Padding, Pad Length, and Next Header. | ESP layer | Local to the ESP processing engine | Derived from SA | 1:1 with ESP packet. | Subject to CTEC compression. |
| **Encrypted ESP Packet (EE)** | The encrypted payload (CTE encrypted) preceded by the ESP Header (SPI and SN) and followed by the ICV. | ESP layer / IPsec stack | Transmitted over the wire | SPI | 1:1 with ESP packet. | Subject to EEC compression. |
| **Security Association (SA)** | The shared cryptographic and compression state between the peers. | IPsec stack / Security Association Database (SAD) | Unidirectional peer-pair communication | SPI (+ IP addresses) | 1 per direction of communication; owns 1 IIPC rule, 1 CTEC rule, 1 EEC rule. | Binds the SCHC Context to the IPsec state. |
| **Attributes for Rules Derivation (AfRD)** | The negotiated parameters defining compression behavior. | IKEv2 / SAD | Per SA | Negotiated via IKEv2 | 1 set per SA. | Used to dynamically construct the rules (SoR) rather than using pre-provisioned static rules. |
| **IIPC Rule** | The SCHC-like rule derived from AfRD to compress/decompress the IIP header. | IIPC / SA | Per SA | Implicit or optional RuleID | 1 per SA. | Focuses on Inner IP and transport headers. |
| **CTEC Rule** | The SCHC-like rule derived from AfRD to compress/decompress the ESP trailer. | CTEC / SA | Per SA | Implicit or optional RuleID | 1 per SA. | Focuses on ESP Padding, Pad Length, and Next Header. |
| **EEC Rule** | The SCHC-like rule derived from AfRD to compress/decompress the ESP header (SPI, SN). | EEC / SA | Per SA | Implicit or optional RuleID | 1 per SA. | Focuses on SPI and Sequence Number (SN). |
| **Security Parameter Index (SPI)** | The identifier of the SA. | ESP Header | Receiver-local uniqueness | SPI (32-bit) | 1 SPI per SA. | Can be compressed (LSB), causing potential lookup ambiguity. |
| **Sequence Number (SN)** | Replay protection counter. | ESP Header | Per SA | SN (32-bit) | Monotonically increasing per packet. | Can be compressed (LSB). |

## Native architectural model
Diet-ESP specifies a compression mechanism for control information in IPsec/ESP communications. It operates within the IPsec/ESP protocol stack and introduces three distinct compressors that are applied at different stages of the outbound and inbound packet processing pipelines.

First, the **Inner IP Compression (IIPC)** compressor targets the original Inner IP packet (IIP) before it is encapsulated by ESP. In tunnel mode, it compresses the inner IP and transport headers (such as UDP or TCP). In transport mode, it only compresses the transport header. The IIP is split into a Header and a Payload; the Header is compressed using the derived IIPC rule and byte-aligned, and the Payload is then appended.

Second, the **Clear Text ESP Compression (CTEC)** compressor compresses the plaintext fields that will be encrypted. This includes the ESP Payload Data and the ESP Trailer (Padding, Pad Length, Next Header). CTEC focuses on compressing or eliding the Padding, Pad Length, and Next Header fields based on the Security Association (SA) configuration and alignment requirements.

Third, the **Encrypted ESP Compression (EEC)** compressor compresses the unencrypted fields of the Encrypted ESP packet (specifically the SPI and SN in the ESP Header). Since these fields are visible on the wire after encryption, they are compressed using the Least Significant Bits (LSB) technique.

The context and rules used by these compressors are not statically pre-provisioned on the endpoints. Instead, they are dynamically derived from the **Attributes for Rules Derivation (AfRD)**. These attributes are negotiated between the peers via IKEv2 when the Security Association (SA) is established. Once negotiated, the derived rules remain static for the lifetime of that SA.

For inbound packets, the receiver must perform SA lookup using the incoming SPI. If the SPI is compressed by EEC, the lookup is potentially ambiguous. The receiver must identify candidate SAs that match the received LSB bits and perform trial decryption and signature verification to determine the correct SA and reconstruct the full SPI and Sequence Number.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **IIP** | Input packet to be compressed | Input Packet (Inner IP Stratum) | Direct | Aligned | Aligned | None | The target of the first compression stage. |
| **IIPC** | Inner IP compressor | SCHClet / Instance | Composite | Aligned | Aligned | IIPC separates the packet into Header and Payload before running SCHC compression on the Header, which is a profile-specific pre-processing step. | Can be modeled as a SCHClet within the SA Instance. |
| **CTEC** | Clear Text ESP compressor | SCHClet / Instance | Composite | Aligned | Aligned | Operates on trailer fields rather than headers, eliding or computing them based on alignment rules. | Can be modeled as a SCHClet within the SA Instance. |
| **EEC** | Encrypted ESP compressor | SCHClet / Instance | Composite | Aligned | Aligned | Operates on outer header fields (SPI, SN) that are also used for context lookup. | Can be modeled as a SCHClet within the SA Instance. |
| **SA** | Security Association holding keys and compression attributes | Session / Context | Composite | Aligned | Unidirectional vs Bi-directional | The SA is unidirectional, whereas a SCHC Session/Context is typically bi-directional, but can support unidirectional flow. | Binds the SCHC Context to the IPsec state. |
| **AfRD** | Negotiated parameters to derive rules | Set of Variables (SoV) / Config | Profile-specific | Aligned | Aligned | Used to dynamically construct the Rules (SoR) rather than just parameterizing static rules. | Negotiated via IKEv2. |
| **RuleID** | Rule selector | RuleID | Direct | Aligned | Aligned | RuleID is elided (implicit) on the wire, which is not explicitly covered in -06. | Requires architectural clarification in -06. |
| **SPI** | Security Parameter Index | Discriminator | Composite | Partial | Unidirectional | SPI LSB can be ambiguous, requiring trial decryption by the IPsec stack instead of simple Dispatcher routing. | Requires architectural clarification in -06. |
| **SN** | Sequence Number | Field Value (LSB compressed) | Direct | Aligned | Aligned | None | Reconstructed at receiver using LSB. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Owned by the Security Association (SA), which is unidirectional and managed by the IPsec stack. | Shared by two or more Instances participating in a Session. | Aligned | The SA represents the unidirectional session state between the peer instances, binding the context. |
| **Ownership of Set of Rules (SoR)** | Derived dynamically from AfRD in the SA. | Part of the Context. | Aligned | Rules are generated programmatically upon SA establishment but remain static for the SA's lifetime. |
| **Ownership of Set of Variables (SoV)** | Managed by the SA (sequence numbers, encryption state, padding details). | Runtime parameters and session variables per Session. | Aligned | Runtime state matches the session parameters. |
| **Endpoint ↔ SCHC Instance** | Endpoint is the IPsec-enabled host. Instance is the SA processing context (or the set of IIPC, CTEC, EEC SCHClets for that SA). | Endpoint hosts one or more Instances. | Aligned | An IPsec host can run multiple SAs, mapping to multiple Instances. |
| **SCHC Instance ↔ Session** | 1:1 mapping between SA and the unidirectional communication session. | A Session is a communication session between Instances sharing a Context. | Aligned | Matches the unidirectional flow of an SA. |
| **Sharing of Context between Sessions/Instances** | Different SAs could derive rules from the same base AfRD, but each SA maintains independent rules/state. | Context can be shared by multiple Instances/Sessions. | Profile-specific | Diet-ESP constrains sharing to preserve security boundaries between SAs. |
| **RuleID scope** | Unique within the SA context (often implicit/elided). | Unique within the Context/SoR. | Aligned | Since there is a unique rule per compressor per SA, RuleID can be elided. |
| **Discriminator scope** | The SPI (or SPI LSB) serves as the Discriminator. | Discriminator routes Datagrams to Instances. | Partial | SPI LSB can be ambiguous, requiring trial decryption. The Dispatcher must delegate to the security stack. |
| **Control Header processing scope** | Not applicable (no separate Control Header is used; SPI/SN residues are carried in the outer ESP header). | Control Header carries multiplexing/protection/metadata. | Not applicable | No Control Header is required. |
| **Domain membership and boundaries** | Domain is the set of hosts sharing the security and key management policies (connected via IKEv2). | Domain is a logical grouping of Instances sharing Contexts. | Aligned | Aligned with the IKEv2 administrative domain. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk:** SPI LSB Collision and Computational Exhaustion (DoS)
- **Why it matters:** When the SPI is compressed (using EEC LSB), multiple SAs can share the same LSB value. The receiver's Dispatcher cannot uniquely route the packet to the correct Instance, forcing the receiver to perform trial decryption and signature verification for all candidate SAs. A malicious actor can flood the receiver with random packets matching a compressed SPI LSB, forcing the receiver to perform expensive cryptographic operations on many SAs, leading to CPU exhaustion.
- **Consequence for migration:** The draft must highlight this risk and recommend deterministic or collision-free SPI assignment, or limit the use of extreme SPI compression in hostile environments.

- **Risk:** RuleID Elision Mismatch
- **Why it matters:** Implementations conforming strictly to SCHC Architecture -06 expect a RuleID at the start of the Datagram. If Diet-ESP elides the RuleID, standard SCHC parsers will fail or misinterpret the first byte of the payload as a RuleID.
- **Consequence for migration:** The integration between the ESP stack and the SCHC C/D engine must be custom-tailored, and standard SCHC implementations cannot be used without modification to support implicit RuleIDs.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 2.2 / 4.1 | "The RuleID in Diet-ESP is expressed as 1 byte but it can be elided as there is a unique Rule determined for the compressors." | Clarify that when the RuleID is elided, the RuleID is implicit and resolved via the SA context, aligning with the SCHC Architecture's concept of implicit rule selection. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Ensures compatibility with the SCHC Architecture's definition of Datagram framing. |
| 2 | Section 2.1 | "The document outlines the three compressors utilized in Diet-ESP..." | Clarify that the three compressors (IIPC, CTEC, EEC) can be modeled as three coordinated SCHClets within a single SCHC Instance associated with the SA. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Aligns the multi-stage pipelining model with the SCHC Architecture's Instance and SCHClet concepts. |
| 3 | Throughout the draft | Various mentions of "Diet-ESP context", "compression rules", "peer context". | Update terminology to use SCHC Architecture -06 terms consistently (e.g., "SCHC Context", "SCHC Rules", "Session"). | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns vocabulary with the reference architecture. |
| 4 | Section 9 | Security Considerations regarding SPI. | Elaborate on the security implications of SPI compression and the potential for DoS via trial decryption, suggesting strategies to mitigate SPI collisions. | OPTIONAL CLARIFICATION | Improves the security considerations section without changing technical behavior. |
| 5 | References | Informative reference to `draft-ietf-schc-architecture-05`. | Update reference to `draft-ietf-schc-architecture-06` (or later). | EDITORIAL | Updates outdated reference. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.5 | RuleID presence | "A Datagram starts with a RuleID. The Rule identified by that RuleID determines the format and interpretation of the remaining bits." | "A Datagram starts with a RuleID, which determines the format and interpretation of the remaining bits. In some profiles or deployments where the Rule is uniquely determined by out-of-band context (e.g., a Security Association or a dedicated point-to-point connection), the RuleID may be elided on the wire and treated as implicit." | ARCHITECTURE GAP | Diet-ESP elides the RuleID because the active rule is uniquely determined by the IPsec SA. The architecture should explicitly allow implicit RuleIDs to accommodate such protocols. |
| 2 | Section 4.2.2.4 | Dispatcher routing | "When an Endpoint is supporting multiple Instances, the Instance Manager is responsible for managing the lifecycle and configuration of these Instances. Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator..." | "When an Endpoint is supporting multiple Instances, the Instance Manager is responsible for managing the lifecycle and configuration of these Instances. Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator... In secure deployments where the Discriminator is compressed and potentially ambiguous (e.g., a compressed SPI in IPsec), the Dispatcher may delegate routing to the security stack to perform trial decryption or signature verification across candidate Instances." | ARCHITECTURE GAP | When security parameters like SPI are compressed, the Discriminator is ambiguous and the Dispatcher cannot route packets based on simple lookups. It must delegate to trial decryption/verification. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? Yes
- Is the gap required for this draft or merely useful generally? The gap is required for this draft (to allow elided RuleIDs and trial-decryption routing) but is also useful generally for other secure or highly constrained protocols.
- What is the single most important migration issue? The single most important issue is aligning the concept of the unidirectional IPsec Security Association (SA) and its dynamic negotiation (via IKEv2) with the SCHC concepts of Session, Context, and Instance, specifically handling RuleID elision and trial-decryption demultiplexing.
