# Architectural alignment review: draft-sirohi-schc-quic-frame-compression-00

SOURCE CONFIRMED: Exploring SCHC Compression of QUIC Frames — 9 sections / approx 1121 lines — obtained from /Users/apelov/Work/SCHC/archi/schc_drafts/draft-sirohi-schc-quic-frame-compression-00.txt
SOURCE CONFIRMED: Static Context Header Compression (SCHC) Architecture — 9 sections / approx 1681 lines — obtained from /Users/apelov/Work/SCHC/archi/schc_drafts/draft-ietf-schc-architecture-06.txt

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **Very High** | Highest grade | The core compression logic of the draft relies entirely on the rule-based framework of SCHC, where fields are matched and replaced by a RuleID and residue. Every architectural model in the draft (sequence rules, per-frame rules, unified vs separate compressors) corresponds directly to -06 concepts (Rules, Contexts, Stratum, and Multiple Instances/Endpoints). There are no conceptual mismatches or need to re-interpret the draft's technical model. |
| **Transition difficulty** | **Easy** | While the mapping is conceptually straightforward and can be represented cleanly, it is not "Very Easy" (i.e. purely mechanical find-and-replace). It requires non-trivial architectural judgment in Section 6 to properly describe the inner and outer compressors as separate SCHC Endpoints/Instances operating on different Strata, and in Section 5 to map the QUIC extension frame to a Control Header preceding a SCHC Datagram. | No major redrafting, redesign, or changes to the protocol behavior/calculations are required. The mapping decisions are clear, stable, and can be documented in a concise unified diff without introducing any new assumptions or modifying technical intent. |
| **SCHC Architecture adaptation need** | **None** | Highest grade | Every architectural concept required by the draft (such as multiple instances at different layers of the stack) is already fully defined and supported in -06 (e.g. through the 'Stratum' concept and multiple Endpoints/Instances on the same equipment). No modifications or gaps were identified. |

## Executive assessment
The reference architecture `draft-ietf-schc-architecture-06` can naturally and completely express the concepts and technical model of `draft-sirohi-schc-quic-frame-compression-00`. The principal conceptual mapping relates the draft's "inner compressor" and "outer compressor" to two separate SCHC Endpoints (or Instances) operating on different Strata (the QUIC frame stratum and the IP/UDP stratum) on the same physical equipment. The principal migration difficulty is ensuring that the implementation architecture and integration options (like the alternative payload syntax and extension frames) are framed using the formal -06 concepts of Datagrams, Control Headers, Dispatchers, and Discriminators rather than implementation-specific terms like "compressor container." No architectural gaps exist in `draft-ietf-schc-architecture-06`, as all required mechanisms are already natively supported.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **Frame metadata / fields** | The protocol header fields of QUIC transport frames (e.g. Frame Type, Stream ID, Offset, Length, Largest Acknowledged, ACK Delay, ACK ranges) carrying transport and stream control information. | Participating QUIC endpoints | QUIC connection / packet | Parsed from the QUIC packet payload | Multiple frames per packet | Application data in STREAM frames is not compressed. |
| **Static context** | Shared set of rules and parameters known by the sender and receiver before compression begins. | Participating QUIC endpoints | Peer-pair (QUIC connection) | Identified by Rule ID | 1 Context per peer-pair (implied) | Can be pre-provisioned or negotiated. |
| **Rule ID** | A compact identifier replacing the matched frame header fields. | Compressed frame payload / datagram | Within the static context | Carried on the wire | 1 Rule ID per compressed frame or sequence | Fits standard SCHC Rule ID concept. |
| **Sequence rule (One Rule for Complete Frame Sequence)** | A rule matching a specific sequence of multiple frames in one packet. | Static context | Packet-level | A single Rule ID | 1 rule matches N frames in a fixed order | Highly efficient for predictable traffic. |
| **Per-frame rule (One Rule per Frame)** | A rule that compresses a single frame type independently. | Static context | Frame-level | Rule ID per frame | 1 rule matches 1 frame; multiple compressed frames per packet | Better rule reuse but higher per-frame overhead. |
| **Stateful rule** | A rule deriving field values (offsets, packet numbers) from prior packets or connection state. | Compressor/Decompressor state | Connection-level | Implicitly selected based on connection state or Rule ID | 1 state per connection | Vulnerable to packet loss and reordering. |
| **Alternative packet-payload syntax** | An integration mode where the entire protected payload is replaced by a SCHC representation. | QUIC packet payload parser | Packet-level | Rule ID as the first byte of the payload | 1 payload syntax per connection | Lowest overhead; requires deep QUIC integration. |
| **Generic compressed-frame extension** | A QUIC extension frame containing an Extension Frame Type, Container Length, and SCHC Representation. | QUIC frame parser | Frame-level | Extension Frame Type | N extension frames per packet | Less invasive; higher overhead. |
| **Extension frame per compressed frame type** | Allocating a unique QUIC extension Frame Type for each compressed frame shape. | QUIC frame parser | Frame-level | Unique Extension Frame Type | N extension frames per packet | Extension Frame Type acts as the rule selector. |
| **Unified SCHC compressor** | A single compression entity that compresses IP, UDP, outer QUIC, and inner QUIC frames. | Integrated network stack | Multi-layer (cross-layer) | Implicit | 1 unified compressor per node | Tight coupling; crosses encryption boundary. |
| **Separate inner and outer compressors** | An inner compressor handles QUIC frames before encryption; an outer compressor handles IP/UDP/outer-QUIC headers after packet construction. | QUIC stack (inner) and network stack (outer) | Layer-specific | Separate Rule IDs and context | 2 compressors per node | Matches security boundary; allows reuse of components. |

