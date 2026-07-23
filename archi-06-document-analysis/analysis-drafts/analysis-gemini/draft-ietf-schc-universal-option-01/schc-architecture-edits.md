# SCHC Architecture -06 edits needed for draft-ietf-schc-universal-option-01

## Purpose
This document specifies the edits needed in `draft-ietf-schc-architecture-06` to address the trivial gap concerning field descriptor ordering and residue serialization sequences when a Context is represented by multiple lists in a data model.

## Proposed edits
Edit 1 —
- Architecture section: Section 4.2.1.2 (Context)
- Architecture concept: Context structure and synchronization
- Reason: The architecture does not specify that the order of field descriptors must be preserved during transmission or how to order descriptors across multiple lists in a data model.
- Classification: ARCHITECTURE GAP

```diff
   The Context contains operational information shared between two or
   more Instances.

   For example, for Header Compression and Decompression (C/D) or
   Fragmentation and Reassembly (F/R), the Context defines the set of C/
   D and F/R Rules - or Set of Rules - describing the specific actions
   to be performed on the packets using the corresponding SCHC
   functionalities, and, optionally, the Parser and the Data Model to
   delineate and dissect the header fields.
+
+  When a Context is represented by a Data Model (such as [RFC9363]),
+  the data model MUST specify a deterministic ordering for the list of
+  field descriptors (entries) to ensure consistent residue serialization.
+  If the data model represents field descriptors across multiple lists
+  or structures, it MUST define the relative processing and serialization
+  order of these structures. The order of field descriptors MUST be
+  preserved when the Context is transmitted, synchronized, or managed.
```

Edit 2 —
- Architecture section: Section 4.2.2.1 (Header Compression and Decompression (C/D))
- Architecture concept: C/D engine processing order
- Reason: The C/D engine must serialize residues in the exact deterministic order defined by the Context's data model.
- Classification: ARCHITECTURE GAP

```diff
   On compression, the C/D engine:

   *  delineates the fields using the Parser and/or Data Model provided
      in the Context;

   *  chooses the appropriate compression Rule among candidate Rules
      from the Context based on the matching policy defined in the
      Instance Configuration;

   *  applies the compression Rule to the fields of the header(s);

   *  generates the compressed SCHC Datagram.  In [RFC8724], a packet
      whose header has been compressed is called a SCHC Packet.
+     The serialization of compression residues in the SCHC Packet MUST
+     follow the deterministic order of field descriptors defined in the
+     Context.
```

## Effect on the draft under study
These edits make the "Entry Serialization Order" mapping **Direct**, as the architecture now explicitly recognizes and enforces the deterministic ordering of field descriptors across multiple data model lists and the corresponding C/D residue serialization sequence.
