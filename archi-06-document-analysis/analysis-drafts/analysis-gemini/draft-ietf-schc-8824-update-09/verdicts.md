# Architectural alignment review: draft-ietf-schc-8824-update-09

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | The core conceptual models of both specifications are fully aligned. The draft's entities (Device, NGW, App, Proxy) and technical procedures (Inner/Outer compression, hop-by-hop routing) map directly to -06 concepts (Endpoint, Instance, Session, Domain) without requiring any reinterpretation or structural changes to the architecture. |
| Transition difficulty | Easy | It is not "Very Easy" because it is not a purely mechanical search-and-replace. It requires restructuring several paragraphs in Section 2 and Section 9 to explicitly frame the topologies and proxy behavior using the -06 model (Endpoints, Instances, Sessions). | The technical intent and all field-level rules remain completely unchanged. The architectural descriptions in the draft are limited to a few specific sections (Sections 1, 2, 9), so the volume of text that needs rewriting is small, and the mappings are straightforward and repeatable. |
| SCHC Architecture adaptation need | None | Highest grade | There are zero architectural gaps. Every concept required to express the draft (multiple strata, multiple instances on an endpoint, multiple domains, hop-by-hop proxying) is already fully defined and supported by -06. |

## Executive assessment
SCHC Architecture -06 can naturally express the draft under study without any modification. The principal conceptual mapping involves representing the Device, NGW, App, and Proxy as physical hosts running logical Endpoints, with Instances executing SCHC C/D within Sessions. The OSCORE Inner/Outer layered compression is mapped to separate SCHC Instances operating at different Strata (Inner CoAP vs. Outer CoAP) on the same Endpoint. The principal migration difficulty is updating the text in Sections 1, 2, and 9 to align with these -06 concepts. No architectural gaps exist.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Device | A constrained node running a CoAP client or server application. | Physical node at the edge of the LPWAN | Node-local | DevEUI (LoRaWAN), IP Address/Prefix | 1 Endpoint containing 1 or more SCHC Instances | Standard constrained IoT device |
| Network Gateway (NGW) | A gateway at the LPWAN boundary performing SCHC C/D on behalf of the Device. | Physical gateway node | Network-boundary | NGW IP address, gateway identifier | 1 Endpoint containing 1 or more SCHC Instances | Unconstrained relative to Device |
| Application Server (App) | The destination CoAP application server communicating with the Device. | Physical host over the Internet | End-to-end peer | App IP address, URI authority | 1 Endpoint containing 1 or more SCHC Instances | Can participate in end-to-end SCHC compression |
| CoAP Proxy | An intermediary CoAP node that forwards messages, potentially modifying headers and options. | Physical node, often co-located on the NGW | Hop-by-hop intermediate node | Proxy IP address | 1 Endpoint hosting ingress/egress Instances for adjacent Sessions | Bridges two separate SCHC Sessions |
| Inner Rules / Context | SCHC Rules used to compress/decompress the Inner Plaintext (sensitive/encrypted options). | Device and App (end-to-end) | End-to-end session | Inner RuleID | 1 Context containing Inner Rules | Encrypted before transmission |
| Outer Rules / Context | SCHC Rules used to compress/decompress the Outer OSCORE message (visible options). | Device and Proxy, or Proxy and App | Hop-by-hop session | Outer RuleID | 1 Context containing Outer Rules | Not encrypted, visible to intermediaries |
| RuleID | An identifier pointing to a specific compression/decompression rule. | Pre-pended to the SCHC Datagram | Context-local | 1 to 8 bits value (e.g. carried in LoRaWAN FPort) | N Rules per Context | Selects the rule for processing |
| Token & Token Length | Fields in CoAP header used to match request/response. | CoAP header | Session/hop-local | Variable length, unique per peer pair | 1 Token per CoAP message | Compressed using the dynamic "tkl" function |
| OSCORE Option Subfields | Subfields within the OSCORE option value (flags, piv, kid_ctx, kid) compressed separately. | OSCORE option value | Message-local | Individual subfields mapped by distinct FIDs | 1 set of subfields per OSCORE option | Custom decomposition of option value |
| tkl / osc.piv functions | Dynamic parsing functions returning the length of Token and piv fields. | Rule definition | Rule-local | Function name | Associated with Token and piv Field Descriptors | Extends static length capabilities of RFC 8724 |
| Payload Marker (0xFF) | Indicator separating headers from payload in CoAP. | Boundary between header and payload | Message-local | Fixed byte value 0xFF | 1 per message with payload | Elided on compression, prepended on decompression |

