# Architectural alignment review: draft-ietf-6lo-schc-15dot4-13

## Verdicts
- Conceptual equivalence: High
- Transition difficulty: Medium
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | High | **Very High** is not chosen because the Pointer-based Route-Over (PRO) mode introduces an intermediate-node routing and residue-modification mechanism that is not natively part of the end-to-end, Context-bound C/D model of SCHC Architecture -06. | **Medium** is not chosen because all other core mechanisms (SRO, TRO, Mesh-Under, TPS, and nested multiple Strata) can be naturally expressed using -06's logical components (Endpoint, Instance, Session, Domain, Context, Control Header, Dispatcher, and Discriminator). |
| **Transition difficulty** | Medium | **Easy** is not chosen because the draft uses "end point" as a synonym for "Instance" or "Session" throughout, and migrating this requires non-trivial architectural judgment (especially regarding the role of 6LRs in PRO and the layering of multiple Strata in TPS) rather than a simple mechanical search-and-replace. | **Difficult** is not chosen because the underlying protocol format, packet structures, and technical behavior do not need to change; the migration is primarily an architectural-framing and terminology exercise. |
| **SCHC Architecture adaptation need** | Trivial | **None** is not chosen because the PRO routing model requires an explicit architectural clarification in -06 to explain how intermediate nodes can inspect or modify residues using pointers in a Control Header without possessing the decompression Context. | **Medium** is not chosen because this gap can be closed through a simple additive clarification/note in -06's Control Header section, without modifying the meaning of any existing normative text or changing the core conceptual model of SCHC. |

## Executive assessment
Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express almost all of the technical behaviors, protocol stacks, and deployment configurations of the draft under study (`draft-ietf-6lo-schc-15dot4-13`). The principal conceptual mapping translates the draft's "SCHC Data end point" to an -06 "SCHC Instance", and the draft's "SCHC Control Header end point" to a combination of -06's Dispatcher and Instance configurations. The network-wide single or multiple endpoint models map to profile-specific configurations of the Dispatcher and Instance counts.

The principal migration difficulty lies in resolving the non-standard terminology of "end points" (used as two words in the draft to represent Instances or Sessions) to match -06's strict separation between "Endpoint" (logical host) and "Instance" (processing entity). Furthermore, architectural framing is needed to represent the nested multiple Strata in the transition protocol stacks and the role of intermediate routers in PRO.

