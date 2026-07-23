# Architectural alignment review: draft-westerlund-schc-compute-address-00

## Verdicts
- Conceptual equivalence: High
- Transition difficulty: Medium
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | The draft's model requires explicit interpretation and decomposition of its device-specific "context" into -06's shared Context (SoR) and instance-specific state (SoV/Instance Config), and the C/D engine's use of dynamic state requires interpretation. | The core technical mechanisms (index-based table compression and PRF-based temporary address generation) map naturally to custom MOs and CDAs, which are standard extension points of SCHC. |
| Transition difficulty | Medium | The draft's overloaded use of "context" makes a mechanical search-and-replace impossible, requiring manual architectural judgment across multiple sections to map terms to Context, Instance Config, and SoV. | The underlying protocol behavior, message formats, and algorithms are completely stable and do not require redesign or restructuring. |
| SCHC Architecture adaptation need | Trivial | It is not None because SCHC Architecture -06 currently lacks an explicit statement that the C/D engine can access dynamic runtime variables (SoV), requiring a minor additive clarification. | It is not Medium because no existing definitions or architectural statements in -06 need to be modified or reworded to shift their meaning; the gap is closed through a purely additive clarification. |

## Executive assessment
This review assesses `draft-westerlund-schc-compute-address-00` against `draft-ietf-schc-architecture-06`. SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping involves treating the draft's Address Tables as part of the Set of Variables (SoV), its secret key as part of the Instance Configuration, and its device and network compressor/decompressor as Endpoints hosting client/server SCHC Instances. The principal migration difficulty is that the draft extensively overloads the term 'context' (e.g., using it for the static rules, device-specific address tables, and device identity), which requires careful, manual architectural interpretation to rewrite. An Architecture gap exists because -06 does not explicitly state that the C/D engine can access dynamic runtime variables in the SoV. This gap is Trivial and can be closed with an additive clarification in -06.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Device (UE) | The mobile device or client node undergoing SCHC compression/decompression. | Client-side equipment. | Physical/logical node. | Device identity. | 1 Device hosts the client compressor/decompressor and communicates with 1 or more gateways. | Main primary actor. |
| SCHC Network Compressor/Decompressor | The network-side entity performing SCHC compression/decompression on behalf of the device. | Network-side gateway, base station, or UPF. | Network-side logical node. | Network node identity. | Can handle multiple devices (UEs) simultaneously. | Network-side peer. |
| Address Table | A deterministically sorted list of assigned IPv4 addresses, IPv6 prefixes, or IPv6 Interface Identifiers (IIDs). | Maintained per-context, shared between compressor and decompressor. | Context-local (device-local). | Category and index. | 1 Context can have up to 3 tables (one per category: IPv4, IPv6 Prefix, IPv6 IID). Multiple Rules can reference the same table. | Rebuilt when the underlying address set changes. |
| Address Category | Classification of address information (IPv4 address, IPv6 prefix, IPv6 IID). | Rule configuration. | Context-local. | Category name (e.g., IPv4, prefix, IID). | Each Address Table belongs to one category. | None. |
| Address Index | Position of an entry in a sorted Address Table. | Carried in packet. | Packet-local. | The index value (residual). | 1 index corresponds to 1 address in a given category's table. | Sent as a residual of N bits. |
| secret_key | Device-specific secret key of >=128 bits. | Device and network-side compressor/decompressor. | Device-local / context-local. | None. | 1 key per device. | Used as input to the PRF for temporary IID generation. |
| Net_Iface | Network interface identifier. | Device interface. | Device-local. | None. | 1 per interface. | Used in the PRF. |
| Network_ID | Network attachment point identifier. | Local network attachment point. | Link/subnet-local. | None. | 1 per subnet/link. | Used in the PRF. |
| Time Parameters | Configuration parameters (Time_Offset, Interval_Length, Max_Lifetime). | Rule configuration. | Rule-local. | None. | 1 set of parameters per temporary IID rule. | None. |
| Epoch | Time interval counter identifying the generation period of a temporary IID. | Derived from current wall clock time. | Time-interval local. | Epoch value (N bits in residual). | 1 epoch corresponds to a specific start time (Tis). | Transmitted in the residual. |
| DAD Counter | Counter to resolve Duplicate Address Detection collisions. | IID generator. | Address generation local. | DAD value (M bits in residual). | Increments per collision. | Transmitted in the residual. |
| comp-addr-v4 / comp-addr-prefix / comp-addr-iid / comp-temp-iid | Matching Operators (MOs) and Compression/Decompression Actions (CDAs) for dynamic address compression. | Rule definitions. | Rule-local. | MO/CDA name. | Associated with specific header fields in the Rule Field Descriptors. | Defined as extensions to RFC 8724. |
| Address Table Cache / IID Cache | Local cache to avoid rebuilding tables or re-running the PRF on every packet. | Local implementation. | Local to the compressor/decompressor. | None. | Internal implementation optimization. | None. |

