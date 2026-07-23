# SCHC Architecture -06 edits needed for draft-ietf-schc-universal-option-01

## Purpose
draft-ietf-schc-universal-option-01 splits a compression Rule's Field Descriptors across two
YANG lists and states twice (Sections 5.2 and 5.4.3) that the resulting entry-ordering
constraint — residue serialization follows entry order, so all participants must process
entries in the same order and the order must survive Rule transmission — "should be documented
in [I-D.ietf-lpwan-architecture]", i.e., in the SCHC architecture. Architecture -06 implies
this through "identical SoR" / "compatible Contexts" (Section 6.2) but never states it, and a
YANG-based Context store may legally reorder list entries unless the ordering is declared part
of the Context. One additive clarification in Section 6.2 closes the gap; the conceptual model
of -06 is unchanged.

## Proposed edits

Edit 1 —
- Architecture section: 6.2 Context consistency
- Architecture concept: Context / Set of Rules — order of Field Descriptors (entries) within a Rule
- Reason: Make explicit that entry order is part of the Context and must be preserved by
  Context distribution and synchronization, so that Data-Model documents (such as
  draft-ietf-schc-universal-option-01 / the RFC 9363 revision) can reference the architecture
  for this interoperability requirement.
- Classification: ARCHITECTURE GAP

```
  To facilitate the provisioning and synchronization of Contexts within
  a Domain for a given Session, it is recommended to deploy the same
  Context (with identical SoR) on all Instances participating in a
  given Session.  However, it is possible for one or more Instances to
  have only a subset of the SoR, as long as the Contexts of the
  Instances participating in a given session remain compatible.

+ The order of the Field Descriptors (entries) within a Rule is part of
+ the Context.  The serialization of compression residues follows that
+ order; therefore, Context distribution and synchronization must
+ preserve the order of the entries of each Rule, and all Instances
+ participating in a Session must process the entries of a Rule in the
+ same order.  When the representation of a Rule contains several lists
+ of entries (for example, a Data Model and its augmentations), the
+ Context must define a single, deterministic processing order covering
+ all entries of the Rule.  A Data Model used to represent the Context,
+ such as [RFC9363], is expected to make this ordering explicit (e.g.,
+ by using ordered lists).
```

(The new paragraph is inserted after the first paragraph of Section 6.2, before the
compatible-partial-Contexts illustration. No existing text is modified or removed.)

## Effect on the draft under study
With this edit applied:

- The mapping of the draft's "residue serialization order / entry-order preservation"
  requirement (Sections 5.2 and 5.4.3) changes from **Partial** to **Direct**: it becomes a
  plain instance of -06 Context consistency, and the draft's pointers to the architecture
  document (currently to the obsolete [I-D.ietf-lpwan-architecture]) can be redirected to
  Section 6.2 of [I-D.ietf-schc-architecture] with no loss of meaning.
- The draft's ordering rule "fields from the standard `entry` list MUST be serialized before
  those defined in the `entry-option-space` list" remains naturally **Profile-specific /
  Data-Model-specific**: it is the deterministic processing order that the (revised) RFC 9363
  Data Model defines, exactly as the new architecture paragraph requires.
- No other mapping is affected; all remaining concepts of the draft were already Direct,
  Composite, or naturally Profile-specific under -06.
