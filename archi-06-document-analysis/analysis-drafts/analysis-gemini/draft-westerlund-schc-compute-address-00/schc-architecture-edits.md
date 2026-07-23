# SCHC Architecture -06 edits needed for draft-westerlund-schc-compute-address-00

## Purpose
A minor Architecture clarification is required to explicitly allow the Compression/Decompression (C/D) engine to utilize dynamic runtime parameters (such as the dynamically assigned IP addresses stored in the Address Tables) from the Set of Variables (SoV) or local Instance state, rather than being restricted to static Context parameters.

## Proposed edits
Edit 1 —
- Architecture section: Section 3 (Terminology)
- Architecture concept: Set of Variables (SoV)
- Reason: Clarify that the SoV can include dynamic runtime parameters used by the Compression/Decompression (C/D) engine, not just fragmentation-related variables.
- Classification: ARCHITECTURE GAP

```diff
    Set of Variables (SoV):  Runtime parameters and session variables,
       such as fragmentation-related timers, retransmission counters,
       state flags, and other per-session values that may change during
-      operation.
+      operation.  The Set of Variables may also include dynamic state
+      utilized by the Compression/Decompression (C/D) engine, such as
+      dynamically assigned IP addresses or address tables.
```

Edit 2 —
- Architecture section: Section 4.2.2.1 (Header Compression and Decompression (C/D))
- Architecture concept: C/D engine state access
- Reason: Explicitly define the C/D engine's ability to retrieve dynamic runtime parameters from the SoV during matching and compression/decompression operations.
- Classification: ARCHITECTURE GAP

```diff
    Internally, on compression, the C/D engine:
 
    *  delineates the fields using the Parser and/or Data Model provided
       in the Context;
 
+   *  retrieves dynamic runtime parameters (such as address tables) from
+      the Set of Variables (SoV) if required by the Matching Operators
+      or CDAs;
+
    *  chooses the appropriate compression Rule among candidate Rules
       from the Context based on the matching policy defined in the
       Instance Configuration;
```

## Effect on the draft under study
Applying these edits allows the Address Table concept in draft-westerlund-schc-compute-address-00 to map Directly to the Set of Variables (SoV) in SCHC Architecture -06. This resolves the partial match by explicitly permitting the C/D engine to access dynamic runtime variables, ensuring the draft's compute-address mechanism is fully compliant with the architecture.