An architectural gap exists in -06 regarding the Pointer-based Route-Over (PRO) mode, where intermediate nodes (6LRs) inspect and modify the compressed packet residue without possessing the Session Context. This gap is classified as **Trivial** and is resolved by proposing a minor additive clarification to Section 4.2.5.1 of -06, allowing a Control Header to contain pointers to residues for intermediate node operations.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **SCHC-Lo network** | A 6LoWPAN network where SCHC is used for header compression/decompression. | Domain / Administrative entity | Network-wide | N/A | Contains multiple 6LNs, 6LRs, and a 6LBR. | Represents the Domain boundary. |
| **6LN (6LoWPAN Node)** | A leaf node (host or router) that communicates using SCHC-compressed packets. Can be a RAL or RUL. | Host device | Node-local | L2 MAC address, DevEUI, IPv6 address | Hosts 1 Endpoint containing 1 or more Instances. | Represents the peripheral device in the network. |
| **6LR (6LoWPAN Router)** | An intermediate router. In SRO, it stores all Rules. In TRO/PRO, it does not store transit Rules. | Router device | Node-local | L2 MAC address, IPv6 address | Hosts Instances for local sessions; transits other sessions. | In PRO, it parses the PRO Header to route and decrement Hop Limit. |
| **6LBR / Root** | Border router or RPL root. Stores all network Rules (SRO/TRO) or external Rules (PRO). | Gateway device | Domain-wide | IPv6 address | Hosts multiple Instances (one per active device/session). | Acts as the central hub of the network. |
| **SCHC Data end point** | The logical target for C/D of compressed packet headers. | 6LN, 6LR, or 6LBR | Peer-pair (Session) | Instance ID (carried in SCHC Control Header) | 1:1 with a Set of Rules/Context; N:1 with an Endpoint. | Equivalent to the -06 "Instance". |
| **SCHC Control Header end point** | The logical target for C/D of the SCHC Control Header. | 6LN, 6LR, or 6LBR | Node-local | Implicit or lower-layer context | 1 per Endpoint/node. | Decodes the Control Header to select the Data end point. |
| **Single-end point network** | A network where each node has a single SCHC Data end point and SoR. | Domain configuration | Domain-wide | Implicit (no Control Header needed) | 1 Instance per Endpoint. | Control Header is fully compressed (0 bits). |
| **Multiple-end point network** | A network where nodes can have multiple SCHC Data end points. | Domain configuration | Domain-wide | Explicit SCHC Control Header | N Instances per Endpoint. | Control Header is >0 bits. |
| **SCHC Control Header** | Metadata prepended to the Datagram to select the Data end point. | Carried in frame | Frame-local | RuleID + residue | 1 per Datagram (optional). | Defined as "SCHC Hdr" in frame formats. |
| **SCHC Instance ID** | Field in the uncompressed Control Header identifying the session. | Control Header | Domain-wide | Unsigned integer | 1:1 with a Session. | Recommended size is 1 to 8 bits. |
| **SCHC Data** | The compressed form of the packet header. | Carried in frame | Frame-local | RuleID + residue | 1 per Datagram. | The C/D residue of the original header. |
| **SCHC Dispatch** | 6LoWPAN Dispatch Type Page 0/1 indicating SCHC compression. | Frame header | Link-local | Bit pattern `01000100` | 1 per frame. | Allocates Page 0/1 dispatch. |
| **SRO** | Straightforward Route-Over multihop mode. | Network layer | Domain-wide | N/A | N/A | All routers store all Rules. |
| **TRO** | Tunneled, RPL-based Route-Over multihop mode. | Network layer | Domain-wide | N/A | N/A | Uses RPL non-storing mode tunnels. |
| **PRO** | Pointer-based Route-Over multihop mode. | Network layer | Domain-wide | SCHC Pointer Dispatch (`01000101`) | N/A | Prepends a pointer to locate residues. |
| **Bit Pointer** | Offset in the compressed header pointing to Hop Limit and Destination residues. | PRO Header | Frame-local | Bit offset | 1 per PRO Header. | Used by 6LRs to locate fields. |
| **Address Residue Length** | Field indicating the length of the known prefix to determine destination residue size. | PRO Header | Frame-local | Bit pattern | 1 per PRO Header. | Encoded as shown in Appendix C. |
| **TPS** | Transition Protocol Stack running SCHC over 6LoWPAN. | Protocol stack | Node-local | SCHC Protocol Number in IPv6 Next Header | N/A | Keeps 6LoWPAN for IPv6, SCHC for UDP/CoAP. |
| **SCHC Stratum** | Portions of the protocol stack where SCHC is applied. | Instance Config | Layer-local | N/A | 1 per Instance. | Can be nested/layered (e.g. TPS). |

## Native architectural model
The native architectural model of `draft-ietf-6lo-schc-15dot4-13` defines how Static Context Header Compression (SCHC) is carried over IEEE 802.15.4 networks within a 6LoWPAN/6lo framework. The model operates under the term "SCHC-Lo network", which represents a 6LoWPAN network that replaces or complements traditional 6LoWPAN header compression (RFC 6282) with SCHC C/D (RFC 8724/RFC 8824). The network consists of three architectural roles: 6LoWPAN Nodes (6LNs) acting as hosts, 6LoWPAN Routers (6LRs) acting as intermediate forwarders, and a 6LoWPAN Border Router (6LBR) acting as the root and gateway.

To organize C/D state, the draft introduces a division between the "SCHC Data end point" and the "SCHC Control Header end point". A SCHC Data end point represents the logical entity that performs compression and decompression of packet headers using a specific Set of Rules (SoR) and Context. A SCHC Control Header end point represents the logical entity that parses the SCHC Control Header (an auxiliary header used to carry session and instance routing information). In all cases, there is a single SCHC Control Header end point on a node, while there can be one or multiple SCHC Data end points.

The draft classifies deployments into "Single-end point networks" and "Multiple-end point networks". In a Single-end point network, each node has a single SCHC Data end point (and thus a single SoR/Context). Because there is no ambiguity about which Data end point applies, the SCHC Control Header can be fully compressed down to 0 bits over the air. In a Multiple-end point network, at least some nodes have multiple SCHC Data end points (e.g. communicating with different peers or using different rule sets). To demultiplex incoming packets, a compressed SCHC Control Header of >0 bits is carried, containing a RuleID and residue that resolve to a "SCHC Instance ID" (identifying the session/instance).