## Native architectural model
The native architectural model of `draft-sirohi-schc-quic-frame-compression-00` centers on compressing QUIC frame metadata inside participating QUIC endpoints. QUIC frames (such as STREAM and ACK) carry transport control information and are already compactly encoded using variable-length integers. Frame compression aims to remove redundant metadata (like Frame Types, Stream IDs, or ACK ranges) for highly constrained links, without altering the application payload or transport semantics.

Because QUIC packet payloads are encrypted by QUIC-TLS, any frame compression must occur before encryption on the sending side, and decompression must occur after decryption on the receiving side. The compressed bytes remain protected by the connection's packet protection.

The compression process relies on a shared static context containing rules. The sender selects a rule matching the frame or frame sequence, replaces the matched fields with a Rule ID, and transmits the Rule ID and any residual values (the residue). The receiver uses the same rule to reconstruct the original frames.

To organize the rules, the draft defines three approaches. Sequence rules compress a complete sequence of expected frames in a single packet, sharing the fixed Rule ID overhead but causing rule-set growth. Per-frame rules compress each frame type independently, maximizing rule reuse but requiring per-frame overhead to delineate boundaries. Generic rules serve as a simple baseline, removing only constant fields.

Stateful rules can achieve higher compression by deriving fields (such as offsets or acknowledgment numbers) from prior packets. However, because QUIC delivery order is not guaranteed and recovery retransmits data rather than packet bytes, stateful compression across packets is risky. Deriving values within a single packet container (e.g. subsequent stream fragment offsets) is safer because the reference data is received atomically.

The draft presents three options to integrate compression into QUIC. A negotiated alternative packet-payload syntax replaces the entire protected payload with a compressed representation starting with a Rule ID. A generic compressed-frame extension encapsulates compressed frames in a standard QUIC extension frame containing a length and Rule ID. A third option allocates distinct extension Frame Types for specific compressed frame shapes.