## Native architectural model
The draft `draft-westerlund-schc-compute-address-00` addresses the problem of using Static Context Header Compression (SCHC) in network environments where IP addresses are dynamically assigned (e.g., via DHCP, SLAAC, or DHCPv6-PD) or change periodically for privacy (RFC 8981 temporary addresses). Because standard SCHC requires addresses to be static target values in the Rules or derived from static Layer 2 addresses (which are absent in 3GPP mobile networks), the draft proposes a dynamic address tracking and synchronized address derivation framework.

The primary architectural components are the Device (or User Equipment, UE) and the SCHC Network Compressor/Decompressor. These two entities share a common set of Rules ("context") and must also maintain synchronized knowledge of the set of IP addresses currently assigned to the device's network interfaces. The exact provisioning mechanism to update the network-side compressor with the device's addresses is out of scope and deployment-specific (e.g., SMF signaling in 5G, or DHCP monitoring).

To compress dynamically assigned addresses without updating static Rules, the draft introduces Address Tables. Addresses are classified into three Address Categories: IPv4 Address, IPv6 Prefix, and IPv6 IID. For each category, the assigned addresses are filtered (excluding loopback, multicast, and optionally link-local addresses), deduplicated, and sorted in ascending binary order. This deterministic sorting ensures that both the compressor and decompressor construct identical tables with identical zero-based index mappings.

During compression, the matching operator (MO) checks if a packet's address field matches an entry in the corresponding Address Table. If a match is found and its index fits within the configured residual bits, the compression/decompression action (CDA) replaces the address field with the Address Index as a residual. The decompressor uses the index to retrieve the address from its local copy of the Address Table and reconstructs the packet header. Both sides must rebuild their tables when the underlying address set changes.

For temporary IPv6 addresses (RFC 8981), where sending the 64-bit randomized IID in the residual would negate compression benefits, the draft defines a synchronized generation algorithm (`comp-temp-iid`). Instead of tables, this mechanism relies on shared state parameters, including a device-unique `secret_key`, a network interface identifier (`Net_Iface`), and a network identifier (`Network_ID`). The compressor and decompressor run a Pseudorandom Function (PRF) matching the device's algorithm.

The PRF runs periodically at intervals defined by `Interval_Length` and `Time_Offset`. Wall clock time is synchronized between the device and network compressor, allowing both to derive the current `Epoch` counter. The compression residual carries the least significant N bits of the Epoch and an M-bit `DAD_Counter` (used to resolve Duplicate Address Detection collisions). The decompressor uses these parameters, along with the shared secret key and the known IPv6 prefix, to compute the identical randomized IID.

