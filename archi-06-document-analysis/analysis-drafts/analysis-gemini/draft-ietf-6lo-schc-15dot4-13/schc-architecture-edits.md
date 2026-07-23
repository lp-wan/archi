# SCHC Architecture -06 edits needed for draft-ietf-6lo-schc-15dot4-13

## Purpose
A minor architectural clarification is required in the description of Control Header services in Section 4.2.5.1 of SCHC Architecture -06. This clarification explicitly permits a Control Header to carry pointer metadata (such as Bit Pointers) that locates specific fields or residues within the compressed SCHC Datagram. This enables intermediate routing nodes to read or modify these fields (e.g., decrementing the Hop Limit or routing based on the Destination Address residue) without needing the Session's decompression Context.

## Proposed edits
Edit 1 —
- Architecture section: Section 4.2.5.1 (Page 16)
- Architecture concept: Control Header
- Reason: To explicitly support routing models (such as Pointer-based Route-Over (PRO) in the 6LoWPAN draft) where intermediate routers need to locate and inspect/modify specific residues inside a compressed packet without having the full context.
- Classification: ARCHITECTURE GAP

```diff
  The Control Header may itself be a SCHC-compressed structure
  piggybacked on the Datagram, or an explicit protocol providing
  services such as:

  *  Multiplexing (Session, Instance, Context Identifier)

  *  Protection (Integrity)

  *  Metadata (retain information that is lost when performing the SCHC
     operation, e.g., save the initial value of the EtherType field
     when it is changed to EtherType=SCHC)
+
+ *  Routing/inspection pointers (carry pointer metadata, e.g. Bit Pointers,
+    to locate specific fields or residues within the Datagram, allowing
+    intermediate routing nodes to inspect or modify these fields without
+    possessing the Session's decompression Context)
```

## Effect on the draft under study
Applying this edit changes the conceptual mapping of the draft's "PRO Routing / Residue Modification" from a **Partial / Missing** (representing an architecture gap) to a **Profile-specific** deployment configuration. Similarly, the mappings for the auxiliary PRO routing fields ("Bit Pointer" and "Address Residue Length") transition from **Partial** to **Direct** mappings as they are recognized as standard Control Header metadata services.
