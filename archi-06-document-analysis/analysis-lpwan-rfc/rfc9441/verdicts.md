# Architectural alignment review: rfc9441

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All concepts in RFC 9441 (Compound ACK message format, ACK-on-Error FSM, per-packet timers/counters, profile parameters, and YANG module extension) map directly and naturally into SCHC Architecture -06 concepts (Datagram, F/R SCHC Function, Instance Role, Session SoV, Context / SoR, Instance Configuration, Data Model) without requiring any conceptual reinterpretation or reframing. -06 even explicitly references RFC 9441 in Section 4.2.2.2. |
| Transition difficulty | Easy | Migrating the draft requires slight architectural contextualization in Section 1 and Section 3.2 to frame the sender and receiver as SCHC Instances operating within a Session and updating the Session's Set of Variables (SoV), rather than simple string find-and-replace. | Technical intent, message encoding, state machine transitions, and YANG schema remain completely unchanged. The mapping decisions across all sections are clear, repeatable, and non-disruptive. |
| SCHC Architecture adaptation need | None | -06 already contains all required concepts (Datagram, F/R SCHC Function, SCHC Instance, Session, SoV, Context, SoR, Data Model) and explicitly references RFC 9441 in Section 4.2.2.2. Zero ARCHITECTURE GAP items are needed. | Lowest grade |

## Executive assessment

RFC 9441 ("Static Context Header Compression (SCHC) Compound Acknowledgement (ACK)") defines an extension to the SCHC Fragmentation and Reassembly (F/R) ACK-on-Error mode (updating RFC 8724) and its corresponding YANG data model (updating RFC 9363). It introduces a SCHC Compound ACK message format that accumulates loss bitmaps across multiple windows into a single layer-2 frame, updates sender and receiver behaviors, and adds management data model leaves for profile configuration.

SCHC Architecture -06 (`draft-ietf-schc-architecture-06`) can **naturally and fully express** all concepts, relationships, and behaviors defined in RFC 9441. In fact, Section 4.2.2.2 of SCHC Architecture -06 explicitly acknowledges RFC 9441 as the reference specification for Compound ACK in ACK-on-Error mode.

The principal conceptual mapping maps:
- The **SCHC Compound ACK Message** to an F/R **Datagram** exchanged between SCHC Instances;
- The **Fragment Sender** and **Fragment Receiver** to **SCHC Instance Roles** executing the F/R function within an Endpoint;
- The per-packet retransmission state (Attempts counters, Retransmission Timer, Inactivity Timer) to the per-session **Set of Variables (SoV)**;
- The **RuleID** to a Rule within the **Set of Rules (SoR)** contained in the shared **Context**;
- The **DTag** to a session-level packet discriminator key within the **SoV**; and
- The YANG data model extension to the SCHC **Data Model** managed by the **Domain Manager** and stored in the **Context Repository**.

