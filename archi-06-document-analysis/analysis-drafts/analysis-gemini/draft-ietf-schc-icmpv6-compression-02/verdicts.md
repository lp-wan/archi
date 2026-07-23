# Architectural alignment review: draft-ietf-schc-icmpv6-compression-02

## Verdicts
- Conceptual equivalence: **Very High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **Very High** | *Highest grade* | All key concepts of the draft—such as ICMPv6 field parsing, error handling surrogate behavior at the Core, and payload compression via direction reversal—can be naturally and directly mapped onto the core concepts of SCHC Architecture -06 (Endpoints, Instances, Sessions, Contexts, Rules, and error/routing policies) without any conceptual distortions or reinterpretation. |
| **Transition difficulty** | **Easy** | To achieve a "Very Easy" grade, the draft's terminology would have to align perfectly with -06 out-of-the-box (e.g., using "Endpoint" instead of "End-Point", "Session" instead of "SCHC instance", and "Datagram" instead of "SCHC message"). Minor textual adjustments and editorial rewrites are needed to rephrase "direction of the End-Point" into "direction of the Session" to avoid architectural confusion, though the technical intent remains completely stable. | The changes do not alter the protocol behavior, packet structure, rule engine logic, or YANG schema. The required edits are simple, localized, and mechanical-to-easy, and can be represented in a unified diff format. |
| **SCHC Architecture adaptation need** | **None** | *Highest grade* | All concepts required to express the draft (e.g., Endpoints, Instances, Sessions, Contexts, Rules, and extension mechanisms for MOs/CDAs) are already present and fully defined in SCHC Architecture -06. No gaps in the architecture are exposed. |

## Executive assessment
The Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express `draft-ietf-schc-icmpv6-compression-02` in its entirety. The principal conceptual mapping is direct: the "SCHC Core" maps to the network-side Endpoint/Instance, the "SCHC Device" maps to the device-side Endpoint/Instance, and the "SCHC instance" channel maps to a SCHC Session. The draft's payload compression mechanism (using `mo-rev-rule-match` and `cda-rev-compress-sent` to compress the inner IPv6 packet payload in the reverse direction) is a natural use of the extensibility of Matching Operators and Compression Decompression Actions defined in [RFC8724] and supported by -06. The principal migration difficulty is purely editorial terminology alignment (converting "End-Point" to "Endpoint", "SCHC instance" to "Session", "SCHC message" to "Datagram", and rephrasing "direction of the End-Point" to "direction of the Session"). No architecture gap exists in SCHC Architecture -06; all its concepts are fully sufficient for this draft.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **SCHC Core** | Endpoint at the boundary of the regular IP network and the compressed network. | Network edge gateway. | Network-local / Link-local boundary. | Gateway IPv6 address. | 1 per SCHC instance; can manage multiple Devices (1:N). | Intercepts packets, generates surrogate ICMPv6 messages, and decompresses/re-compresses ICMPv6 payloads. |
| **SCHC Device** | The end-device on the constrained LPWAN network. | Device node. | Node-local / Device-local. | Device identity (e.g., MAC, DevEUI, IPv6 address). | 1 per SCHC instance (1:1 with Core for a given instance). | Typically a constrained IoT device. |
| **Application** | Entity on the regular Internet sending/receiving packets. | Internet host / server. | Global / Internet-wide. | IPv6 Address / UDP Port. | 1:N with Devices (multiple devices can talk to the same Application). | Unaware of SCHC compression. |
| **SCHC instance** | The logical communication channel established between the Device and Core. | Shared. | Link-local / Peer-to-peer. | Implied by device identity/session context. | 1:1 relationship between a Device and the Core. | Used to refer to the communication link. |
| **ICMPv6 Fields** | Headers and payload fields of ICMPv6 (Type, Code, Checksum, MTU, Pointer, Identifier, Sequence, Payload). | Packet-local. | Packet-local. | Field Identifiers (Field IDs). | N:1 per Rule. | Augmented in the YANG data model. |
| **mo-rule-match / mo-rev-rule-match** | Matching Operators that perform rule-matching on a nested packet within the payload. | Executed by C/D engine. | Rule-local / field-specific. | Field descriptor property. | N:1 per Rule. | `mo-rev-rule-match` reverses the matching direction (UP becomes DOWN, DOWN becomes UP). |
| **cda-compress-sent / cda-rev-compress-sent** | Compression Decompression Actions that compress a nested packet. | Executed by C/D engine. | Rule-local / field-specific. | Field descriptor property. | N:1 per Rule. | Writes RuleID + residue of the inner packet into the outer payload's residue. |
| **Surrogate proxy behavior** | The Core intercepts incorrect packets and generates ICMPv6 errors on behalf of the Device. | SCHC Core. | Core-local routing. | Triggered when no rule matches or port is unreachable. | 1:1 per intercepted packet. | Saves LPWAN bandwidth. |
| **Offending packet Rule ID** | The RuleID of the rule used to compress the offending IPv6 packet inside the ICMPv6 error payload. | Payload residue. | Packet-local. | Carried inside the payload residue. | 1:1 per compressed ICMPv6 payload. | Used by the receiver to select the rule for payload decompression. |

