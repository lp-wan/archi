# Architectural alignment review: draft-ietf-schc-protocol-numbers-06

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | The core technical mechanisms of the draft (using protocol numbers, Ethertypes, and transport ports to signal and route SCHC Datagrams) are completely and naturally expressible by SCHC Architecture -06 without any reinterpretation. |
| Transition difficulty | Easy | Some local rewritings and structural adjustments are required (especially in Section 3.6 to replace the "SCHC Stratum Header" concept and in Section 3.2 to clear up "session (called instance)" conflation), meaning it is not entirely mechanical. | The draft is short, the terminology differences are highly localized, and the mapping decisions are straightforward, unambiguous, and repeatable. |
| SCHC Architecture adaptation need | None | Highest grade | SCHC Architecture -06 already contains all necessary concepts (Discriminator, Dispatcher, Instance, Context, Session) to fully support the draft, and Section A.2.3 explicitly describes this deployment model. |

## Executive assessment
SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is representing the requested IANA protocol and port numbers as **Discriminators** that are processed by the **Dispatcher** to route incoming **SCHC Datagrams** to the appropriate **Instance** and **Context**. The principal migration difficulty is correcting minor terminology conflations in the draft, specifically renaming "SCHC Stratum Header" to outer **Discriminators** (and/or **Control Headers**) and resolving the conflated terms "session" and "instance". No SCHC Architecture -06 gaps exist, and no modifications to the architecture are required.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Internet Protocol Number for SCHC | Decimal value indicating that the payload of an IP packet is a SCHC Datagram. | IP Header (Layer 3) | Link-local or End-to-End | TBD1 (suggested: 145) | N:1 (multiple IP packets mapped to SCHC processing) | Allows SCHC transport independent of UDP or ESP. |
| Ethertype for SCHC | 2-byte value in the IEEE 802 header signaling that the upper-layer protocol is SCHC. | IEEE 802 Header (Layer 2) | Link-local | Ethertype (TBD) | N:1 (multiple Ethernet frames mapped to SCHC processing) | Used to signal SCHC as the upper-layer protocol directly over IEEE 802. |
| Transport Port Numbers for SCHC | Well-known ports identifying the presence of a SCHC Stratum (SCHC Datagram) atop UDP/TCP/DTLS. | UDP/TCP Header (Layer 4) | End-to-End | UDP/TCP ports (TBD) | N:1 (multiple UDP/TCP packets mapped to SCHC processing) | Used when upper-layer protocols (like CoAP) are compressed by SCHC. |
| CCSDS Encapsulation Number for SCHC | Codepoint in the Internet Protocol Extension (IPE) registry to allocate SCHC over CCSDS. | CCSDS link layer | Space Link (point-to-point) | CCSDS IPE codepoint | N:1 (multiple CCSDS packets mapped to SCHC processing) | Used for space link layers managed by SANA. |
| SCHC Datagram | The unit exchanged between endpoints, consisting of a RuleID, compression residue, and payload. | Network payload | Session-wide | RuleID | 1:1 with the transmitted message payload | Often called "SCHC Packet" in other contexts. |
| Set of Rules (SoR) | The collection of compression/decompression and fragmentation rules. | Endpoint / Host | Session-wide | RuleID | 1:1 with a SCHC Session | Statically configured or negotiated. |
| SCHC Session (also called "instance" in Sec 3.2) | The logical communication association established between two endpoints. | Endpoints | Peer-pair | Implicit or signaled | 1:1 between communicating peers | Conflated with "instance" in Section 3.2. |
| SCHC Stratum | A portion of the network protocol stack targeted by SCHC. | Network stack | Stack-local | Layer identifier | 1:1 per compressed stack portion | Defines the scope of the headers compressed. |
| SCHC Stratum Header | A conceptual header that adds signaling information to identify SCHC and select the correct instance/SoR. | Prefix to SCHC Datagram or outer header | Link-local or End-to-End | Protocol/port numbers | N:1 (multiple outer headers signal SCHC) | A non-standard conceptual term that conflates outer headers with internal signaling. |
| RuleID size table | A table mapping source IP address prefixes to RuleID sizes. | Receiver node | Node-local | Source IP address prefix | N:1 (multiple IP prefixes mapped to a RuleID size) | Statically configured to allow parsing variable-sized RuleIDs. |

## Native architectural model
The draft under study, `draft-ietf-schc-protocol-numbers-06`, is focused on facilitating the recognition and routing of SCHC-compressed datagrams across different networking layers. It addresses the need for standard, well-known identifiers so that endpoints and intermediate nodes can easily identify when SCHC has been applied to a payload. The primary mechanisms are IANA allocations at the network layer (an Internet Protocol Number), the link layer (an Ethertype and a CCSDS Encapsulation Number), and the transport layer (TCP/UDP port numbers).