No architectural gaps exist in SCHC Architecture -06 for RFC 9441 (Adaptation need: **None**). Conceptual equivalence is **Very High**, and transition difficulty is **Easy**, consisting primarily of terminology alignment and framing per-packet runtime state as part of the Session's Set of Variables (SoV).

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC Compound ACK Message | Failure SCHC ACK carrying multiple window numbers (W) and corresponding loss bitmaps in a single L2-word aligned message. | Exchanged from Fragment Receiver to Fragment Sender over L2 link. | Packet / Datagram scope | Identified by RuleID + DTag + ACK Header (C=0, W=w1) | 1 message reports losses for 1 to N windows of a fragmented SCHC Packet. | Extends RFC 8724 single-window failure ACK format. |
| ACK-on-Error Mode | Reliability mode for SCHC fragmentation using windows of tiles, supporting variable MTU and out-of-order L2 delivery with feedback. | Executed by SCHC F/R entities at sender and receiver. | Link / Communication relationship scope | Selected by RuleID in Context | 1 F/R mode configured per F/R Rule. | Replaces Section 8.4.3 of RFC 8724. |
| Fragment Sender | Actor that fragments SCHC Packets into tiles, transmits Regular/All-1 fragments, tracks retransmissions, and processes ACKs. | Sending host / node protocol stack. | Node / Session role | Associated with RuleID + DTag active session | 1 Sender per fragmented SCHC Packet transmission. | Maintains per-(RuleID, DTag) Attempts counter and Retransmission Timer. |
| Fragment Receiver | Actor that receives tiles, reassembles SCHC Packets, tracks inactivity, generates Compound ACKs, and verifies RCS integrity. | Receiving host / node protocol stack. | Node / Session role | Associated with RuleID + DTag active session | 1 Receiver per fragmented SCHC Packet reassembly. | Maintains per-(RuleID, DTag) Attempts counter and Inactivity Timer. |
| RuleID & DTag Pair | Active identifier pair indexing a fragmentation session for a specific SCHC Packet transmission. | Shared between sender and receiver. | Packet transmission session scope | RuleID (F/R rule index) + DTag (datagram tag) | 1 pair per active fragmented packet; RuleID is 1:N, DTag is unique per active packet. | RuleID selects Rule parameters; DTag disambiguates concurrent/interleaved packets. |
| Window (W) | Absolute window index grouping a fixed number (`WINDOW_SIZE`) of tiles within a fragmented SCHC Packet. | F/R state structure. | Packet-local scope | Window number field (W) | 1 Packet has 2^M windows (0 to 2^M - 1). | W field size (M bits) specified in Profile. |
| Bitmap & Compressed Bitmap | Bit array reporting reception status of tiles in a window (1=received, 0=lost). Last bitmap may be compressed to omit trailing bits. | Carried inside SCHC Compound ACK payload. | Datagram payload scope | Position within Compound ACK message | 1 bitmap per reported window; last bitmap optional compression. | Compression allowed only on the final reported window in a Compound ACK. |
| Attempts Counter & Retransmission Timer | Retransmission control state maintained by sender for ACK requests and tile retransmissions. | Sender local state. | Session / Packet scope | Keyed by (RuleID, DTag) | 1 counter + 1 timer per active (RuleID, DTag) pair at sender. | Reset on All-1 / ACK REQ transmission; bounded by `MAX_ACK_REQUESTS`. |
| Attempts Counter & Inactivity Timer | Timeout and abort control state maintained by receiver for packet reassembly and feedback generation. | Receiver local state. | Session / Packet scope | Keyed by (RuleID, DTag) | 1 counter + 1 timer per active (RuleID, DTag) pair at receiver. | Reset on fragment reception; bounded by `MAX_ACK_REQUESTS`. |
| Profile Parameters | Technology-specific F/R configuration parameters (tile size, M, N, WINDOW_SIZE, RCS algorithm, timers, Compound ACK usage). | Provisioned profile configuration. | Profile / Rule scope | Bound to RuleID | 1 set of parameters per F/R RuleID. | Specified in technology-specific SCHC Profiles (e.g. RFC 9011). |
| YANG Data Model Extension (`ietf-schc-compound-ack`) | YANG 1.1 module extending `ietf-schc` (RFC 9363) with leaves for `bitmap-format` and `last-bitmap-compression`. | Management plane / configuration store. | Administrative domain scope | Module name `ietf-schc-compound-ack`, namespace URN | Augments `/schc:schc/schc:rule/.../schc:ack-on-error` node. | Allows NETCONF/RESTCONF provisioning of Compound ACK rule parameters. |

## Native architectural model

RFC 9441 specifies an optimization for the Static Context Header Compression (SCHC) Fragmentation and Reassembly (F/R) mechanism operating in ACK-on-Error mode. Originally specified in RFC 8724, SCHC ACK-on-Error mode allows a sender to divide an uncompressed or compressed IPv6/UDP/CoAP packet (a "SCHC Packet") into small blocks called tiles, group those tiles into windows of fixed size (`WINDOW_SIZE`), and transmit them over constrained Low-Power Wide-Area Network (LPWAN) links. When tile losses occur, the receiver provides feedback to the sender using SCHC ACK messages containing a bitmap of received tiles.

