# SCHC Architecture -06 edits needed for draft-ietf-ipsecme-diet-esp-10

## Purpose
A minor architecture clarification is required in SCHC Architecture -06 to accommodate protocols that elide the RuleID on the wire (treating it as implicit via the Session/Security Association context) and deployments where the Discriminator is cryptographically compressed and ambiguous, requiring trial decryption/verification by candidate Instances to route the packet correctly.

## Proposed edits
Edit 1 —
- Architecture section: Section 4.2.5
- Architecture concept: RuleID elision / Implicit RuleID
- Reason: Diet-ESP elides the RuleID because the active rule is uniquely determined by the IPsec SA. The architecture should explicitly allow implicit RuleIDs to accommodate such protocols.
- Classification: ARCHITECTURE GAP

```diff
-   A Datagram starts with a RuleID.  The Rule identified by that RuleID
-   determines the format and interpretation of the remaining bits.
+   A Datagram starts with a RuleID, which determines the format and
+   interpretation of the remaining bits.  In some profiles or deployments
+   where the Rule is uniquely determined by out-of-band context (e.g.,
+   a Security Association or a dedicated point-to-point connection), the
+   RuleID may be elided on the wire and treated as implicit.
```

Edit 2 —
- Architecture section: Section 4.2.2.4
- Architecture concept: Discriminator / Dispatcher in Secure Environments
- Reason: When security parameters like SPI are compressed, the Discriminator is ambiguous and the Dispatcher cannot route packets based on simple lookups. It must delegate to trial decryption/verification.
- Classification: ARCHITECTURE GAP

```diff
-   When an Endpoint is supporting multiple Instances, the Instance
-   Manager is responsible for managing the lifecycle and configuration
-   of these Instances.  Datagrams are routed to the appropriate Instance
-   by the Dispatcher using the Discriminator and admission rules based
-   on information provided in the Instance Configuration.
+   When an Endpoint is supporting multiple Instances, the Instance
+   Manager is responsible for managing the lifecycle and configuration
+   of these Instances.  Datagrams are routed to the appropriate Instance
+   by the Dispatcher using the Discriminator and admission rules based
+   on information provided in the Instance Configuration.  In secure
+   deployments where the Discriminator is compressed and potentially
+   ambiguous (e.g., a compressed SPI in IPsec), the Dispatcher may
+   delegate routing to the security stack to perform trial decryption
+   or signature verification across candidate Instances.
```

## Effect on the draft under study
Applying these edits has the following effects on the mappings:
1. The **RuleID** mapping in `draft-ietf-ipsecme-diet-esp-10` becomes **Direct** since the architecture now explicitly supports elided (implicit) RuleIDs.
2. The **SPI** mapping (which acts as a compressed, ambiguous Discriminator) becomes a naturally **Profile-specific** (or Direct) use of the Dispatcher/Discriminator concepts, as the architecture now permits delegating routing decisions to the cryptographic stack.