Finally, the implementation architecture can be unified or split. A unified compressor handles all layers (IP, UDP, outer QUIC, and inner frames) in one context, which is complex because it crosses the encryption boundary. A split architecture separates the inner compressor (inside the QUIC stack, compressing frames) from the outer compressor (outside QUIC, compressing IP/UDP/QUIC headers), which matches the security boundary and allows reuse of existing SCHC components.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **Frame metadata / fields** | QUIC frame headers (Frame Type, Stream ID, etc.) | C/D Field Descriptors in a Rule | Direct | Aligned (fields scoped to packet/datagram) | Aligned (1:1 mapping of fields to descriptors) | None | A Parser dissects these fields. |
| **Static context** | Shared set of rules and parameters | Context / Set of Rules (SoR) | Direct | Aligned (shared between Instances in a Session) | Aligned (1:1 Context to SoR) | None | -06 formalizes Context to include both SoR and parser metadata. |
| **Rule ID** | Compact rule selector | RuleID | Direct | Aligned (unique within a Context) | Aligned (1:1 RuleID to Rule) | None | Formalized as RuleID in -06. |
| **Sequence rule** | Rule matching a sequence of frames | Rule | Profile-specific | Aligned (packet-level scope) | Aligned (1 Rule matches N fields) | None | A Rule can contain field descriptors for consecutive frames parsed as one structure. |
| **Per-frame rule** | Rule compressing a single frame type | Rule | Direct | Aligned (frame-level/header-level scope) | Aligned (1 Rule per frame type) | None | Matches the standard model where a Rule compresses a specific protocol header. |
| **Stateful rule** | Rule deriving values from connection state | Rule using Set of Variables (SoV) | Composite | Aligned (connection scope maps to Session scope) | Aligned (1 SoV per Session) | None | Stateful compression relies on updating runtime session parameters in the SoV. |
| **Alternative packet-payload syntax** | Protected payload replaced by SCHC representation | SCHC Datagram (RuleID + residue) | Direct | Aligned (packet-level scope) | Aligned (1 payload to 1 Datagram) | None | Fits the default Datagram Format of -06 (RuleID followed by residue). |
| **Generic compressed-frame extension** | QUIC extension frame containing SCHC representation | SCHC Datagram with preceding Control Header | Composite | Aligned (the frame header acts as a Control Header) | Aligned (1:1 encapsulation of Datagram in frame) | None | In -06, a Control Header can precede the RuleID to carry length and type. |
| **Extension frame per compressed frame type** | Frame Type representing a compressed frame shape | RuleID / Dispatcher Discriminator | Composite | Aligned (outer framing layer serves to route and select rule) | Aligned (1 Frame Type to 1 Rule) | None | The lower-layer Frame Type acts as both the discriminator for the Instance and the RuleID. |
| **Unified SCHC compressor** | Single compressor for outer and inner layers | SCHC Instance spanning multiple Strata | Direct | Aligned (operates across contiguous layers of the stack) | Aligned (1 Instance per node) | None | Corresponds to an Instance with a Context containing rules for multiple layers. |
| **Separate inner and outer compressors** | Inner compressor for frames, outer for IP/UDP/QUIC headers | Separate SCHC Endpoints / Instances on different Strata | Direct | Aligned (each operates on its own Stratum) | Aligned (2 Instances/Endpoints on the same host) | None | Under -06, multiple Endpoints/Instances can coexist on the same equipment to serve different Strata. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **ownership of Context** | Shared between participating QUIC endpoints. | Shared between participating Instances of the Session. | Aligned | Context must be provisioned or fetched on both ends. |
| **ownership of Set of Rules** | Contained in the static context. | Part of the Context. | Aligned | Rules are static and identical on both ends. |
| **ownership of Set of Variables** | Connection-level state (e.g. for offset/ACK tracking). | Runtime parameters stored in the SoV. | Aligned | Stateful rules require synchronized SoV between the Instances. |
| **Endpoint↔SCHC Instance** | In split mode, two compressors (inner and outer) operate independently. | An Endpoint hosts one or more Instances. Or multiple Endpoints on one node. | Aligned | Can be modeled as one Endpoint with two Instances, or two separate Endpoints (one for QUIC payload stratum, one for IP/UDP stratum). |
| **SCHC Instance↔Session** | Inner compressor communicates with remote inner; outer with remote outer. | Session is a communication between Instances sharing a Context. | Aligned | Two distinct Sessions are established: an inner Session for frames, and an outer Session for headers. |
| **sharing of Context between Sessions/Instances** | Multiple connections could reuse the same rules. | Multiple Sessions/Instances can share a common Context in a Domain. | Aligned | Standard rules can be shared across multiple QUIC connections. |
| **RuleID scope** | Identifies the rule inside the context. | Unique within the Context. | Aligned | RuleID is only meaningful inside the associated Context/Session. |
| **Discriminator scope** | Identified by Extension Frame Type, negotiated state, or Rule ID. | Used by Dispatcher to route to correct Instance. | Aligned | Dispatcher routes to the inner or outer Instance based on layer context. |
| **Control Header processing scope** | Extension Frame Type + Container Length preceding the compressed frames. | Control Header placed before or after RuleID, processed before Context-dependent fields. | Aligned | The decompressor reads the length and type to delineate the SCHC Datagram. |
| **Domain membership and boundaries** | Participating QUIC endpoints. | Instances sharing a common set of Contexts. | Aligned | The QUIC client and server belong to the same Domain. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk: Stateful compression synchronization under loss**
  - **Why it matters:** If a stateful rule derives fields (like Stream Offsets or Largest Acknowledged) from prior packets, packet loss or reordering can cause desynchronization of the Set of Variables (SoV) between the compressing and decompressing Instances. Unlike IP/UDP where packet loss is handled by upper layers, QUIC frame decompression failure would cause a decryption or parsing error, resulting in a fatal connection teardown (CONNECTION_CLOSE).
  - **Consequence for migration:** The profile for QUIC frame compression must strictly limit stateful rules to intra-packet derivations (e.g. deriving offsets from fragments in the same packet) or define a robust, out-of-band resynchronization mechanism, which -06 does not define.