For multihop communication, the draft defines four distinct modes:
1. **Mesh-Under**: Routing is performed at the adaptation layer (L2) using the Mesh Header. The SCHC Control Header can be fully compressed if the originator address in the Mesh Header uniquely identifies the SCHC Data end point.
2. **Straightforward Route-Over (SRO)**: Routing is performed at the IP layer (L3). Every intermediate router (6LR) must possess the complete Set of Rules for all nodes in the network, so it can fully decompress incoming packets and re-compress them before forwarding.
3. **Tunneled, RPL-based Route-Over (TRO)**: Routing is performed at the IP layer using RPL non-storing mode. Packets are encapsulated in an outer IPv6-in-IPv6 tunnel (compressed with RFC 8138) between the 6LN and the Root (6LBR). The SCHC Session is established end-to-end, and intermediate 6LRs only route the outer tunnel header without possessing any SCHC Rules.
4. **Pointer-based Route-Over (PRO)**: Routing is performed at the IP layer. A special "PRO Header" is prepended, containing a "Bit Pointer" and "Address Residue Length". Intermediate 6LRs use the Bit Pointer to locate the Hop Limit and Destination Address residues inside the compressed header, allowing them to decrement the Hop Limit and route the packet without possessing the C/D Rules.

Finally, the draft defines a "Transition Protocol Stack" (TPS) to ease migration from existing 6LoWPAN stacks. In TPS, the IPv6 header is compressed using RFC 6282, while the UDP and CoAP headers are compressed using SCHC. To signal this, the Next Header of the compressed IPv6 header is set to the SCHC Internet Protocol Number. TPS can run with a single SCHC Stratum (compressing UDP and CoAP jointly) or multiple nested SCHC Strata (separating UDP, CoAP outer, and CoAP inner when OSCORE is used).

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **SCHC-Lo network** | The 6LoWPAN network domain. | **Domain** | Direct | Aligned | Aligned | None. | Maps to the logical grouping of Instances. |
| **6LN / 6LR / 6LBR** | Physical/logical node roles. | Hosts a **SCHC Endpoint** | Composite | Aligned | Aligned | A physical equipment can host multiple logical Endpoints. | An Endpoint hosts one or more Instances. |
| **SCHC Data end point** | Target of data header C/D. | **SCHC Instance** | Direct | Aligned | Aligned | Terminology difference; draft calls it "end point" but it acts as the Instance. | Instance holds the Context (SoR + metadata). |
| **SCHC Control Header end point** | Target of Control Header C/D. | **Dispatcher** / Control Instance | Composite | Aligned | Aligned | -06 models this as a Dispatcher function or a pre-routing stage. | Decodes the Control Header before routing to the Instance. |
| **Single-end point network** | Network with 1 Data end point/node. | Domain with **1 Instance/Endpoint** | Profile-specific | Aligned | Aligned | None. | Allows elision of the Control Header. |
| **Multiple-end point network** | Network with multiple Data end points. | Domain with **multiple Instances/Endpoint** | Profile-specific | Aligned | Aligned | None. | Requires explicit Control Header as Discriminator. |
| **SCHC Control Header** | Header to carry multiplexing ID. | **Control Header** | Direct | Aligned | Aligned | None. | Placed before or after the RuleID. |
| **SCHC Instance ID** | Session/Instance identifier. | **Session ID** or **Instance ID** | Direct | Aligned | Aligned | None. | Used by the Dispatcher as a Discriminator. |
| **SCHC Data** | Compressed header of the packet. | **SCHC Datagram** residue | Direct | Aligned | Aligned | None. | RuleID + compression residue. |
| **SCHC Dispatch** | 6LoWPAN Dispatch Type. | Lower-layer **Discriminator** | Direct | Aligned | Aligned | None. | Routes packet to the SCHC Dispatcher in stack. |
| **SRO** | Routers decompress/compress at each hop. | Multi-hop via per-hop **Sessions** | Profile-specific | Aligned | Aligned | None. | Standard hop-by-hop deployment model. |
| **TRO** | End-to-end session tunneled via L3. | End-to-end **Session** over tunnel | Profile-specific | Aligned | Aligned | None. | Standard end-to-end Session over lower-layer tunnel. |
| **PRO** | Intermediate nodes modify residues. | End-to-end **Session** with **Control Header pointers** | Partial / Missing | Aligned | Aligned | -06 does not define intermediate node residue modification without Context. | **ARCHITECTURE GAP**: Exposes need for pointer-based forwarding. |
| **Bit Pointer** | Offset to fields in residue. | **Control Header** metadata | Partial | Aligned | Aligned | -06 has no native notion of pointing to a sub-field in a residue. | Carried in the PRO Header. |
| **Address Residue Length** | Prefix info to determine residue size. | **Control Header** metadata | Partial | Aligned | Aligned | -06 has no native notion of residue size determination by transit nodes. | Carried in the PRO Header. |
| **TPS** | 6LoWPAN IPv6 + SCHC UDP/CoAP. | Nested **Strata** (L3 + L4/L7) | Profile-specific | Aligned | Aligned | None. | Uses Next Header as Discriminator. |
| **SCHC Stratum** | Targeted layers of the stack. | **Stratum** | Direct | Aligned | Aligned | None. | Defines scope of Rules. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Owned by the C/D nodes participating in a Session. | Shared by two or more Instances forming a Domain. | Aligned | A Context is shared by peer Instances to perform C/D. |
| **Ownership of Set of Rules (SoR)** | 1 SoR per SCHC Data end point (Instance). | 1 SoR (part of Context) per SCHC Instance. | Aligned | Changing a Rule requires updating the Instance's Context. |
| **Ownership of Set of Variables (SoV)** | 1 SoV per Session (contains runtime variables). | 1 SoV per Session (contains runtime variables). | Aligned | Session state (timers, counters) is isolated per Session. |
| **Endpoint ↔ SCHC Instance** | A node hosts 1 Endpoint; 1 Instance (single-endpoint) or N Instances (multiple-endpoint). | An Endpoint hosts 1 or more Instances. | Aligned | Multiple logical Instances can coexist on the same Endpoint. |
| **SCHC Instance ↔ Session** | A Session is a point-to-point communication between Instances. | A Session is a communication between two or more Instances. | Aligned | -06 allows multicast/multipoint Sessions, which is compatible. |
| **Sharing of Context between Sessions/Instances** | 6LBR (root) shares Context/SoR across multiple Sessions/Instances. | Multiple Sessions/Instances can share a common Context. | Aligned | Allows efficient memory usage on the central Gateway/6LBR. |
| **RuleID scope** | Unique network-wide (single-endpoint) or unique per Context. | Unique within a Context (or Set of Rules). | Aligned | The Control Header disambiguates the Context first. |
| **Discriminator scope** | DevEUI, IPv6 address, or L2 port unique in Domain. | Used by Dispatcher to route to Instance. | Aligned | Dispatcher uses lower-layer or header info to route. |
| **Control Header processing scope** | Decoded by Control Header end point prior to Data C/D. | Decoded by Dispatcher or Instance prior to RuleID lookup. | Aligned | Control Header must be decoded before Context is accessed. |
| **Domain membership and boundaries** | Defined by the SCHC-Lo network. | Group of Instances sharing a set of Contexts. | Aligned | A single Domain covers the entire SCHC-Lo network. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| **PRO Routing / Residue Modification** | Profile-specific | 6LRs (intermediate nodes) inspect and modify field residues (Hop Limit, Destination Address) within a SCHC Datagram without possessing the decompression Context or Rules. This violates the opaque, end-to-end nature of SCHC C/D Sessions defined in -06. | Partial / Missing (ARCHITECTURE GAP) | A transiting node in -06 is expected to either decompress/re-compress (SRO) or forward the packet opaquely (TRO). Modifying residues inline using pointers is a conceptual extension. |
| **SCHC Data / Control Header end point** | Direct match to Endpoint | The draft uses "end point" (two words) to mean the logical processing targets of the data C/D (Instance) and control header parsing (Dispatcher), whereas -06 defines "Endpoint" (one word) as the logical host entity containing Instances. | Direct match to Instance (for Data) / Composite to Dispatcher (for Control Header) | To prevent confusion with -06's "Endpoint", the draft's "end points" must be mapped to "Instances" and "Dispatcher" functions. |