## Native architectural model
The draft under study, `draft-ietf-schc-8824-update-09`, defines how to apply the Static Context Header Compression (SCHC) framework (defined in RFC 8724) to the Constrained Application Protocol (CoAP). CoAP is an application-layer protocol with highly flexible headers, including a variable number of variable-length options and request-response asymmetry, unlike the fixed-header protocols like IPv6 and UDP.

The draft outlines three distinct deployment architectures. In the first architecture (LPWAN boundary compression), SCHC compression is performed above Layer 2 on both the Device and the Network Gateway (NGW) for the entire IPv6/UDP/CoAP stack. The NGW decompresses the packets and forwards standard IPv6/UDP/CoAP packets to the App. In the second architecture (standalone end-to-end compression), SCHC is applied directly at the CoAP layer, and the compressed payload is encrypted using DTLS. The third architecture incorporates OSCORE, where a single CoAP message is split into an Inner Plaintext (sensitive options, encrypted end-to-end) and an Outer Message (non-sensitive options, visible to proxies).

Under the OSCORE architecture, SCHC compression is performed in two separate stages: Inner SCHC Compression (applied to the Inner Plaintext before encryption) and Outer SCHC Compression (applied to the Outer Message after encryption). The recipient performs decompression in the reverse order.

Intermediaries such as CoAP proxies can participate in hop-by-hop compression and decompression of the Outer headers, modifying Message IDs and Tokens, while the Inner headers remain compressed and encrypted end-to-end between the origin client and server.

To achieve maximum compression efficiency without prepending explicit length indicators for variable-length fields (such as the CoAP Token and OSCORE Partial IV), the draft introduces dynamic length-evaluation functions: the "tkl" function (which returns the length of the Token field based on the value of the Token Length field) and the "osc.piv" function (which returns the length of the OSCORE piv field based on the n flag).

Furthermore, the draft defines specific FIDs for new CoAP options (such as Proxy-Cri, Proxy-Scheme-Number, Hop-Limit, Echo, Request-Tag, EDHOC, Q-Block1, Q-Block2) and extends the OSCORE Option representation into four subfields: flags, piv, kid_ctx, and kid. These subfields are treated as distinct fields in the SCHC Rules, enabling fine-grained compression of security context information.