To minimize processing overhead, implementations maintain local caches for the constructed Address Tables and the generated temporary IIDs. The network decompressor also populates its cache by observing incoming uplink packets and storing successfully matched temporary IIDs with their corresponding epoch and DAD counter metadata.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Device (UE) | Client node undergoing compression. | Endpoint (hosting client Instance). | Direct | Aligned. | Aligned. | None. | Maps to the client-side entity. |
| SCHC Network Compressor/Decompressor | Network-side peer. | Endpoint (hosting network Instance). | Direct | Aligned. | Aligned. | None. | Maps to the network gateway/base station. |
| Address Table | Table of assigned addresses/prefixes. | Set of Variables (SoV). | Partial | Partially aligned. | Aligned. | In -06, C/D operations are traditionally static. Mapping this to SoV implies the C/D engine accesses dynamic session variables, which is currently implicit/unspecified in -06. | Represents dynamic session state that must be synchronized between Instances. |
| Address Category | Classification of address information. | Rule / Context metadata. | Direct | Aligned. | Aligned. | None. | Part of the Rule Field Descriptor configuration. |
| Address Index | Table position index. | Compression Residual (Datagram field). | Direct | Aligned. | Aligned. | None. | Carried in the compressed SCHC Datagram. |
| secret_key | Device-specific cryptographic key. | Instance Configuration or Set of Variables (SoV). | Composite | Aligned. | Aligned. | Storing this key in the Context would make the Context device-unique, preventing Context sharing across a Domain. It must reside in Instance Config or SoV. | Unique per device Instance. |
| Net_Iface / Network_ID | Environmental interface/link IDs. | Set of Variables (SoV) or Instance Configuration. | Composite | Aligned. | Aligned. | These are runtime parameters of the Instance. | Part of the local Instance state. |
| Time Parameters | Parameters for temporary IID generation. | Rule (Context). | Direct | Aligned. | Aligned. | None. | Part of the Rule Field Descriptor definition. |
| Epoch / DAD Counter | Time/collision counters for temporary IIDs. | Compression Residual (Datagram fields). | Direct | Aligned. | Aligned. | None. | Carried in the compressed SCHC Datagram. |
| comp-addr-v4 / comp-addr-prefix / comp-addr-iid / comp-temp-iid | Custom MOs and CDAs. | Matching Operators (MOs) and CDAs. | Direct | Aligned. | Aligned. | None. | Standard extension points of the SCHC framework. |
| Address Table Cache / IID Cache | Local optimization caches. | Set of Variables (SoV). | Direct | Aligned. | Aligned. | None. | Local state within the Instance's runtime. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Context represents the static Set of Rules associated with the device. | Context is a Set of Rules and metadata shared by two or more Instances. | Aligned | The draft's static rule set maps to the shared Context. |
| Ownership of Set of Rules (SoR) | Static set of rules defining matching/compression (e.g. Table 1). | SoR is part of the Context, shared between Instances. | Aligned | None. |
| Ownership of Set of Variables (SoV) | Address Tables and temporary IID state are maintained per-context (device). | SoV contains runtime parameters and session variables, maintained per-session. | Aligned | Since a multi-session device has separate Instances/Sessions, its Address Tables map to per-session SoVs. |
| Endpoint↔SCHC Instance | A single Device can have multiple PDU sessions (different addresses/rules). | 1 Endpoint can host multiple Instances, each with its own Context and Config. | Aligned | A multi-session Device is represented as one Endpoint with multiple Instances (one per PDU session). |
| SCHC Instance↔Session | A PDU session is a communication relationship between UE and Gateway. | A Session is a communication session between two or more Instances. | Aligned | A Session exists between the Device Instance and the Gateway Instance. |
| Sharing of Context between Sessions/Instances | Multiple Rules within the same context reference the same Address Table. | Context is shared across Instances/Sessions. | Aligned | The same Set of Rules can be shared, while their specific Address Tables are instance-local (part of SoV). |
| RuleID scope | Carried in the packet to select processing rules. | Unique within a Context. | Aligned | None. |
| Discriminator scope | UE/session identified using out-of-band parameters (e.g. PDU session ID). | Discriminator used by Dispatcher to route Datagrams to correct Instance. | Aligned | The PDU session ID or network tunnel ID serves as the Discriminator. |
| Control Header processing scope | Not explicitly discussed. | Optional header before/after RuleID carrying session/routing info. | Not applicable | None. |
| Domain membership and boundaries | UE and Network Gateway belong to the same network deployment. | Domain is a logical grouping of Instances sharing a set of Contexts. | Aligned | The UE and gateway Instances belong to the same Domain. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| secret_key | Context | If the secret key is stored in the Context, the Context cannot be shared across multiple devices in a Domain, violating the SCHC -06 model where Contexts (SoRs) are shared/reusable. | **Instance Configuration** or **Set of Variables (SoV)** | To preserve Context reusability, device-unique parameters like keys must be isolated to the Instance Configuration or SoV, while the Context contains the shared Set of Rules and generic metadata. |
| Address Table | Context | The draft states that the Address Table is "maintained per-context". However, in -06, Contexts are static. Since Address Tables change dynamically at runtime as addresses are assigned/expired, placing them in the Context would make the Context dynamic. | **Set of Variables (SoV)** or local **Instance** state | Address Tables represent dynamic, session-specific runtime state, which maps to the Set of Variables (SoV) rather than the static Context. |

## Architectural risk points
- **Risk:** Address Table desynchronization and packets-in-flight.
  - **Why it matters:** The draft does not define a mechanism to synchronize Address Table updates or handle out-of-order/in-flight packets during table rebuilds. When the address set changes, sorting changes, which shifts indices. A packet compressed with the old index but received after a table rebuild will be decompressed using the new index, leading to packet corruption (misdelivery or discard).
  - **Consequence for migration:** Implementations must introduce versioning, grace periods, or out-of-band coordination for Address Tables to prevent transient packet corruption.
