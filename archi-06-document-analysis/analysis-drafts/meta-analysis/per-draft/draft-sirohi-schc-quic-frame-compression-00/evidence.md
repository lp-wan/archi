# Evidence Notes: draft-sirohi-schc-quic-frame-compression-00

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

The reference architecture `draft-ietf-schc-architecture-06` can naturally and completely express the concepts and technical model of `draft-sirohi-schc-quic-frame-compression-00`. The principal conceptual mapping relates the draft's "inner compressor" and "outer compressor" to two separate SCHC Endpoints (or Instances) operating on different Strata (the QUIC frame stratum and the IP/UDP stratum) on the same physical equipment. The principal migration difficulty is ensuring that the implementation architecture and integration options (like the alternative payload syntax and extension frames) are framed using the formal -06 concepts of Datagrams, Control Headers, Dispatchers, and Discriminators rather than implementation-specific terms like "compressor container." No architectural gaps exist in `draft-ietf-schc-architecture-06`, as all required mechanisms are already natively supported.

### Architectural risk points

- **Risk: Stateful compression synchronization under loss**
  - **Why it matters:** If a stateful rule derives fields (like Stream Offsets or Largest Acknowledged) from prior packets, packet loss or reordering can cause desynchronization of the Set of Variables (SoV) between the compressing and decompressing Instances. Unlike IP/UDP where packet loss is handled by upper layers, QUIC frame decompression failure would cause a decryption or parsing error, resulting in a fatal connection teardown (CONNECTION_CLOSE).
  - **Consequence for migration:** The profile for QUIC frame compression must strictly limit stateful rules to intra-packet derivations (e.g. deriving offsets from fragments in the same packet) or define a robust, out-of-band resynchronization mechanism, which -06 does not define.
- **Risk: Dispatcher complexity in the split architecture**
  - **Why it matters:** In a split architecture, the inner Instance processes frames before encryption, and the outer Instance processes IP/UDP/QUIC headers after packet construction. If both are hosted by a single Endpoint, the Dispatcher must handle nested interception and routing. This requires the Dispatcher to intercept packets at two different stages of the network stack, which increases stack integration complexity and breaks the assumption of a single packet flow.
  - **Consequence for migration:** The implementation should model the inner and outer compressors as two distinct Endpoints on the same physical equipment, each with its own local Dispatcher, rather than a single Endpoint.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 2.2, 2.3, 4.1, 5.1 | "Rule ID" | Change to "RuleID" | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal spelling used in draft-ietf-schc-architecture-06. |
| 2 | Section 2.2, 4.3, 6.1, 8 | "static context", "context" | Capitalize as "Context" when referring to the shared SCHC ruleset and parser metadata | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal term defined in draft-ietf-schc-architecture-06. |
| 3 | Section 6.1 | "Unified SCHC Compressor" / "context" | Describe as a single SCHC Instance on an Endpoint, with a Context whose Stratum spans the IP, UDP, and QUIC frame layers. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the formal -06 architectural concepts of Instance and Stratum. |
| 4 | Section 6.2 | "Separate Inner and Outer Compressors" | Describe as separate SCHC Endpoints (or Instances) operating at different Strata (inner frames vs outer headers) on the same physical equipment. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concept of Stratum and the support for multiple Endpoints/Instances on the same equipment. |
| 5 | Section 5.2 | "Extension Frame Type" and "Container Length" | Frame as a Control Header placed before the RuleID of the SCHC Datagram. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concept of a Control Header and its placement options. |
| 6 | Section 5.3 | "Extension Frame per Compressed Frame Type" | Frame as the Extension Frame Type acting as a Dispatcher Discriminator to route the incoming packet to the correct SCHC Instance, representing the RuleID. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 concepts of Dispatcher, Discriminator, and RuleID. |
| 7 | Section 4.4 | "prior packet state" / "compression state" | Describe stateful rules in terms of the Set of Variables (SoV), distinguishing it from the static Set of Rules (SoR) in the Context. | REQUIRED FOR TERMINOLOGY MIGRATION | Align with the -06 definition of Set of Variables (SoV) for runtime state. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 4.2.2.4 | Multiple Instances / Stratum | N/A | Add a paragraph explaining that separate Endpoints or Instances can operate at different Strata in a nested/layered manner, where the output of an inner Stratum Instance is encapsulated and subsequently processed as payload by an outer Stratum Instance. | OPTIONAL CLARIFICATION | Clarifies that nested/layered SCHC instances (such as inner QUIC frames and outer IP/UDP headers) are fully compatible with the architecture. |

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (It requires minor rewording in Section 6 to frame the implementation architectures using the formal -06 Concepts, but the rest is mechanical terminology replacements).
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable (no gap exists).**
- What is the single most important migration issue? **Mapping the implementation architectures in Section 6 (specifically the separate inner and outer compressors) to the -06 concepts of separate Endpoints/Instances operating on different Strata (inner QUIC frame stratum vs outer IP/UDP/QUIC header stratum).**