## Native architectural model
The draft under study describes how to compress ICMPv6 protocol headers and payloads in a SCHC network. The network consists of a SCHC Device (typically a resource-constrained IoT node) and a SCHC Core (a gateway at the boundary between the LPWAN and the regular Internet).

The SCHC Device and the SCHC Core establish a SCHC instance, sharing a static context that contains rules for header compression. The regular Internet host or Application communicates with the SCHC Device through the SCHC Core. The Application is unaware of SCHC and sends standard uncompressed IPv6 packets.

The draft defines how standard ICMPv6 messages, such as Echo Requests and Replies (ping), as well as ICMPv6 error messages (Destination Unreachable, Packet Too Big, Time Exceeded, Parameter Problem), are compressed. Because different ICMPv6 messages have different fields, the draft recommends using separate rules for different message types.

For informational messages like ping, the draft specifies a sequence where the Device sends an Echo Request to an Application. To optimize compression, the Identifier is ignored (assumed to be 0) and the Sequence Number is compressed to its 3 or 8 least significant bits. This introduces a constraint: only a single ping can be active at a time for the Device.

For error messages, the draft identifies two main scenarios depending on whether the Device is the source or the destination of the error.

When an incoming packet from the Internet cannot be processed or matched by the SCHC Core, the draft introduces a surrogate or proxy behavior. Instead of sending the invalid packet over the constrained LPWAN link to the Device, the SCHC Core intercepts the packet and generates an ICMPv6 error message on behalf of the Device.

For the SCHC Core to act as a surrogate router and generate these ICMPv6 messages, it must have a routable IPv6 address. This proxying behavior saves valuable bandwidth on the LPWAN and protects the Device from processing unwanted or malformed packets.

When the Device is the destination of an ICMPv6 error message (e.g., because a packet it sent generated an error in the network), the ICMPv6 message must reach the Device. Under RFC 4443, ICMPv6 error messages contain the invoking (offending) packet in their payload.

To compress this payload, which is itself an IPv6 packet, the draft introduces two new Matching Operators (`mo-rule-match` and `mo-rev-rule-match`) and two new Compression Decompression Actions (`cda-compress-sent` and `cda-rev-compress-sent`).

The `mo-rev-rule-match` operator checks if the invoking packet matches any rule in the current Set of Rules, reversing the direction (UP becomes DOWN, DOWN becomes UP) because the offending packet was sent UP by the Device, while the ICMPv6 error is traveling DOWN to the Device.

If a match is found, `cda-rev-compress-sent` compresses the payload using that rule. The compressed payload is represented as a variable-length residue starting with the RuleID of the matching rule, followed by its compression residue. If no match is found, the payload is sent uncompressed or ends with the compressed Value field.

This nested compression allows the Device to receive the ICMPv6 error message with its payload compressed, which is decompressed by identifying the RuleID in the payload and applying the reverse decompression.