## Architectural risk points
- **Risk: PRO Layering Violation and Residue Modification**
  - **Why it matters**: In Pointer-based Route-Over (PRO), intermediate routers (6LRs) must parse the PRO Header and locate specific field residues (Hop Limit and Destination Address) inside the SCHC Datagram residue using a Bit Pointer. This requires 6LRs to inspect and modify the compressed payload of the adaptation layer, coupling the network routing plane directly with the bit-level layout of the compressed packet's residue. It violates the end-to-end opacity of the SCHC Datagram.
  - **Consequence for migration**: Migration requires coordinating the Rule design on the endpoints (which must Swap source/destination descriptors to place the destination address at a predictable offset in the residue) with the routing logic on the 6LRs. If the Rule layout changes, the Bit Pointer logic must be updated, increasing the risk of routing failures.
- **Risk: Overloaded "end point" Terminology**
  - **Why it matters**: The draft uses the term "end point" (two words) to refer to the C/D Instances or Dispatcher targets (e.g. "SCHC Data end point", "SCHC Control Header end point") and refers to "Single-end point networks" and "Multiple-end point networks". However, SCHC Architecture -06 defines "Endpoint" (one word) as a logical host entity that can contain multiple Instances. Citing -06 while using mismatched terminology will confuse implementers and spec authors.
  - **Consequence for migration**: The draft must be carefully edited to replace "end point" with "Instance" or "Dispatcher" when referring to processing components, and reserve "Endpoint" for the logical host entity, to ensure clear alignment with -06.