Historically, SCHC was designed for highly constrained LPWAN networks where the link-layer endpoints and the application flow were preconfigured, rendering explicit signaling of SCHC and the specific session redundant. However, as SCHC's applicability expands to more capable and diverse technologies such as Ethernet, standard IP networks, and space links, this implicit approach is no longer viable. In these richer environments, multiple communication sessions may run in parallel, and endpoints require explicit markers to trigger the SCHC decompression process.

Under the draft's model, the identifier used to signal SCHC is stack-layer dependent. At Layer 3, an Internet Protocol Number (TBD1, suggested: 145) is requested to denote that the IPv4 "Protocol" or IPv6 "Next Header" field contains a SCHC datagram. This allows SCHC to run directly over IP, independent of UDP or ESP, which is particularly beneficial for protocols like Diet ESP and DTLS 1.3 to avoid complex heuristics (such as inspecting ESP SPIs) to determine if header compression was used.

At Layer 2, a dedicated Ethertype is requested to support the native transport of SCHC over IEEE 802 networks (like Ethernet or Wi-Fi). This is essential because standard OUI-based protocol assignments would add unnecessary payload overhead, contradicting SCHC's core goal of minimizing packet size. In this use case, immediately following the SCHC Ethertype is the RuleID. If the rule does not determine the datagram length, the length must be explicitly carried in the compression residue.

At Layer 4, transport port numbers are requested to identify when a SCHC Stratum sits atop UDP or TCP. For instance, when compressing CoAP over UDP or running QUIC, well-known port numbers are required so that the receiving transport layer knows that the payload is a SCHC-compressed datagram rather than raw application data. Similarly, for space links, a CCSDS Encapsulation Number in the Internet Protocol Extension (IPE) registry is requested to indicate SCHC processing over space data links.

To handle the actual processing, the draft describes how the SCHC Stratum Header adds signaling information to the SCHC datagram. This header may be fully compressed, resulting in zero overhead, and it contains identifiers (such as the protocol or port numbers) that depend on the compressed stack layer. This "header" is used to identify the use of SCHC and to select the correct instance and Set of Rules (SoR) at the receiver.

In terms of session and rule management, the draft describes connection-oriented communications where two endpoints establish a session to transfer data. During the connection establishment (such as a 3-way handshake), the hosts identify SCHC via the port number and agree on the Set of Rules (SoR). Ongoing management and modification of the SoR is envisioned to use the YANG data model as described in the CORECONF management specifications, requiring both endpoints to apply synchronized updates to preserve flow control.