The configuration of fields, MOs, and CDAs is managed via a YANG module that augments the base SCHC YANG data model (RFC 9363) with ICMPv6 identities.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **SCHC Core** | Boundary endpoint executing SCHC compression. | **Endpoint** (specifically, the network-side Endpoint/Instance). | Direct | Aligned | Aligned | None (terminology style: "End-Point"). | Maps to network-side endpoint hosting the Instance. |
| **SCHC Device** | End-device executing SCHC compression. | **Endpoint** (specifically, the device-side Endpoint/Instance). | Direct | Aligned | Aligned | None. | Maps to device-side endpoint hosting the Instance. |
| **SCHC instance** | Communication channel between Device and Core. | **Session** | Direct | Aligned | Aligned | Draft uses "instance" for communication relationship; -06 uses "Session" for relationship and "Instance" for software component. | Wording must be updated in migration. |
| **ICMPv6 Fields** | Parsed fields of ICMPv6. | **Field Identifiers (Field IDs / FIDs)** | Direct | Aligned | Aligned | None. | Defined in Context via Data Model / YANG. |
| **mo-rule-match / mo-rev-rule-match** | Matching operators check if inner payload matches a rule. | **Matching Operator (MO)** | Profile-specific | Aligned | Aligned | Perform recursive execution against the Set of Rules. | Permitted by standard MO extensibility in [RFC8724]/[-06]. |
| **cda-compress-sent / cda-rev-compress-sent** | Actions to compress inner payload. | **Compression Decompression Action (CDA)** | Profile-specific | Aligned | Aligned | Perform recursive compression and write inner RuleID + residue to residue. | Permitted by standard CDA extensibility in [RFC8724]/[-06]. |
| **Surrogate proxy behavior** | Core generating ICMPv6 errors on behalf of the Device. | **Instance Configuration** (routing/interception criteria) and local **Error Handling** policy. | Profile-specific | Aligned | Aligned | Draft defines a specific ICMPv6 surrogate rule; -06 provides the general error policy hooks. | Permitted by -06 error policy and stack routing flexibility. |
| **SCHC message** | Compressed packet on the wire. | **Datagram** (or **SCHC Packet**) | Direct | Aligned | Aligned | Terminology difference ("SCHC message" vs "Datagram"). | Align wording to "Datagram" / "SCHC Packet". |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **ownership of Context** | Shared between SCHC Device and SCHC Core. | Shared between two or more Instances (Session), stored in Context Repository. | Aligned | None. |
| **ownership of Set of Rules (SoR)** | Defined statically for the SCHC instance. | Part of the Context shared between Instances. | Aligned | None. |
| **ownership of Set of Variables (SoV)** | Implicitly per-device / per-ping state. | Maintained per Session/Instance. | Aligned | None. |
| **Endpoint↔SCHC Instance** | "SCHC Core" is an "End-Point", "SCHC Device" is an "End-Point". | Endpoint hosts one or more Instances. | Aligned | Terminology in draft needs to be updated to "Endpoint hosting Instance". |
| **SCHC Instance↔Session** | "SCHC instance" is the communication channel. | Instance belongs to Endpoint; Session is the communication relationship between Instances. | Terminology collision | The draft's use of "instance" to refer to the communication channel must be migrated to "Session". |
| **sharing of Context between Sessions/Instances** | Assumes static Context between Device and Core. | Context can be shared across multiple Sessions/Instances in a Domain. | Aligned | None. |
| **RuleID scope** | Selects a rule within the static context. | Unique within a Context (or Set of Rules) associated with an Instance. | Aligned | None. |
| **Discriminator scope** | Implicitly handled by lower layer or device ID. | Optional element used by Dispatcher to route Datagrams to Instances. | Aligned | None. |
| **Control Header processing scope** | *Not applicable* (not used). | Optional element before/after RuleID for routing/protection. | Aligned | None. |
| **Domain membership and boundaries** | *Not applicable* (not explicitly discussed). | Grouping of Instances sharing Contexts. | Aligned | None. |

## Challenged mappings
No mapping classification changed during the adversarial pass.

