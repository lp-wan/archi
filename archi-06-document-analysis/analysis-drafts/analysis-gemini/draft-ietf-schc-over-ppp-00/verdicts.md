# Architectural alignment review: draft-ietf-schc-over-ppp-00

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | The draft's concepts of PPP session, context, rules, peer roles, and compression/fragmentation map cleanly onto the architecture's Session, Context, Set of Rules, Instance Roles, and Datagram concepts, and the architecture explicitly accommodates this model in its text. |
| Transition difficulty | Easy | It requires introducing new architectural components (Instance, Dispatcher, Discriminator) and explaining their relationship to the PPP link, which requires local rewriting rather than simple search-and-replace. | The draft is short and the mapping is straightforward and unambiguous, requiring no complex architectural trade-offs or technical changes. |
| SCHC Architecture adaptation need | None | Highest grade | All concepts are already fully supported, and the architecture even includes an explicit deployment example for PPP matching this draft. |

## Executive assessment
The Static Context Header Compression (SCHC) Architecture -06 can naturally express the draft under study (`draft-ietf-schc-over-ppp-00`) without any conceptual stretching. The principal mapping relates the PPP session to a SCHC Session between two SCHC Instances hosted on SCHC Endpoints, where the PPP connection itself serves as the Discriminator used by the Dispatcher. The principal transition difficulty is editorial: introducing the concepts of "Instance", "Dispatcher", and "Discriminator" (which are absent in the draft) and clearly distinguishing between physical/link-layer endpoints and logical SCHC Endpoints. No architectural gaps exist in `draft-ietf-schc-architecture-06` with respect to this draft.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Endpoint | A physical or network node (IP Host, IP Router, serial DTE/DCE) that sends/receives packets. | Physical or virtual hardware | Node-local | MAC or IP Address | 1:1 with network interface | In -06, this is a logical entity rather than a physical node. |
| PPP Session / Virtual Link | The point-to-point connection established between a pair of nodes over PPP. | Shared by both peer nodes | Link-local (peer-pair) | PPP Session ID (in PPPoE) / IPV6CP negotiation context | 1 PPP Session connects exactly 2 nodes | Maps to the Session concept in -06. |
| SCHC Context | The state containing the Set of Rules used to compress/decompress or fragment/reassemble packets. | Resides on both peer nodes | Session-local | URI negotiated during PPP setup | 1 Context per PPP Session | Contains the Set of Rules and metadata. |
| Set of Rules | The collection of compression/decompression and fragmentation/reassembly rules. | Resides in the Context | Session-local | URI | 1 Set of Rules per Context | Represented as JSON-encoded YANG. |
| Compressor/Decompressor (C/D) | The functional role/module that compresses or decompresses headers. | Runs on each node | Node-local | Implicitly selected by PPP link or packet type | 1 C/D module per node | Maps to an Instance running C/D in -06. |
| Fragmenter/Reassembler (F/R) | The functional role/module that fragments and reassembles packets in No-ACK mode. | Runs on each node | Node-local | Implicitly selected by fragmentation RuleID (1111) | 1 F/R module per node | Maps to an Instance running F/R in -06. |
| Initiator (Downstream / Device) | The node that initiates the PPP session, playing the role of the LPWAN device. | Node role | Session-local | PPP link initiator status | 1 per PPP session | Maps to the Downside / Device role. |
| Responder (Upstream / Network) | The node that accepts the PPP session, playing the role of the LPWAN network. | Node role | Session-local | PPP link responder status | 1 per PPP session | Maps to the Upside / Network role. |
| RuleID | A selector prefix in the packet indicating which rule applies. | Packet header | Session-local / Context-local | 2-byte prefix starting with `00` (compression) or 4-bit prefix `1111` (fragmentation) | Many RuleIDs per Context; 1 RuleID maps to 1 Rule | Variable size is a profile-specific choice. |
| DTag | Fragment discriminator used to identify fragments of the same packet. | SCHC Fragment Header | Session-local | 11-bit field | 1 DTag per fragmented PDU | Part of No-ACK fragmentation parameterization. |
| FCN | Fragment sequence bit to signal the end of a fragmented packet. | SCHC Fragment Header | Fragment-local | 1-bit field | 1 FCN per fragment | Part of No-ACK fragmentation parameterization. |

