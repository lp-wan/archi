# SCHC Architecture -06 edits needed for draft-pelov-schc-header-format-00

## Purpose
This document specifies the additive clarifications required in draft-ietf-schc-architecture-06 to define the concepts of "RuleID Encoding" and "SCHC Header Format", and to introduce an architectural hook that allows intermediate non-C/D nodes (such as firewalls, segment boundaries, and capture tools) to delineate SCHC datagrams.

## Proposed edits
Edit 1 —
- Architecture section: Section 3 (Terminology)
- Architecture concept: Terminology definitions
- Reason: The draft under study introduces the concepts of "RuleID Encoding" and "SCHC Header Format" as structural properties of the framing, which are currently missing from the architecture's glossary.
- Classification: ARCHITECTURE GAP

```diff
--- draft-ietf-schc-architecture-06.txt (Section 3)
+++ draft-ietf-schc-architecture-06.txt (Section 3)
@@ -270,3 +270,11 @@
        packet fragment.  It may be followed by a Payload.
 
+   RuleID Encoding:  How a RuleID at the start of a Datagram is delimited
+      or represented (e.g., fixed-length, context-defined, or self-
+      delimiting).
+
+   SCHC Header Format:  A reusable, structural description of a SCHC
+      Datagram's framing, specifying the RuleID encoding and the Control
+      Header type.
+
    Domain Manager:  A logical component that manages the Domain,
```

Edit 2 —
- Architecture section: Section 4.2.5.1 (Control Header for Advanced Use Cases)
- Architecture concept: Control Header placement and delineation hook
- Reason: To incorporate the "Proposed Architecture Hook" from Appendix A of the draft under study, linking the architecture to the header format specification and defining the role of intermediate nodes.
- Classification: ARCHITECTURE GAP

```diff
--- draft-ietf-schc-architecture-06.txt (Section 4.2.5.1)
+++ draft-ietf-schc-architecture-06.txt (Section 4.2.5.1)
@@ -831,4 +831,12 @@
    The presence, placement, and format of the Control Header must be
    clearly identified, e.g., by a SCHC profile or other specification
    that defines the framing used by the deployment.
 
+   The format of the SCHC Control Header, the RuleID encoding, and the
+   encoding of the Discriminator are deployment-specific.  A node that
+   processes a SCHC datagram without being a C/D endpoint for it - a
+   segment boundary, firewall, classifier, or capture tool - requires a
+   description of the datagram's framing (the RuleID encoding and the
+   Control Header type) in order to delineate it.  Such a description is
+   a SCHC Header Format, specified in draft-pelov-schc-header-format.
+   It may be self-describing in band or fixed out of band, including by
+   an RFC that binds it to a demux point such as an EtherType.
+
```

## Effect on the draft under study
After applying these edits:
- The mapping of "SCHC Header Format" becomes **Direct** (to the newly defined concept in the architecture).
- The mapping of "RuleID Encoding" becomes **Direct** (to the newly defined concept in the architecture).
- The delineation of datagrams by intermediate nodes becomes an explicitly recognized architectural concept, removing the need for a composite or profile-specific interpretation.
