# SCHC Architecture -06 edits needed for draft-ietf-schc-schclet-00

## Purpose

SCHC Architecture -06 already defines `SCHClet` (Terminology §3), devotes a dedicated subsection to it
(§4.2.2.3), lists it among the Instance Configuration functionalities (§4.2.1.1), and cites this draft
as `[DRAFT-SCHCLET]`. Only two small **additive** clarifications are required to make the draft map
onto -06 without inference. First, §4.2.2.3 currently frames a SCHClet solely as a subfunction
"combined with other SCHClets within an Instance," and never states the draft's central relationship:
that a *minimal deployment may consist of a single SCHClet in a single Instance operating on a single
Stratum, in which case Instance selection, the Discriminator, and the Control Header are implicit and
MAY be elided.* -06 already supports this pattern implicitly (Appendix A.2.1: "Instance selection is
implicit"; §4.2.2.4), but the SCHClet subsection does not say so. Second, the draft uses the term
"SCHC Stratum Header," which does not appear in -06; a one-line terminology note identifying it with
the Control Header closes the gap. Neither edit changes the meaning of any existing normative text.

## Proposed edits

Edit 1 —
- Architecture section: §4.2.2.3 (SCHClets)
- Architecture concept: SCHClet deployment altitude; implicit Instance selection / Discriminator / Control Header in a minimal single-SCHClet deployment
- Reason: Make the draft's standalone-minimal SCHClet model map Directly (not merely implicitly) onto -06, by stating the already-implied single-SCHClet/single-Instance/single-Stratum relationship explicitly.
- Classification: ARCHITECTURE GAP

```
  A SCHClet is a self-contained unit within the SCHC framework that
  implements a specific SCHC function or a subset of SCHC operations.
  A SCHClet may implement aspects defined in [RFC8724] or functions
  from other related SCHC RFCs, and MAY be combined with other SCHClets
  within an Instance, as specified in the Instance Configuration.
+
+ A minimal SCHC deployment MAY consist of a single SCHClet hosted in a
+ single Instance operating on a single Stratum. In that case, Instance
+ selection is implicit (as described in Section 4.2.2.4), and the
+ Discriminator and the Control Header MAY be elided. Such a deployment
+ remains interoperable with a full SCHC implementation that is
+ configured with a compatible Context and Set of Rules (see
+ Section 6.2).
```

Edit 2 —
- Architecture section: §4.2.5.1 (Control Header for Advanced Use Cases), closing note
- Architecture concept: Control Header terminology; alignment with the "SCHC Stratum Header" term used in [DRAFT-SCHCLET]
- Reason: [DRAFT-SCHCLET] refers to a "SCHC Stratum Header" that does not appear in -06; identifying it with the Control Header prevents the two documents from appearing to use disjoint vocabularies and closes the Partial mapping.
- Classification: ARCHITECTURE GAP

```
  Illustrative Control Header formats are collected in Appendix A.1.
+
+ Note: the term "SCHC Stratum Header" used in [DRAFT-SCHCLET] refers to
+ the Control Header described in this section. When a deployment uses a
+ single Stratum and a single Instance, no such header is required and it
+ is elided.
```

## Effect on the draft under study

With Edit 1 accepted, the draft's central concept — a SCHClet operating on "a single Stratum and a
single SCHC Instance," with the Instance/Discriminator notions omitted — maps **Direct** onto -06's
SCHClet definition rather than requiring the reader to assemble it from §4.2.2.3, §4.2.2.4, and
Appendix A.2.1. The `SCHClet` concept mapping in `verdicts.md` becomes unambiguously Direct.

With Edit 2 accepted, the draft's "SCHC Stratum Header" maps cleanly to the Control Header: the
mapping upgrades from **Partial** to a **Direct** (renamed) correspondence, and the
terminology-migration diff can rewrite every "SCHC Stratum Header" occurrence as "Control Header"
without residual ambiguity.

Together the two edits leave the draft's *Full SCHC Implementation* / *Full Configuration* /
*SCHClet Configuration* vocabulary as the only remaining **Composite** (Instance Configuration +
Context/Set of Rules) mappings, which are natural and require no further architecture change.
