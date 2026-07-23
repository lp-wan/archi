# SCHC Architecture -06 edits needed for draft-corneo-schc-ctx-mgmt-00

## Purpose
This document specifies the trivial proposed edits to `draft-ietf-schc-architecture-06` that explicitly define and clarify rule referencing, rule fragments, and recursive/sequential rule composition within the C/D engine. These changes ensure the architecture naturally supports composed rules and modular protocol stacks.

## Proposed edits

Edit 1 —
- Architecture section: Section 3 (Terminology)
- Architecture concept: Rule
- Reason: Clarify that a Rule can reference or branch to other rules in the Set of Rules, establishing conceptual support for composed rule definitions.
- Classification: ARCHITECTURE GAP

```diff
 Rule:  A structured description, identified by a RuleID, of how SCHC
    processes a packet or a SCHC message.  Depending on its type, a
    Rule defines C/D field descriptors, F/R mode and parameters, or
-   no-compression behavior.
+   no-compression behavior.  Rules may reference other rules or branch
+   to alternative rules (rule fragments) within the same Set of Rules
+   to enable modular or dynamic protocol compression.
```

Edit 2 —
- Architecture section: Section 3 (Terminology)
- Architecture concept: Rule Fragment (New Term)
- Reason: Introduce the formal definition of a Rule Fragment into the architectural glossary to match the draft under study.
- Classification: ARCHITECTURE GAP

```diff
+Rule Fragment:  A Rule designed to compress or decompress a specific
+   portion or layer of a packet, intended to be composed with other
+   Rules or Rule Fragments.
```

Edit 3 —
- Architecture section: Section 4.2.2.1 (Header Compression and Decompression (C/D))
- Architecture concept: C/D Engine execution
- Reason: Clarify that applying a compression/decompression rule is not restricted to a single flat rule, but can involve sequential/recursive execution of referenced rules or fragments.
- Classification: ARCHITECTURE GAP

```diff
 Internally, on compression, the C/D engine:
 
 *  delineates the fields using the Parser and/or Data Model provided
    in the Context;
 
 *  chooses the appropriate compression Rule among candidate Rules
    from the Context based on the matching policy defined in the
    Instance Configuration;
 
-*  applies the compression Rule to the fields of the header(s);
+*  applies the compression Rule to the fields of the header(s);
+   this may include sequentially or recursively executing referenced
+   rules or rule fragments if specified by the rule's actions;
 
 *  generates the compressed SCHC Datagram.  In [RFC8724], a packet
    whose header has been compressed is called a SCHC Packet.
```

## Effect on the draft under study
Applying these proposed edits to the SCHC Architecture has the following effects on the draft's conceptual mapping:
- The mapping of `ref(N)` and `ref-edit(N,M)` CDAs to standard C/D engine execution transitions from **Profile-specific** (which required interpretation of rule redirection) to **Direct**, as sequential/recursive execution is now an explicitly supported behavior of the C/D engine.
- The concept of **Rule Fragment** transitions from a custom definition requiring decomposition to a **Direct** mapping with the newly introduced terminology in Section 3.
- The `branch` CDA and its associated `match-rule` MO map cleanly and naturally to the C/D engine's expanded capability to branch and compose rules dynamically during execution.