## Architectural risk points
- **Risk: Terminology collision on "Instance" vs "SCHC instance"**
  - **Why it matters:** In -06, "Instance" is a logical component running on an Endpoint. In the draft, "SCHC instance" is used to refer to the peer-to-peer relationship (which -06 calls a "Session"). This collision could lead to confusion for developers implementing both specifications.
  - **Consequence for migration:** Wording in the draft must be adjusted to use "Session" when referring to the communication link and "Instance" when referring to the processing entity.
- **Risk: Endpoint Directionality Overloading**
  - **Why it matters:** In Sections 7.1 and 7.2, the draft refers to the "direction of the End-Point" (e.g., "in the same direction of the End-Point"). Under the SCHC Architecture, Endpoints are logical nodes and do not have a "direction". Direction (UP/DOWN) is a property of the transmission path or session roles.
  - **Consequence for migration:** The text must be rephrased to refer to "the direction of transmission within the Session" or "the direction of the Session" to remain architecturally coherent.
- **Risk: Implicit 1:1 Ping Assumption**
  - **Why it matters:** The draft states that ignoring the Identifier and setting it to 0 "implies that only one single ping can be launched at any given time on a device." While this is a profile constraint, it assumes a simple single-application/single-instance scenario. In a multi-instance or multi-session endpoint, multiple applications could try to ping.
  - **Consequence for migration:** Clarification is needed that this constraint applies per Session or per Instance, not necessarily globally to the physical device.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 5.1 & Section 3 | "...implies that only one single ping can be launched at any given time on a device." | "...implies that only one single ping can be active at any given time per SCHC Session." | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | A physical device may host multiple SCHC Instances or Sessions. The ping constraint is a consequence of the Session's Context (where the Identifier is elided to 0), not the physical device as a whole. |
| 2 | Section 1, 2, 6, 7, 7.1, 7.2, 8 | "SCHC End-Point", "End-Point", "end point", "End-Points" | "SCHC Endpoint", "Endpoint", "Endpoints" | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align terminology spelling with SCHC Architecture -06 which uses "Endpoint" (no hyphen). |
| 3 | Section 2 | "* SCHC Device: The other end of the SCHC instance formed with the SCHC core." | "* SCHC Device: The other Endpoint in the SCHC Session established with the SCHC Core." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with SCHC Architecture -06 which uses "Session" for the peer-to-peer relationship and "Endpoint" for the nodes. |
| 4 | Section 7, 7.1, 7.2 | "...direction of the End-Point", "...direction of the end point..." | "...direction of transmission within the Session", "...direction of the Session..." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Endpoints do not have a direction in SCHC Architecture -06; direction is a property of the Session's transmission path. |
| 5 | Section 7.1 | "...current Set of Rule..." | "...current Set of Rules..." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with the standard term "Set of Rules (SoR)" (plural) as defined in -06. |
| 6 | Section 8 | "...included in the SCHC message as a variable length residue." | "...included in the SCHC Datagram as a variable length residue." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align terminology with SCHC Architecture -06 which uses the term "Datagram" or "SCHC Packet" instead of "SCHC message". |
| 7 | Section 8 & Section 9 (YANG) | "Macthing Operator", "Macthing operator" | "Matching Operator", "Matching operator" | **EDITORIAL** | Fix typographical error. |
| 8 | Section 7.3 (Line 657-658) | "...An unsued field MUST not appear in the compressoin rules." | "...An unused field MUST NOT appear in the compression rules." | **EDITORIAL** | Fix typographical errors ("unsued" -> "unused", "compressoin" -> "compression") and capitalize normative keyword "MUST NOT". |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- **Can the draft be migrated without changing technical behavior?** Yes
- **Can the migration be performed mechanically?** Mostly
- **Does the draft expose a SCHC Architecture -06 gap?** No
- **Is the gap required for this draft or merely useful generally?** Not applicable (no gap exists)
- **What is the single most important migration issue?** Terminology alignment around "Endpoint" (unhyphenated), "Session" (replacing "SCHC instance" for communication channels), and "direction of the Session" (replacing "direction of the End-Point").
