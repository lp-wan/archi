# Evidence Notes: draft-ietf-ipsecme-diet-esp-10

## analysis-gemini
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

SCHC Architecture -06 can naturally express the technical model of `draft-ietf-ipsecme-diet-esp-10` with minor clarifications. The principal conceptual mapping involves representing the three Diet-ESP compressors (IIPC, CTEC, EEC) as coordinated SCHClets within a single SCHC Instance owned by the IPsec Security Association (SA). The principal migration difficulty lies in updating the terminology to use SCHC Architecture -06 terms consistently and handling the elision of the RuleID and trial-decryption demultiplexing. Two trivial architecture gaps exist in -06 regarding: (1) allowing the RuleID to be implicit (elided) when uniquely determined by out-of-band context (like the SA), and (2) clarifying that the Dispatcher may delegate routing to the security stack to perform trial decryption when the Discriminator is compressed and ambiguous.

### Architectural risk points

- **Risk:** SPI LSB Collision and Computational Exhaustion (DoS)
- **Why it matters:** When the SPI is compressed (using EEC LSB), multiple SAs can share the same LSB value. The receiver's Dispatcher cannot uniquely route the packet to the correct Instance, forcing the receiver to perform trial decryption and signature verification for all candidate SAs. A malicious actor can flood the receiver with random packets matching a compressed SPI LSB, forcing the receiver to perform expensive cryptographic operations on many SAs, leading to CPU exhaustion.
- **Consequence for migration:** The draft must highlight this risk and recommend deterministic or collision-free SPI assignment, or limit the use of extreme SPI compression in hostile environments.

- **Risk:** RuleID Elision Mismatch
- **Why it matters:** Implementations conforming strictly to SCHC Architecture -06 expect a RuleID at the start of the Datagram. If Diet-ESP elides the RuleID, standard SCHC parsers will fail or misinterpret the first byte of the payload as a RuleID.
- **Consequence for migration:** The integration between the ESP stack and the SCHC C/D engine must be custom-tailored, and standard SCHC implementations cannot be used without modification to support implicit RuleIDs.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 2.2 / 4.1 | "The RuleID in Diet-ESP is expressed as 1 byte but it can be elided as there is a unique Rule determined for the compressors." | Clarify that when the RuleID is elided, the RuleID is implicit and resolved via the SA context, aligning with the SCHC Architecture's concept of implicit rule selection. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Ensures compatibility with the SCHC Architecture's definition of Datagram framing. |
| 2 | Section 2.1 | "The document outlines the three compressors utilized in Diet-ESP..." | Clarify that the three compressors (IIPC, CTEC, EEC) can be modeled as three coordinated SCHClets within a single SCHC Instance associated with the SA. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Aligns the multi-stage pipelining model with the SCHC Architecture's Instance and SCHClet concepts. |
| 3 | Throughout the draft | Various mentions of "Diet-ESP context", "compression rules", "peer context". | Update terminology to use SCHC Architecture -06 terms consistently (e.g., "SCHC Context", "SCHC Rules", "Session"). | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns vocabulary with the reference architecture. |
| 4 | Section 9 | Security Considerations regarding SPI. | Elaborate on the security implications of SPI compression and the potential for DoS via trial decryption, suggesting strategies to mitigate SPI collisions. | OPTIONAL CLARIFICATION | Improves the security considerations section without changing technical behavior. |
| 5 | References | Informative reference to `draft-ietf-schc-architecture-05`. | Update reference to `draft-ietf-schc-architecture-06` (or later). | EDITORIAL | Updates outdated reference. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.5 | RuleID presence | "A Datagram starts with a RuleID. The Rule identified by that RuleID determines the format and interpretation of the remaining bits." | "A Datagram starts with a RuleID, which determines the format and interpretation of the remaining bits. In some profiles or deployments where the Rule is uniquely determined by out-of-band context (e.g., a Security Association or a dedicated point-to-point connection), the RuleID may be elided on the wire and treated as implicit." | ARCHITECTURE GAP | Diet-ESP elides the RuleID because the active rule is uniquely determined by the IPsec SA. The architecture should explicitly allow implicit RuleIDs to accommodate such protocols. |
| 2 | Section 4.2.2.4 | Dispatcher routing | "When an Endpoint is supporting multiple Instances, the Instance Manager is responsible for managing the lifecycle and configuration of these Instances. Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator..." | "When an Endpoint is supporting multiple Instances, the Instance Manager is responsible for managing the lifecycle and configuration of these Instances. Datagrams are routed to the appropriate Instance by the Dispatcher using the Discriminator... In secure deployments where the Discriminator is compressed and potentially ambiguous (e.g., a compressed SPI in IPsec), the Dispatcher may delegate routing to the security stack to perform trial decryption or signature verification across candidate Instances." | ARCHITECTURE GAP | When security parameters like SPI are compressed, the Discriminator is ambiguous and the Dispatcher cannot route packets based on simple lookups. It must delegate to trial decryption/verification. |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? Yes
- Is the gap required for this draft or merely useful generally? The gap is required for this draft (to allow elided RuleIDs and trial-decryption routing) but is also useful generally for other secure or highly constrained protocols.
- What is the single most important migration issue? The single most important issue is aligning the concept of the unidirectional IPsec Security Association (SA) and its dynamic negotiation (via IKEv2) with the SCHC concepts of Session, Context, and Instance, specifically handling RuleID elision and trial-decryption demultiplexing.