Under RFC 8724, each failure SCHC ACK message can report missing tiles for only a single window. If tile losses occur across multiple windows during the transmission of a fragmented packet, the receiver is forced to issue multiple separate failure SCHC ACK messages—one for each window with losses. In LPWAN networks characterized by severe downlink transmission constraints, duty-cycle limits, high latency, and asymmetric energy costs, transmitting multiple downlink ACK messages introduces significant overhead and delay.

RFC 9441 solves this problem by defining the **SCHC Compound ACK**. The SCHC Compound ACK is an extended failure ACK message format that accumulates loss bitmaps from multiple non-contiguous windows into a single, variable-length layer-2 message. The message structure orders windows from lowest to highest numerical index ($w_1 < w_2 < \dots < w_i$). The lowest window number ($w_1$) is placed in the standard SCHC ACK Header, while subsequent window numbers and their corresponding bitmaps are concatenated in sequence. Termination of the Compound ACK is signaled either by appending $M$ zero bits (which cannot be confused with window 0, as window 0 is always placed in the header as $w_1$) or by reaching the layer-2 MTU boundary.

RFC 9441 also introduces an optional bitmap compression optimization for the final window reported in a Compound ACK message. If the profile permits and the last bitmap ends on a layer-2 Word boundary, trailing bits of the final window's bitmap can be omitted, further reducing message length. Intermediate bitmaps within a Compound ACK must remain uncompressed and of full `WINDOW_SIZE` length to ensure unambiguous parsing.

From a protocol behavior perspective, RFC 9441 replaces Section 8.4.3 of RFC 8724 in its entirety. It updates the state machine and procedural rules for both the **Fragment Sender** and the **Fragment Receiver**. The Fragment Sender fragments the packet, maintains an Attempts counter and a Retransmission Timer per active `(RuleID, DTag)` pair, listens for Compound ACKs after transmitting All-1 fragments or SCHC ACK Requests, and retransmits missing tiles across all reported windows upon receiving a Compound ACK. The Fragment Receiver tracks incoming tiles, maintains an Attempts counter and an Inactivity Timer per active `(RuleID, DTag)` pair, performs integrity verification using the Reassembly Check Sequence (RCS), and generates Compound ACKs when requested or upon receiving All-0 fragments under favorable network and delay conditions.

