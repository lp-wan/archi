# Evidence Notes: draft-westerlund-schc-compute-address-00

## analysis-gemini
Verdicts: {'conceptual': 'High', 'transition': 'Medium', 'adaptation': 'Trivial'}

### Executive assessment

This review assesses `draft-westerlund-schc-compute-address-00` against `draft-ietf-schc-architecture-06`. SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping involves treating the draft's Address Tables as part of the Set of Variables (SoV), its secret key as part of the Instance Configuration, and its device and network compressor/decompressor as Endpoints hosting client/server SCHC Instances. The principal migration difficulty is that the draft extensively overloads the term 'context' (e.g., using it for the static rules, device-specific address tables, and device identity), which requires careful, manual architectural interpretation to rewrite. An Architecture gap exists because -06 does not explicitly state that the C/D engine can access dynamic runtime variables in the SoV. This gap is Trivial and can be closed with an additive clarification in -06.

### Architectural risk points

- **Risk:** Address Table desynchronization and packets-in-flight.
  - **Why it matters:** The draft does not define a mechanism to synchronize Address Table updates or handle out-of-order/in-flight packets during table rebuilds. When the address set changes, sorting changes, which shifts indices. A packet compressed with the old index but received after a table rebuild will be decompressed using the new index, leading to packet corruption (misdelivery or discard).
  - **Consequence for migration:** Implementations must introduce versioning, grace periods, or out-of-band coordination for Address Tables to prevent transient packet corruption.
- **Risk:** Stateful Compression/Decompression.
  - **Why it matters:** Standard SCHC C/D is stateless and depends only on the static Context. The draft introduces a dependency on dynamic runtime state (Address Tables) in the C/D engine. This complicates the C/D engine architecture, as it must now interact with dynamic session variables (SoV) and handle table invalidation/rebuilding.
  - **Consequence for migration:** Implementations must support stateful C/D engines that interface with the Set of Variables (SoV).
- **Risk:** Clock Synchronization for Temporary IID.
  - **Why it matters:** The `comp-temp-iid` CDA relies on synchronized wall clocks between the compressor and decompressor to derive the correct epoch and Tis. If clocks drift beyond the configured `Interval_Length` tolerance, the decompressor will generate a different IID than the one used by the device, causing decompression failure.
  - **Consequence for migration:** A clock synchronization mechanism (e.g., NTP or 3GPP network time sync) is a hard prerequisite, and the system must handle drift detection and recovery.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4, Paragraph 2 & Section 2 Terminology | "The Address Table is maintained per-context and shared between compressor and decompressor." | Clarify that the Address Table is maintained as part of the Instance's Set of Variables (SoV) rather than the shared static Context (SoR). | REQUIRED FOR CONCEPTUAL ALIGNMENT | To align with SCHC Architecture -06, where Contexts are static and reusable, and dynamic runtime parameters are stored in the Set of Variables (SoV). |
| 2 | Section 7.2, Paragraph 1 | "...or MAY be provisioned as part of the SCHC context setup." (regarding secret_key) | Specify that the secret_key is provisioned as part of the Instance Configuration or SoV, rather than the shared Context. | REQUIRED FOR CONCEPTUAL ALIGNMENT | Storing a device-unique cryptographic key in the Context prevents the Context from being shared across multiple devices in a Domain. |
| 3 | Section 1 & Section 4 | General references to "compressor and decompressor" or "endpoints". | Update the terminology to refer to "SCHC Endpoints" hosting "SCHC Instances" participating in a "SCHC Session". | REQUIRED FOR TERMINOLOGY MIGRATION | To use the standardized architectural terminology of SCHC Architecture -06. |
| 4 | Section 9.2 & Section 4 | General description of device identity and session mapping without architectural terms. | Frame the network-side routing and session mapping in terms of the "Dispatcher" routing packets to the correct "Instance" using a "Discriminator" (e.g. PDU session ID). | REQUIRED FOR TERMINOLOGY MIGRATION | To align the provisioning and routing models with the Dispatcher/Discriminator architecture in -06. |
| 5 | Section 8, Paragraph 3 | "Detailed mechanisms for synchronizing table updates... are outside the scope of this document..." | Add an informative note suggesting that a table version identifier or brief grace period (maintaining old and new tables) could be used to mitigate the risk of packets in flight. | OPTIONAL CLARIFICATION | Provides guidance for implementers to handle the packet corruption risk during table transitions. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 (Terminology) or Section 4.2.2.1 (C/D) | Set of Variables (SoV) / C/D engine | "Set of Variables (SoV): Runtime parameters and session variables, such as fragmentation-related timers, retransmission counters, state flags, and other per-session values that may change during operation." | Add a statement: "The C/D engine may also utilize dynamic runtime parameters from the Set of Variables (SoV) or local Instance state (e.g. dynamically assigned IP addresses or cryptographic keys) to execute specific Matching Operators or Compression/Decompression Actions." | ARCHITECTURE GAP | SCHC Architecture -06 currently assumes C/D operations are based solely on static Context. Enabling MOs and CDAs to access dynamic variables (like Address Tables in the SoV) requires an explicit statement allowing C/D to use the SoV. |
| 2 | Section 4.2.1.2 (Context) | Static Context assumption | "SCHC as defined in [RFC8724] assumes that the Context is static and provisioned before use..." | Add a note clarifying that: "While the Context itself is static, custom Matching Operators and CDAs can reference dynamic session variables (SoV) that are updated at runtime, without requiring context re-provisioning." | OPTIONAL CLARIFICATION | Clarifies how the static Context model coexists with dynamic address compression mechanisms. |

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **No**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft**
- What is the single most important migration issue? **The overloaded use of the word "context" in the draft under study, which must be carefully separated into the static Context (SoR) and the dynamic Set of Variables (SoV) or Instance Configuration to preserve Context sharing and reusability.**