Furthermore, for the Internet Protocol use case, the draft states that because the RuleID size is variable, an implementation should maintain a table mapping source IP addresses to RuleID sizes. This table should represent addresses in prefix format to group devices with identical RuleID sizes. This allows the receiving node to correctly parse the variable-length RuleID from the incoming SCHC Datagram.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Internet Protocol Number for SCHC | Identifier in IP header signaling SCHC payload. | Discriminator | Direct | Aligned | Aligned | None | Serves as the outer Discriminator for the IP-layer Dispatcher. |
| Ethertype for SCHC | Identifier in IEEE 802 header signaling SCHC payload. | Discriminator | Direct | Aligned | Aligned | None | Serves as the outer Discriminator for the Ethernet-layer Dispatcher. |
| Transport Port Numbers for SCHC | Identifiers in transport headers (UDP/TCP) signaling SCHC payload. | Discriminator | Direct | Aligned | Aligned | None | Serves as the outer Discriminator for the Transport-layer Dispatcher. |
| CCSDS Encapsulation Number for SCHC | Codepoint in CCSDS IPE registry signaling SCHC payload. | Discriminator | Direct | Aligned | Aligned | None | Serves as the outer Discriminator for the CCSDS-layer Dispatcher. |
| SCHC Datagram | RuleID followed by residue and payload. | Datagram | Direct | Aligned | Aligned | None | Exactly corresponds to the architectural Datagram definition. |
| Set of Rules (SoR) | The collection of rules available to the process. | Set of Rules (SoR) | Direct | Aligned | Aligned | None | Part of the shared Context. |
| SCHC Session (also called "instance" in Sec 3.2) | The logical communication association between endpoints. | Composite (Instance + Session) | Composite | Aligned | Aligned | The draft conflates the local executing component (Instance) with the peer association (Session). | SCHC Architecture -06 clarifies this distinction. |
| SCHC Stratum | The targeted portion of the network protocol stack. | Stratum | Direct | Aligned | Aligned | None | Defines stack layers addressed by rules. |
| SCHC Stratum Header | Conceptual header containing layer-specific protocol/port numbers to select instance/SoR. | Misleading | Misleading | Misaligned | Misaligned | Conflates outer headers (Discriminators) with internal signaling (Control Headers). | In -06, protocol/port numbers are outer Discriminators, not an internal SCHC header. |
| RuleID size table | Table mapping source IP prefixes to RuleID sizes. | Profile-specific | Profile-specific | Aligned | Aligned | The draft treats it as a node-local table. In -06, this represents metadata in the Instance Configuration or Context. | Fits the natural use of Instance Configuration/Context metadata. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Shared between the two communicating endpoints. | Shared between two or more Instances (part of a Domain). | Aligned | A Context is logically shared within a Domain; the draft's P2P model is a subset of this. |
| Ownership of Set of Rules (SoR) | Associated with the session/endpoints, exchanged and agreed upon. | Contained within the Context shared by Instances. | Aligned | No technical difference; SoR is part of the Context. |
| Ownership of Set of Variables (SoV) | Kept by both endpoints to maintain session/flow control state. | Associated with a specific Session (per-session runtime state). | Aligned | The draft's session state corresponds to the architecture's SoV. |
| Endpoint↔SCHC Instance | Assumed 1:1 in basic LPWAN, but multi-Instance is hinted at for Ethernet/IP. | 1 Endpoint can host multiple Instances. | Aligned | The draft's protocol numbers act as outer Discriminators to route to the correct Instance. |
| SCHC Instance↔Session | Section 3.2 mentions "SCHC session (called instance)". | An Instance can participate in multiple Sessions. | Misaligned | The draft must update terminology to distinguish the local component (Instance) from the association (Session). |
| Sharing of Context between Sessions/Instances | Assumed unique per session/endpoints in most text. | Context can be shared among multiple Sessions or Instances in a Domain. | Aligned | The draft's model is a subset; sharing is permitted but not required by the draft. |
| RuleID scope | Unique within the Set of Rules (session context). | Unique within a Context. | Aligned | RuleID is used to select the specific rule within the Context. |
| Discriminator scope | Outer protocol/port numbers identify SCHC traffic globally. | Used by the Dispatcher to route packets to the appropriate Instance. | Aligned | Outer protocol numbers are the primary Discriminators; lower-layer addresses provide sub-discrimination. |
| Control Header processing scope | Called "SCHC Stratum Header" in Section 3.6. | Processed before or after the RuleID; carries optional multiplexing/protection. | Misaligned | The draft must distinguish outer Discriminators from any internal Control Header. |
| Domain membership and boundaries | Implied by sharing the same SoR/context. | Group of Instances sharing a set of Contexts under a Domain Manager. | Aligned | The draft's "administrator" or "provisioning" corresponds to Domain/Instance management. |

## Challenged mappings
| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| SCHC Stratum Header | Composite (Discriminator + Control Header) | The draft states that the "SCHC Stratum Header format includes... the protocol number at layer three and port numbers at layer four." This is technically incorrect: these fields are in the outer headers, not in a SCHC-specific header format. | Misleading | Calling outer headers a "SCHC Stratum Header" is misleading. In SCHC -06, outer header fields are **Discriminators** used by the **Dispatcher**, and any internal signaling uses a **Control Header**. |
| SCHC session (called instance) | Composite (Instance + Session) | In Section 3.2, the draft states "the SCHC session (called instance) to use, are implicit." These are distinct concepts in SCHC -06 (Instance is local; Session is peer-to-peer). Conflating them is technically incorrect. | Composite (Instance + Session) | Although conflated on the draft's wire/prose, they map to the distinct architectural concepts of **Instance** and **Session** which must be clearly separated in the migrated text. |

## Architectural risk points
- **Risk:** Terminology Conflation (Session vs. Instance vs. Endpoint)
  - **Why it matters:** The draft under study uses the phrase "SCHC session (called instance)" in Section 3.2 and conflates these concepts. In SCHC Architecture -06, an Endpoint is a logical entity hosting one or more Instances, and a Session is the communication relationship between Instances. Conflating them prevents proper implementation of multi-tenant or multi-interface nodes (like the uncrewed cargo aircraft mentioned in Section 3.1).
  - **Consequence for migration:** The draft's text in Sections 2, 3.2, 3.4, and 3.6 must be reframed to clearly separate the logical Endpoint, the Instances running on it, and the Sessions established between them.