## Native architectural model
The draft under study, `draft-ietf-schc-over-ppp-00`, defines a mechanism to transport compressed and fragmented packets over a Point-to-Point Protocol (PPP) link. It extends the IPv6 datagram compression option defined in RFC 5172 (which operates within the IPv6 Control Protocol, IPV6CP) to negotiate the use of Static Context Header Compression (SCHC) between a pair of nodes.

When establishing the PPP link, the nodes negotiate the use of SCHC by exchanging a new compression protocol identifier (suggested value 4). Along with this identifier, the initiator transmits a Uniform Resource Identifier (URI) in the IPV6CP configuration option's data field. This URI points to a JSON file containing the Set of Rules (SoR) modeled in YANG, which defines the compression and fragmentation rules for the session.

Once negotiated, the PPP session serves as a virtual link with an established SCHC Context. Both endpoints on the link must support the SCHC Compressor/Decompressor (C/D) functions. The Fragmenter/Reassembler (F/R) function is optional but supported for cases where a small, protocol-independent frame size is desired.

The two endpoints play asymmetric roles if the rules in the context are asymmetric (e.g. client/server or sensor/actuator). The initiator of the PPP session is defined as "downstream," taking on the LPWAN "device" role, while the responder is "upstream," taking on the LPWAN "network" role.

Packets are compressed and encapsulated as standard PPP payloads. To multiplex compressed and uncompressed traffic, the PPP Protocol field remains set to the standard IPv6 Protocol ID (0x0057). The receiver distinguishes compressed packets by examining the first bits of the payload, which correspond to the SCHC RuleID.

The RuleID numbering scheme specifies that compression RuleIDs are 2 bytes long, with the first two bits set to 00. This leaves 14 bits for indexing compression rules and ensures that the packet does not conflict with the version field of a native IPv6 header (which begins with 0110).

Fragmentation is supported strictly in No-ACK mode. A fragmentation RuleID is 4 bits long and must be set to 1111 (again avoiding conflict with native IPv6). The fragmentation header is 2 bytes long, containing the 4-bit RuleID, an 11-bit DTag (for identifying fragments of the same packet), and a 1-bit FCN (which is set to 1 on the last fragment and 0 otherwise).