- **Risk: Implicit Role Assignment in Mesh Topologies**
  - **Why it matters**: SCHC C/D relies on asymmetric roles (Dev and App) for Rule matching and compression. In a mesh topology (P2P), nodes have equal capabilities, meaning roles cannot be derived from network topology. The draft states that each C/D entity must know its role before communication occurs, but leaves the exact mechanism out of scope, relying on "prior knowledge".
  - **Consequence for migration**: If peer nodes in a mesh network disagree on their roles (e.g. both assume they are the "Dev" or both "App" for a shared Rule), header decompression will fail. A clear role negotiation or assignment mechanism must be defined.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3.2, 3.2.1, 3.2.2, 3.2.3 | "SCHC Data end point", "SCHC Control Header end point" | Rename "SCHC Data end point" to "SCHC Data Instance" or "SCHC Instance", and "SCHC Control Header end point" to "SCHC Control Header Instance" or "Dispatcher context". | REQUIRED FOR TERMINOLOGY MIGRATION | To align with SCHC Architecture -06, which defines "Endpoint" as the logical host and "Instance" as the C/D processing component. |
| 2 | Section 3.2.2, 3.2.3 | "Single-end point networks", "Multiple-end point networks" | Rename to "Single-Instance networks" and "Multiple-Instance networks" (or "Single-Instance Domains" and "Multiple-Instance Domains"). | REQUIRED FOR TERMINOLOGY MIGRATION | To align with -06, as the distinction is based on the number of Instances hosted per Endpoint, not the number of Endpoints. |
| 3 | Section 6.1 (paragraph 4) | "the Field Descriptors of the IPv6 destination address... MUST appear before the Field Descriptors of the IPv6 source address" | Reframe this as a profile-specific constraint on the Rule design for PRO, rather than a general update to RFC 8724. | REQUIRED FOR CONCEPTUAL ALIGNMENT | RFC 8724 mandates that Field Descriptors appear in the order they exist in the header. Changing this globally violates RFC 8724; it should be constrained only to Contexts used with PRO. |
| 4 | Section 3.5.2 & 3.5.3 | Implicit Instance allocation on 6LBR (root). | Explicitly state that the 6LBR (root) hosts multiple SCHC Instances, each participating in a Session with a specific 6LN. | OPTIONAL CLARIFICATION | Clarifies the cardinality of Instances and Sessions on the root node to align with the -06 model. |
| 5 | Section 12.1 | `[I-D.ietf-schc-architecture]` citation to version -05. | Update reference to point to `draft-ietf-schc-architecture-06`. | EDITORIAL | To reference the current and correct version of the architecture draft. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.5.1 (Control Header for Advanced Use Cases) | Control Header | Currently describes Control Header services as: Multiplexing, Protection, Metadata. | Add a new bullet point: "* Routing/inspection pointers: carry pointers (e.g. Bit Pointers) to locate specific fields or residues within the Datagram, allowing intermediate routing nodes to inspect or modify these fields without possessing the Session's decompression Context." | ARCHITECTURE GAP | Required to naturally express and validate the PRO (Pointer-based Route-Over) forwarding model defined in the draft under study. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **No**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft's PRO mode, but useful generally for other pointer-based routing profiles.**
- What is the single most important migration issue? **The alignment of the draft's "end point" terminology with -06's "Instance/Endpoint" model, and the conceptual framing of the PRO pointer-based residue modification within -06's end-to-end Session model.**