- **Risk:** Stateful Compression/Decompression.
  - **Why it matters:** Standard SCHC C/D is stateless and depends only on the static Context. The draft introduces a dependency on dynamic runtime state (Address Tables) in the C/D engine. This complicates the C/D engine architecture, as it must now interact with dynamic session variables (SoV) and handle table invalidation/rebuilding.
  - **Consequence for migration:** Implementations must support stateful C/D engines that interface with the Set of Variables (SoV).
- **Risk:** Clock Synchronization for Temporary IID.
  - **Why it matters:** The `comp-temp-iid` CDA relies on synchronized wall clocks between the compressor and decompressor to derive the correct epoch and Tis. If clocks drift beyond the configured `Interval_Length` tolerance, the decompressor will generate a different IID than the one used by the device, causing decompression failure.
  - **Consequence for migration:** A clock synchronization mechanism (e.g., NTP or 3GPP network time sync) is a hard prerequisite, and the system must handle drift detection and recovery.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4, Paragraph 2 & Section 2 Terminology | "The Address Table is maintained per-context and shared between compressor and decompressor." | Clarify that the Address Table is maintained as part of the Instance's Set of Variables (SoV) rather than the shared static Context (SoR). | REQUIRED FOR CONCEPTUAL ALIGNMENT | To align with SCHC Architecture -06, where Contexts are static and reusable, and dynamic runtime parameters are stored in the Set of Variables (SoV). |
| 2 | Section 7.2, Paragraph 1 | "...or MAY be provisioned as part of the SCHC context setup." (regarding secret_key) | Specify that the secret_key is provisioned as part of the Instance Configuration or SoV, rather than the shared Context. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Storing a device-unique cryptographic key in the Context prevents the Context from being shared across multiple devices in a Domain. |
| 3 | Section 1 & Section 4 | General references to "compressor and decompressor" or "endpoints". | Update the terminology to refer to "SCHC Endpoints" hosting "SCHC Instances" participating in a "SCHC Session". | REQUIRED FOR TERMINOLOGY MIGRATION | To use the standardized architectural terminology of SCHC Architecture -06. |
| 4 | Section 9.2 & Section 4 | General description of device identity and session mapping without architectural terms. | Frame the network-side routing and session mapping in terms of the "Dispatcher" routing packets to the correct "Instance" using a "Discriminator" (e.g. PDU session ID). | REQUIRED FOR TERMINOLOGY MIGRATION | To align the provisioning and routing models with the Dispatcher/Discriminator architecture in -06. |
| 5 | Section 8, Paragraph 3 | "Detailed mechanisms for synchronizing table updates... are outside the scope of this document..." | Add an informative note suggesting that a table version identifier or brief grace period (maintaining old and new tables) could be used to mitigate the risk of packets in flight. | OPTIONAL CLARIFICATION | Provides guidance for implementers to handle the packet corruption risk during table transitions. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 (Terminology) or Section 4.2.2.1 (C/D) | Set of Variables (SoV) / C/D engine | "Set of Variables (SoV): Runtime parameters and session variables, such as fragmentation-related timers, retransmission counters, state flags, and other per-session values that may change during operation." | Add a statement: "The C/D engine may also utilize dynamic runtime parameters from the Set of Variables (SoV) or local Instance state (e.g. dynamically assigned IP addresses or cryptographic keys) to execute specific Matching Operators or Compression/Decompression Actions." | ARCHITECTURE GAP | SCHC Architecture -06 currently assumes C/D operations are based solely on static Context. Enabling MOs and CDAs to access dynamic variables (like Address Tables in the SoV) requires an explicit statement allowing C/D to use the SoV. |
| 2 | Section 4.2.1.2 (Context) | Static Context assumption | "SCHC as defined in [RFC8724] assumes that the Context is static and provisioned before use..." | Add a note clarifying that: "While the Context itself is static, custom Matching Operators and CDAs can reference dynamic session variables (SoV) that are updated at runtime, without requiring context re-provisioning." | OPTIONAL CLARIFICATION | Clarifies how the static Context model coexists with dynamic address compression mechanisms. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **No**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft**
- What is the single most important migration issue? **The overloaded use of the word "context" in the draft under study, which must be carefully separated into the static Context (SoR) and the dynamic Set of Variables (SoV) or Instance Configuration to preserve Context sharing and reusability.**