In terms of padding, the compression residue is aligned to the Layer 2 word. For Ethernet/PPPoE, the Layer 2 word is 1 byte, so padding is added up to the next byte boundary.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Endpoint | A physical or network node (IP Host, IP Router, serial DTE/DCE) that sends/receives packets. | Endpoint | Direct | Aligned | Aligned | The draft views Endpoint as a physical or link-layer node, whereas -06 defines it as a logical entity hosting Instances. | Can be resolved by clarifying that the logical Endpoint is hosted on the PPP node. |
| PPP Session / Virtual Link | The point-to-point connection established between a pair of nodes over PPP. | Session | Direct | Aligned | Aligned | In the draft, the Session is tied to the physical/L2 PPP link, while in -06, a Session is a logical communication relationship between Instances. | Fits naturally because the PPP link isolates the traffic of the session. |
| SCHC Context | The state containing the Set of Rules used to compress/decompress or fragment/reassemble packets. | Context | Direct | Aligned | Aligned | None | The draft's context maps perfectly to the -06 Context. |
| Set of Rules | The collection of compression/decompression and fragmentation/reassembly rules. | Set of Rules (SoR) | Direct | Aligned | Aligned | None | Fully aligned. |
| Compressor/Decompressor (C/D) | The functional role/module that compresses or decompresses headers. | Instance C/D function | Composite | Aligned | Aligned | The draft treats C/D as a node function, while -06 encapsulates it in an Instance. | Maps to an Instance performing C/D. |
| Fragmenter/Reassembler (F/R) | The functional role/module that fragments and reassembles packets in No-ACK mode. | Instance F/R function | Composite | Aligned | Aligned | The draft treats F/R as a node function, while -06 encapsulates it in an Instance. | Maps to an Instance performing F/R. |
| Initiator (Downstream / Device) | The node that initiates the PPP session, playing the role of the LPWAN device. | Instance Configuration (Device Role) | Profile-specific | Aligned | Aligned | The draft links the role to PPP session initiation, whereas -06 specifies it as part of Instance Configuration. | Maps to the Device (Downside) role by convention in peer-to-peer links. |
| Responder (Upstream / Network) | The node that accepts the PPP session, playing the role of the LPWAN network. | Instance Configuration (Network Role) | Profile-specific | Aligned | Aligned | The draft links the role to PPP session responder, whereas -06 specifies it as part of Instance Configuration. | Maps to the Network (Upside) role. |
| RuleID | A selector prefix in the packet indicating which rule applies. | RuleID | Direct | Aligned | Aligned | None | The specific 16-bit (00 prefix) or 4-bit (1111 prefix) representation is a profile-level formatting choice. | Compatible with -06 datagram format. |
| DTag | Fragment discriminator used to identify fragments of the same packet. | Set of Variables (SoV) / Fragment Header | Profile-specific | Aligned | Aligned | None | Standard fragmentation parameter. |
| FCN | Fragment sequence bit to signal the end of a fragmented packet. | Fragment Header field | Profile-specific | Aligned | Aligned | None | Standard fragmentation parameter. |
| PPP Protocol Field (0x0057) | Multiplexing using the standard IPv6 Protocol ID (0x0057) to encapsulate SCHC Datagrams. | Discriminator / Dispatcher | Composite | Aligned | Aligned | None | The PPP connection and the Protocol ID are used as the Discriminator to route packets. | Mentioned in -06 Section 4.2.2.4. |
| URI pointing to SoR | The URI passed in the IPV6CP configuration option to distribute the rules. | Context Repository / Provisioning | Direct | Aligned | Aligned | None | Fits the "fetched on demand" paradigm of -06. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Established for the specific PPP session (virtual link). Owned jointly by the two peer nodes. | Shared between two or more Instances that participate in a Session. | Aligned | The context is tied to the Session, which maps perfectly. |
| Ownership of Set of Rules | Specified by the URI negotiated in the PPP session setup, shared by both peers. | Contained within the Context, shared between Instances. | Aligned | No conflict. |
| Ownership of Set of Variables | Implied to be session-local (e.g. fragmentation state such as DTag, FCN). | Runtime parameters and session variables owned per-Session/Instance. | Aligned | No conflict. |
| Endpoint↔SCHC Instance | 1 Instance per endpoint per PPP session. | 1 Endpoint can host multiple Instances (1:N). | Aligned | The draft's 1:1 is a specific case of the architecture's 1:N support. |
| SCHC Instance↔Session | 1 Instance per PPP session. | 1 Instance per Session per Endpoint. | Aligned | Fully aligned. |
| Sharing of Context between Sessions/Instances | Context is established for a specific PPP session. No sharing across multiple PPP sessions. | Contexts can be shared between multiple Instances or Sessions in a Domain. | Aligned | The draft's single-session Domain is a valid subset of -06. |
| RuleID Scope | Local to the PPP session. | Local to the Context/Session. | Aligned | Aligned. |
| Discriminator Scope | The PPP link itself acts as the discriminator. | Used by the Dispatcher to route datagrams to the correct Instance. | Aligned | The PPP link acts as a lower-layer discriminator, which is explicitly supported. |
| Control Header processing scope | Not applicable | Optional header placed before or after RuleID. | Not applicable | The draft does not use Control Headers. |
| Domain membership and boundaries | The two peers on the PPP link form the domain (implicit single-session Domain). | A logical grouping of Instances that share a common set of Contexts. | Aligned | The draft's peers form a single-session Domain. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk:** Conflation of physical/link-layer nodes with logical SCHC Endpoints and Instances.
  **Why it matters:** The draft attributes C/D and F/R functions directly to the "endpoints" (which it defines as the IP Host or serial DTE/DCE). In the architecture, these functions are executed by SCHC Instances hosted on logical Endpoints, and a physical node can host multiple such Endpoints or Instances. Failing to distinguish this could limit implementations that want to run multiple independent SCHC sessions (e.g., over multiple virtual PPP tunnels or different protocol layers) on the same host.
  **Consequence for migration:** The draft's terminology needs to be updated to introduce the concepts of "Instance", "Dispatcher", and "Discriminator" and explain how they map to the PPP link and PPP session.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3, Page 3 | "a PPP session defines a vitual link where a SCHC context is established..." | Rephrase to specify that a PPP session maps to a SCHC Session between two SCHC Instances, sharing a common Context. | REQUIRED FOR TERMINOLOGY MIGRATION | To align the description of the PPP connection with the Session and Instance concepts in -06. |
