# SCHC Architecture -06 edits needed for draft-ietf-intarea-schc-protocol-numbers-02

## Purpose

draft-ietf-intarea-schc-protocol-numbers-02 asks, in its Section 6.3, whether an IANA registry of SCHC RuleID values is needed for the SCHC Ethertype, and sketches one in which the top nibble of a 1-byte RuleID would be assigned to "different domains of use, like for aviation" and the value 15 would designate a 2-byte RuleID. Whether such a registry is architecturally coherent depends entirely on the uniqueness scope of a RuleID — and SCHC Architecture -06 never states it. Section 3 has no Terminology entry for RuleID; Section 4.1.2 scopes the identifiers of Instances, Contexts and Sessions to their Domain and passes over the RuleID in silence; Section 4.2.5.1 requires that the Control Header be locatable before parsing but says nothing about the RuleID's own size, even though the same section already assumes a profile can fix that size. Three additive clarifications close the gap: define the RuleID, state that it is Context-scoped rather than Domain-scoped, and state that its size must be determinable before the Datagram is parsed. No existing definition or architectural statement changes meaning, and no architectural concept is added, removed, or re-scoped.

## Proposed edits

Edit 1 —
- Architecture section: 3 (Terminology)
- Architecture concept: RuleID
- Reason: RuleID is the most visible identifier in the whole framework, is used throughout -06 (Sections 4.1.1, 4.2.2.1, 4.2.5, 4.2.5.1, 6.1, Appendix A.2.1), and has no definition. The draft's Section 6.3 cannot be evaluated without one. Insert immediately after the `Rule:` entry and before `Set of Rules (SoR):`.
- Classification: ARCHITECTURE GAP

```
   Rule:  A structured description, identified by a RuleID, of how SCHC
      processes a packet or a SCHC message.  Depending on its type, a
      Rule defines C/D field descriptors, F/R mode and parameters, or
      no-compression behavior.

+  RuleID:  The identifier of a Rule within a Context.  A RuleID is
+     meaningful only with respect to the Context of the Instances
+     participating in a Session: the same RuleID value may designate
+     different Rules in different Contexts.  A profile or a deployment
+     MAY constrain the allocation of RuleID values, for example by
+     fixing the RuleID size or by reserving RuleID ranges whose
+     interpretation is agreed among the deployments concerned.  Such a
+     constraint does not extend the scope in which a RuleID is unique
+     beyond the Contexts to which it applies.
+
   Set of Rules (SoR):  The collection of C/D, F/R, and no-compression
      Rules available to an Instance.
```

Edit 2 —
- Architecture section: 4.1.2 (Basic SCHC Architecture), final paragraph
- Architecture concept: identifier scope
- Reason: the existing sentence enumerates three identifiers and omits the fourth, inviting the reader to assume the RuleID shares the Domain scope. It also leaves unstated how a deployment selects an Instance or Context from information carried in the Datagram, which is precisely what the draft's Section 6.3 registry appears to attempt with RuleID bits. The existing sentence is retained verbatim; one sentence is appended.
- Classification: ARCHITECTURE GAP

```
   Identifiers for Instances, Contexts, and Sessions are unique within
   the scope of their Domain.

+  The RuleID is not a Domain-scoped identifier: it identifies a Rule
+  within a Context (Section 3).  Where a deployment needs to select an
+  Instance or a Context from information carried in the Datagram, it
+  does so through a Discriminator or a Control Header (Section
+  4.2.5.1), and not by relying on RuleID values being unique across
+  Contexts or across Domains.
```

Edit 3 —
- Architecture section: 4.2.5.1 (Control Header for Advanced Use Cases)
- Architecture concept: determinability of the RuleID size
- Reason: Section 4.2.5.1 already states that "The information needed to locate and decode the Control Header must be known before that information is used," and already assumes that "a profile may define a fixed RuleID size." It never states the underlying prerequisite that the RuleID size itself must be resolvable before the Datagram is parsed. The draft resolves it two ways — a source-address-keyed table in its Section 3, and a self-describing top-nibble escape in its Section 6.3 — and -06 gives neither a stated footing. Insert after the paragraph beginning "The information needed to locate and decode the Control Header".
- Classification: ARCHITECTURE GAP

```
   The information needed to locate and decode the Control Header must
   be known before that information is used.  For example, a profile may
   define a fixed RuleID size and specify that RuleID values in a
   particular range are followed by a Control Header having a known
   format.  Those framing semantics are independent of the C/D or F/R
   Rule selected by the RuleID.  The Control Header can therefore remain
   decodable when that Rule is unknown or cannot be applied.

+  The same applies to the RuleID itself: because the RuleID size may
+  vary, the receiving Instance must be able to determine that size
+  before the Datagram is parsed.  A deployment may achieve this by
+  fixing the RuleID size in a profile, by deriving it from the Instance
+  Configuration of the Instance selected by the Dispatcher from the
+  Discriminator, or by making the RuleID self-delimiting, e.g., by
+  reserving a value of its leading bits to indicate a longer RuleID.
+  The RuleID size cannot be derived from the Rule that the RuleID
+  selects.
```

## Effect on the draft under study

With edits 1 and 2 accepted, the draft's Section 6.3 becomes expressible without reinterpreting any -06 concept. The proposed registry stops being a claim about global RuleID uniqueness — which -06 would not support — and becomes a reservation of RuleID ranges whose interpretation is agreed among the deployments that use the SCHC Ethertype. The `domain of use` concept, which the Concept mapping in `verdicts.md` classifies **Partial** because -06 supplies no scope in which a cross-deployment RuleID meaning can live, remains a coordination convention over a codepoint space rather than an -06 Domain, and is explicitly distinguished from one. The draft's Section 6.3 can then say what it means without asserting anything -06 denies.

With edit 3 accepted, the two mechanisms by which the draft determines RuleID size both acquire a natural home. The source-IP-address table of the draft's Section 3 becomes the second option listed in the new paragraph — the RuleID size derived from the Instance Configuration of the Instance the Dispatcher selected from the Discriminator — which is a **Composite** mapping onto Discriminator, Dispatcher, Instance and Instance Configuration. The `value of 15 designates a 2-byte RuleID` escape of the draft's Section 6.3 becomes the third option, a self-delimiting RuleID, and its mapping settles as naturally **Profile-specific**: it is the same architectural move as the RuleID-range-driven framing that Section 4.2.5.1 already permits, applied to the RuleID's own length rather than to the Control Header's position. Before edit 3, that mapping could not be called Direct, because -06 had no RuleID-size statement for it to correspond to.

The remaining mappings are unaffected. The three requested codepoints already map **Direct** onto the Discriminator by virtue of -06's Appendix A.2.3, which names this draft and states that the value "serves as the Discriminator"; the draft's Figure 1 already is -06's Datagram Format; and the datagram-length requirement of the draft's Section 4 is already a legitimate profile-level constraint on Rule content under -06's Section 5. None of those needed an architecture change, and none is proposed.