To support management and provisioning of this feature, RFC 9441 defines a YANG 1.1 data model (`ietf-schc-compound-ack`) that augments the base SCHC YANG module specified in RFC 9363. The module adds two configuration leaves to the `ack-on-error` fragmentation node: `bitmap-format` (an identityref selecting between standard `bitmap-RFC8724` and `bitmap-compound-ack`) and `last-bitmap-compression` (a boolean controlling final bitmap compression). Finally, RFC 9441 updates the list of technology profile parameters defined in Appendix D of RFC 8724, requiring technology-specific SCHC profiles (such as LoRaWAN, Sigfox, or NB-IoT) to explicitly declare whether Compound ACK and last-bitmap compression are enabled.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC Compound ACK Message | Multi-window failure ACK frame carrying window numbers and bitmaps. | Datagram (SCHC F/R Message Datagram) | Direct | Aligned (Datagram exchanged between Instances in a Session) | Aligned (1 Datagram conveys feedback for 1..N windows) | None | Explicitly referenced in SCHC Architecture -06 Section 4.2.2.2. |
| ACK-on-Error Mode | Window-based reliability mode for SCHC F/R. | F/R SCHC Function (executed by SCHC Instance) | Direct | Aligned (Function executed within Instance for a Session) | Aligned (Executed by sender and receiver Instances per Session) | None | Core F/R mode specified in RFC 8724 and integrated in -06. |
| Fragment Sender | Entity that fragments packets, manages retransmissions, processes ACKs. | SCHC Instance Role (Sender / Upside role executing F/R) | Direct | Aligned (Instance role executing within Endpoint) | Aligned (1 Sender role per Session end) | None | Defined in Instance Configuration / Context. |
| Fragment Receiver | Entity that reassembles tiles, verifies RCS, generates Compound ACKs. | SCHC Instance Role (Receiver / Downside role executing F/R) | Direct | Aligned (Instance role executing within Endpoint) | Aligned (1 Receiver role per Session end) | None | Defined in Instance Configuration / Context. |
| RuleID & DTag Pair | Identifier pair indexing active fragmented packet transmission. | Rule (via RuleID) in Context + Session State Key in SoV | Composite | Aligned (RuleID has Context/SoR scope; DTag has Session SoV scope) | Aligned (RuleID 1:N Sessions; DTag unique per active packet in Session) | None | RuleID selects F/R Rule in SoR; RuleID+DTag indexes active session state in SoV. |
| Window & Bitmap / Compressed Bitmap | Format elements for tile loss reporting in Compound ACK. | F/R Datagram Payload / Profile Wire Format | Profile-specific | Aligned (Wire format within Datagram) | Aligned (Fields inside Datagram payload) | None | Wire format defined by SCHC profile / specification. |
| Sender Attempts Counter & Retransmission Timer | Retransmission control state for ACK requests and tile retransmissions. | Set of Variables (SoV) | Direct | Aligned (Runtime per-session state in SoV) | Aligned (1 set per active (RuleID, DTag) session key in SoV) | None | Maintained in Session SoV during active F/R operation. |
| Receiver Attempts Counter & Inactivity Timer | Timeout control state for reassembly and ACK generation. | Set of Variables (SoV) | Direct | Aligned (Runtime per-session state in SoV) | Aligned (1 set per active (RuleID, DTag) session key in SoV) | None | Maintained in Session SoV during active F/R operation. |
| Profile Parameters | F/R configuration parameters (tile size, M, N, Compound ACK usage, etc.). | Instance Configuration & Context (SoR Rules) | Direct | Aligned (Provisioned in Instance Config / Context) | Aligned (Configured per Instance / RuleID in Context) | None | Stored in Context / Instance Configuration. |
| YANG Data Model Extension (`ietf-schc-compound-ack`) | Data model extending RFC 9363 for Compound ACK configuration. | SCHC Data Model (stored in Context Repository / managed by Domain Manager) | Direct | Aligned (Administrative domain / management scope) | Aligned (Augments SCHC Data Model in Context Repository) | None | Managed by Domain Manager and Instance Manager. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Context (SoR) shared between sender and receiver nodes. | Context shared between Instances in a Domain. | Aligned | Fully compatible; Context defines the F/R Rule and parameters used by Instances. |
| Ownership of Set of Rules (SoR) | Collection of C/D and F/R rules defined in profile / context. | Part of Context, shared across Instances in a Domain. | Aligned | Compound ACK usage and bitmap format leaves are part of the F/R Rule definition in SoR. |
| Ownership of Set of Variables (SoV) | Per-(RuleID, DTag) counters and timers maintained at sender and receiver. | Runtime parameters and session variables (SoV) maintained per Session. | Aligned | Attempts counters, Retransmission Timer, and Inactivity Timer reside in the Session's SoV. |
| Endpoint ↔ SCHC Instance | Unstated (assumed 1 SCHC stack per physical device / gateway). | Endpoint host entity can run 1 or multiple SCHC Instances. | Aligned (Superset in -06) | RFC 9441 applies directly to an Instance executing F/R within an Endpoint. |
| SCHC Instance ↔ Session | Point-to-point communication between sender and receiver. | Instance participates in 1 or multiple Sessions within a Domain. | Aligned | An Instance can run Compound ACK F/R across multiple simultaneous Sessions. |
| Context sharing between Sessions | Rules pre-provisioned on sender and receiver. | Context shared across multiple Instances / Sessions in a Domain. | Aligned | Multiple Sessions can share the same F/R Context containing Compound ACK rules. |
| RuleID scope | Selects F/R rule and parameters on sender and receiver. | Unique within the Context / Set of Rules (SoR). | Aligned | RuleID scope is identical. |
| DTag scope | Disambiguates concurrent fragmented packets for a RuleID. | Unique per active fragmented Datagram within a Session's SoV. | Aligned | DTag scope maps directly to Session SoV keying. |
| Control Header scope | Not used in baseline RFC 9441 Compound ACK. | Optional framing header for instance/session multiplexing or metadata. | Not applicable | Compound ACK is a native SCHC F/R Datagram starting with RuleID; no Control Header required. |
| Domain membership and boundaries | Implicit LPWAN network domain (Device and NGW/App Server). | Logical grouping of Instances sharing Contexts, managed by Domain Manager. | Aligned | YANG data model extension enables Domain Manager to manage Compound ACK rules. |