| 2 | Section 4.1, Page 4 | "This specification leverages SCHC between an end point that is an IP Host ... and another that is an IP Node ... Both endpoints MUST support the function of SCHC Compressor/ Decompressor (C/D) as shown in Figure 2." | Update to state that each peer hosts a SCHC Endpoint with a SCHC Instance running the C/D (and optionally F/R) functions. Rephrase "endpoints" in the physical sense to "peer nodes" or "hosts," and reserve "Endpoint" for the logical SCHC Endpoint. | REQUIRED FOR TERMINOLOGY MIGRATION | To align with the logical Endpoint and Instance definitions in -06, preventing conflation of physical nodes with logical SCHC entities. |
| 3 | Section 4.1, Page 4 | "Both endpoints MUST support the function of SCHC Compressor/ Decompressor (C/D) as shown in Figure 2." | Replace Figure 2 with an updated diagram showing SCHC Instances hosted on SCHC Endpoints within the IP Host and IP Router, with the PPP link serving as the discriminator. | REQUIRED FOR TERMINOLOGY MIGRATION | To reflect the -06 component architecture visually. |
| 4 | Section 3, Page 4 | "If the encoding is asymetrical, the initiator of the session is considered downstream, playing the role of the device in an LPWAN network." | Rephrase to state that the initiator's Instance plays the Downside (Device) role and the responder's Instance plays the Upside (Network) role. | REQUIRED FOR TERMINOLOGY MIGRATION | To align role names with the -06 terminology (Downside/Upside). |
| 5 | Section 4.1, Page 4 | "A context may be generated for a particular upper layer application... The context can be asymetric, e.g., when connecting a primary and a secondary endpoints..." | Rephrase "endpoints" to "Instances" or "peer nodes" where appropriate. | REQUIRED FOR TERMINOLOGY MIGRATION | Consistent use of -06 terminology. |
| 6 | Section 4.1, Page 4 (New Subsection) | N/A | Add a new subsection 4.1.1 "Architectural Mapping" describing the Dispatcher and Discriminator. Specify that the PPP connection itself serves as the Discriminator, and the Dispatcher routes incoming PPP packets with Protocol 0x0057 to the corresponding SCHC Instance. | REQUIRED FOR TERMINOLOGY MIGRATION | To describe the multiplexing and routing in terms of the -06 architecture components (Dispatcher/Discriminator). |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A
- What is the single most important migration issue? The need to introduce the concepts of "Instance", "Dispatcher", and "Discriminator" into the draft and clearly distinguish between logical SCHC Endpoints/Instances and physical/L2 PPP nodes.