- **Risk: Dispatcher complexity in the split architecture**
  - **Why it matters:** In a split architecture, the inner Instance processes frames before encryption, and the outer Instance processes IP/UDP/QUIC headers after packet construction. If both are hosted by a single Endpoint, the Dispatcher must handle nested interception and routing. This requires the Dispatcher to intercept packets at two different stages of the network stack, which increases stack integration complexity and breaks the assumption of a single packet flow.
  - **Consequence for migration:** The implementation should model the inner and outer compressors as two distinct Endpoints on the same physical equipment, each with its own local Dispatcher, rather than a single Endpoint.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 2.2, 2.3, 4.1, 5.1 | "Rule ID" | Change to "RuleID" | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal spelling used in draft-ietf-schc-architecture-06. |
| 2 | Section 2.2, 4.3, 6.1, 8 | "static context", "context" | Capitalize as "Context" when referring to the shared SCHC ruleset and parser metadata | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal term defined in draft-ietf-schc-architecture-06. |
| 3 | Section 6.1 | "Unified SCHC Compressor" / "context" | Describe as a single SCHC Instance on an Endpoint, with a Context whose Stratum spans the IP, UDP, and QUIC frame layers. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal -06 architectural concepts of Instance and Stratum. |
| 4 | Section 6.2 | "Separate Inner and Outer Compressors" | Describe as separate SCHC Endpoints (or Instances) operating at different Strata (inner frames vs outer headers) on the same physical equipment. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concept of Stratum and the support for multiple Endpoints/Instances on the same equipment. |
| 5 | Section 5.2 | "Extension Frame Type" and "Container Length" | Frame as a Control Header placed before the RuleID of the SCHC Datagram. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concept of a Control Header and its placement options. |
| 6 | Section 5.3 | "Extension Frame per Compressed Frame Type" | Frame as the Extension Frame Type acting as a Dispatcher Discriminator to route the incoming packet to the correct SCHC Instance, representing the RuleID. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concepts of Dispatcher, Discriminator, and RuleID. |
| 7 | Section 4.4 | "prior packet state" / "compression state" | Describe stateful rules in terms of the Set of Variables (SoV), distinguishing it from the static Set of Rules (SoR) in the Context. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 definition of Set of Variables (SoV) for runtime state. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.2.4 | Multiple Instances / Stratum | N/A | Add a paragraph explaining that separate Endpoints or Instances can operate at different Strata in a nested/layered manner, where the output of an inner Stratum Instance is encapsulated and subsequently processed as payload by an outer Stratum Instance. | OPTIONAL CLARIFICATION | Clarifies that nested/layered SCHC instances (such as inner QUIC frames and outer IP/UDP headers) are fully compatible with the architecture. |

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (It requires minor rewording in Section 6 to frame the implementation architectures using the formal -06 Concepts, but the rest is mechanical terminology replacements).
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable (no gap exists).**
- What is the single most important migration issue? **Mapping the implementation architectures in Section 6 (specifically the separate inner and outer compressors) to the -06 concepts of separate Endpoints/Instances operating on different Strata (inner QUIC frame stratum vs outer IP/UDP/QUIC header stratum).**