## Challenged mappings

No mapping classification changed during the adversarial pass.

## Architectural risk points

- **Risk:** Session-level state isolation for concurrent fragmented packets under shared Contexts.
  - **Why it matters:** In SCHC Architecture -06, a single SCHC Instance or shared Context may participate in multiple simultaneous Sessions (e.g., a gateway Instance communicating with multiple device Instances). If multiple Sessions use the same F/R RuleID, the `(RuleID, DTag)` pair must be scoped to the specific Session in the Set of Variables (SoV).
  - **Consequence for migration:** When reframing RFC 9441's state machine text, state variables (Attempts counter, Retransmission Timer, Inactivity Timer) must be explicitly identified as belonging to the Session's Set of Variables (SoV), keyed by `(RuleID, DTag)` per Session.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1 (Introduction) | "The Generic Framework for Static Context Header Compression (SCHC) and Fragmentation specification [RFC8724] describes two mechanisms..." | Update introduction to frame SCHC operations as taking place between SCHC Instances hosted on Endpoints within a Domain, exchanging SCHC Datagrams over a Session as specified in `draft-ietf-schc-architecture-06`. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns RFC 9441 introductory framing with the SCHC Architecture -06 component model. |
| 2 | Section 3 (SCHC Compound ACK) | "The SCHC Compound ACK is a failure SCHC ACK message..." | Clarify that the SCHC Compound ACK is a SCHC F/R Datagram format generated by a reassembling SCHC Instance role and processed by a fragmenting SCHC Instance role. | REQUIRED FOR TERMINOLOGY MIGRATION | Adopts -06 terminology for Datagrams and Instance roles. |
| 3 | Section 3.2.1 (ACK-on-Error Mode) | "For each active pair of RuleID and DTag values, the sender MUST maintain... For each active pair of RuleID and DTag values, the receiver MUST maintain..." | Explicitly state that the Attempts counter, Retransmission Timer, and Inactivity Timer are session-level runtime variables stored in the Session's Set of Variables (SoV) maintained by the respective SCHC Instance. | REQUIRED FOR TERMINOLOGY MIGRATION | Maps per-packet F/R state variables directly to the -06 Set of Variables (SoV) concept. |
| 4 | Section 3.2.1.1 & 3.2.1.2 (Sender / Receiver Behavior) | "fragment sender", "fragment receiver" | Update references to "fragmenting SCHC Instance (or sender Instance)" and "reassembling SCHC Instance (or receiver Instance)" executing the F/R SCHC Function. | REQUIRED FOR TERMINOLOGY MIGRATION | Replaces informal role titles with -06 SCHC Instance role terminology. |
| 5 | Section 5 (YANG Data Model) | "This document also extends the SCHC YANG data model defined in [RFC9363]..." | Add an informative note referencing SCHC Architecture -06, noting that the YANG data model represents the Context schema stored in the Context Repository and managed by the Domain Manager / Instance Manager. | OPTIONAL CLARIFICATION | Clarifies how the YANG data model extension integrates into the -06 management architecture. |
| 6 | Section 6 (Parameters) | "This section lists the parameters related to the SCHC Compound ACK usage that need to be defined in the Profile." | Clarify that profile parameters populate the Instance Configuration and/or Context (Set of Rules) provisioned on the SCHC Instances. | OPTIONAL CLARIFICATION | Connects profile parameter definitions to Instance Configuration and Context provisioning in -06. |

## Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? Reframing RFC 8724 sender/receiver roles and per-packet state (Attempts counter, timers) as SCHC Instances executing the F/R SCHC Function within a Session and maintaining state in the Set of Variables (SoV).