The 0xFF payload marker is treated as an implicit boundary: it is elided by the compressor and reconstructed by the decompressor on both the Inner and Outer layers.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Device | A constrained node running a CoAP client or server application. | Endpoint (hosting Instance(s)) | Direct | Aligned. Both represent a logical entity providing SCHC functionality on the constrained host. | Aligned (1 Endpoint, N Instances). | None. | Standard constrained IoT device. |
| Network Gateway (NGW) | A gateway at the LPWAN boundary performing SCHC C/D on behalf of the Device. | Endpoint (hosting Instance(s)) | Direct | Aligned. | Aligned (hosts one or more Instances corresponding to Devices). | None. | Unconstrained relative to Device. |
| Application Server (App) | The destination CoAP application server communicating with the Device. | Endpoint (hosting Instance(s)) | Direct | Aligned. | Aligned. | None. | Can participate in end-to-end SCHC compression. |
| CoAP Proxy | An intermediary CoAP node that forwards messages, potentially modifying headers and options. | Endpoint hosting multiple Instances (for separate Session legs) | Composite | Aligned. The proxy operates as a bridge between two separate SCHC Sessions. | Aligned. | None. | Bridges two separate SCHC Sessions. |
| Inner Rules / Context | SCHC Rules used to compress/decompress the Inner Plaintext (sensitive/encrypted options). | Context (associated with an end-to-end Session/Instance) | Direct | Aligned. | Aligned. | None. | Encrypted before transmission. |
| Outer Rules / Context | SCHC Rules used to compress/decompress the Outer OSCORE message (visible options). | Context (associated with hop-by-hop Sessions/Instances) | Direct | Aligned. | Aligned. | None. | Not encrypted, visible to intermediaries. |
| RuleID | An identifier pointing to a specific compression/decompression rule. | RuleID | Direct | Aligned. | Aligned. | None. | Selects the rule for processing. |
| Token & Token Length | Fields in CoAP header used to match request/response. | Field ID and Field Length within a Rule (defined in Parser / Data Model) | Profile-specific | Aligned. | Aligned. | Dynamic calculation of FL is a profile-specific parsing mechanism. | Compressed using the dynamic "tkl" function. |
| OSCORE Option Subfields | Subfields within the OSCORE option value (flags, piv, kid_ctx, kid) compressed separately. | Subfields mapped to separate Field IDs in the Parser / Data Model | Profile-specific | Aligned. | Aligned. | -06 allows Parser to dissect headers; the draft decomposes the OSCORE option into separate subfields. | Custom decomposition of option value. |
| tkl / osc.piv functions | Dynamic parsing functions returning the length of Token and piv fields. | Parser / Rule parsing logic | Profile-specific | Aligned. | Aligned. | -06 leaves the rule execution details to RFC 8724 and profiles. | Extends static length capabilities of RFC 8724. |
| Payload Marker (0xFF) | Indicator separating headers from payload in CoAP. | Parser / C/D engine boundary behavior | Profile-specific | Aligned. | Aligned. | Standard behavior in SCHC profiles. | Elided on compression, prepended on decompression. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| ownership of Context | Shared between Device and NGW (Outer/Regular) or Device and App (Inner). | Shared by two or more Instances. | Aligned | Context is provisioned/shared within the Session. |
| ownership of Set of Rules | Contained in the Context. | Part of the Context. | Aligned | Identical. |
| ownership of Set of Variables | Per-session state (timers, reassembly state). | Maintained per Session. | Aligned | Identical. |
| Endpoint↔SCHC Instance | Device has a single Instance. NGW can have one shared or one per-session Instance. | Endpoint can host multiple Instances. | Aligned | -06 naturally supports both Device (single Instance) and NGW (multiple/shared Instances) configurations. |
| SCHC Instance↔Session | Communication between Instances sharing a Context. | A Session is a communication session between Instances. | Aligned | Matches perfectly. |
| sharing of Context between Sessions/Instances | Gateway can use a single Context (same SoR) for multiple Sessions/Devices. | Multiple Sessions/Instances can share the same Context. | Aligned | Matches perfectly. |
| RuleID scope | Local to the Context/Session. | Unique within the scope of the Domain/Context. | Aligned | Matches. |
| Discriminator scope | DevEUI/fPort (LoRaWAN) or connection (PPP). | Used by Dispatcher to route Datagrams to correct Instance. | Aligned | Matches. |
| Control Header processing scope | OSCORE Outer header acts as a shell; optional Control Header can carry metadata/integrity. | Control Header can carry multiplexing, protection, or metadata. | Aligned | The draft's use of Outer headers and potential Control Headers fits the -06 model. |
| Domain membership and boundaries | Rules can come from different provisioning domains (Inner vs Outer). | Domain is a grouping of Instances sharing Contexts. Multiple Endpoints on the same physical equipment can serve different Domains. | Aligned | The dual-domain structure of OSCORE fits the multiple-Endpoint/multiple-Domain model in -06. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk:** Chaining of Instances (Inner/Outer) on the same Endpoint.
  - **Why it matters:** The draft relies on OSCORE, which splits CoAP into Inner and Outer headers. This requires applying SCHC twice (Inner SCHC and Outer SCHC) on the same message, with an encryption step in between.
  - **Consequence for migration:** The architecture must allow a packet to be routed from the network stack to the Inner Instance, then back to the security layer (OSCORE), and then to the Outer Instance. If this interface is not well-defined, implementations may struggle to integrate the two SCHC layers.
- **Risk:** Provisioning and management of Dual-Domain Contexts.
  - **Why it matters:** The Inner Context (shared between Device and App) and the Outer Context (shared between Device and NGW/Proxy) may come from different provisioning domains.
  - **Consequence for migration:** The physical device must support multiple Endpoints or Domains, meaning the Instance Manager must coordinate Contexts from different Domain Managers, which may have different security policies.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1 (page 4, line 203) | compressing CoAP headers requires installing common Rules between the two SCHC instances | compressing CoAP headers requires installing a common Context containing Rules shared between the communicating SCHC Instances within a Session | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with the -06 concept of Instances communicating in a Session using a Context. |
| 2 | Section 2 (pages 7-9, lines 364-374, 399-421, 453-491) | Figure 1, 2, 3 descriptions and mentions of "SCHC instances", "adaptation layers", and "provisioning domains" | Update text to describe the physical nodes (Device, NGW, App) hosting SCHC Endpoints and Instances communicating within Sessions using Contexts, and clarify the stratification of Inner/Outer Instances. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the applicability scenarios with the -06 terminology. |
| 3 | Section 9 (pages 46-47, lines 2555-2666) | Proxy descriptions and hop-by-hop processing using "adjacent hops" and "application endpoints" | Frame the CoAP proxy as hosting a SCHC Endpoint with separate ingress and egress Instances participating in separate Sessions with adjacent hops. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns proxy hop-by-hop forwarding with the -06 Instance/Session model. |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? The single most important migration issue is ensuring that the layering of Inner and Outer SCHC Instances (for OSCORE) and the hop-by-hop proxying Sessions are clearly framed and defined using the Endpoint/Instance/Session model of -06.