- **Risk:** The "SCHC Stratum Header" Concept
  - **Why it matters:** The draft introduces the concept of a "SCHC Stratum Header" in Section 3.6 and claims its format includes the protocol/port numbers. This is technically incorrect because the protocol/port numbers are fields in the outer IP/UDP headers, not in a SCHC-specific header.
  - **Consequence for migration:** The draft must be revised to remove the "SCHC Stratum Header" terminology and instead describe the protocol and port numbers as outer **Discriminators** used by the **Dispatcher** to identify SCHC packets and route them to the appropriate **Instance**. Any actual SCHC-specific signaling should be referred to as a **Control Header**.

- **Risk:** RuleID Size Determination from IP Address
  - **Why it matters:** Section 4 states that an implementation should have a table mapping source IP addresses to RuleID sizes. This assumes that RuleID size is variable and dependent on the peer's IP address. However, in SCHC Architecture -06, the RuleID size is typically defined in the Context or the Instance Configuration.
  - **Consequence for migration:** The draft should clarify that this mapping table is a component of the **Instance Configuration** or **Context** metadata, ensuring it is managed within the SCHC -06 configuration framework.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3.6 | "In the current SCHC architecture, the SCHC Stratum Header adds signalling information... selects the correct instance and SoR..." | Rewrite to remove the concept of "SCHC Stratum Header" and replace it with outer **Discriminators** (the IP protocol or port numbers) processed by the **Dispatcher** to route to the correct **Instance** (which has an associated **Context** and **SoR**), and mention that any internal signaling can be carried in a **Control Header**. | REQUIRED FOR CONCEPTUAL ALIGNMENT | The draft's concept of a "SCHC Stratum Header" that includes outer protocol/port numbers is conceptually incorrect and violates the layered model of SCHC -06. |
| 2 | Section 4, Paragraph 2 | "An implementation should have a table of source IP address and RuleID size. The addresses should be represented in prefix format..." | Rewrite to: "An Instance Configuration or Context should associate the peer's IP address (or prefix) with the expected RuleID size to enable proper parsing of the SCHC Datagram." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Storing RuleID sizes in an ad-hoc table is outside the SCHC -06 architecture. It should be defined as metadata within the **Instance Configuration** or the **Context**. |
| 3 | Section 3.2, Paragraph 1 | "...the use of SCHC to compress the transported protocol, as well as the SCHC session (called instance) to use, are implicit. The MAC-Layer endpoints are preconfigured..." | Rewrite to: "...the use of SCHC to compress the transported protocol, as well as the SCHC Instance and Session to use, are implicit. The MAC-Layer Endpoints are preconfigured..." | REQUIRED FOR TERMINOLOGY MIGRATION | Align terminology with SCHC -06 by clearly distinguishing between **Endpoint**, **Instance**, and **Session**, and replacing "session (called instance)". |
| 4 | Section 3.3, Paragraph 1 | "...identifies the presence of a SCHC Stratum (defined in [schc-architecture]) atop UDP..." | Rewrite to: "...identifies that the payload of the UDP packet is a SCHC Datagram, which belongs to a Session operating on a specific Stratum (defined in [schc-architecture]) atop UDP..." | REQUIRED FOR TERMINOLOGY MIGRATION | A port number identifies the payload as a SCHC Datagram (serving as a Discriminator), not the presence of the Stratum itself. |
| 5 | Section 3.4, Paragraph 1 | "...both hosts must identify SCHC with the layer-4 port number and exchange and agree on the Set of Rules (SoR)." | Rewrite to: "...both Endpoints must identify SCHC using the layer-4 port number (acting as a Discriminator) and exchange and agree on the Context containing the Set of Rules (SoR)." | REQUIRED FOR TERMINOLOGY MIGRATION | The port number is a Discriminator. Agreeing on rules is part of Context provisioning/synchronization managed by the Domain/Instance Manager in SCHC -06. |
| 6 | Section 1, Paragraph 2 | "After applying SCHC, the protocol information is reduced to a RuleID and the compression residue (if any)." | Add a note clarifying that the resulting unit is a SCHC Datagram. | OPTIONAL CLARIFICATION | Makes the text explicit about the resulting architectural unit (SCHC Datagram). |
| 7 | Global / References | Reference to `[schc-architecture]` pointing to `draft-ietf-schc-architecture-05`. Typo "datgram" in Section 4. | Update reference `[schc-architecture]` to `draft-ietf-schc-architecture-06` and fix the typo. | EDITORIAL | Reference updates and typo fixes. |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A
- What is the single most important migration issue? Replacing the confused "SCHC Stratum Header" concept with the clean architectural concepts of outer Discriminators and optional Control Headers.
