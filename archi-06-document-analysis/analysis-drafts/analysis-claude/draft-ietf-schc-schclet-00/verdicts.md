# Architectural alignment review: draft-ietf-schc-schclet-00

## Verdicts
- Conceptual equivalence: **High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **Trivial**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | The draft's own terms *Full SCHC Implementation*, *Full Configuration*, and *SCHClet Configuration* are not single -06 concepts; they require composite decomposition into Instance + Instance Configuration + Context/Set of Rules. The draft's *SCHC Stratum Header* is not a defined -06 term and requires interpretation as the Control Header. There is also a genuine framing tension: the draft treats a SCHClet as a possibly-standalone minimal deployment, whereas -06 §4.2.2.3 frames it as a subfunction *combined within an Instance*. Interpretation is needed, so it is not a pure terminology exercise. | -06 already **defines** SCHClet (Terminology §3 and §4.2.2.3), already **references** this draft ([DRAFT-SCHCLET]), and already lists SCHClets in the Instance Configuration. Every native concept maps Direct or Composite; nothing needs reinterpretation of the technical model, and no concept is Missing. The single-Instance implicit-selection behaviour the draft relies on is already stated in -06 (§4.2.2.4, Appendix A.2.1). |
| Transition difficulty | Easy | Two locations need architectural judgement rather than find/replace: (a) the repeated triad "SCHC Stratum Header, SCHC Instance and Discriminator" must be reconciled with -06's Control Header / Discriminator / Instance vocabulary, and (b) the "operates on a single Instance … notions can be omitted" framing must be reconciled with -06's "combined within an Instance." These recur across §1, §3.1, §4, §4.1. | The document is short (~12 pages, mostly examples). The largest example (§5.3) already uses -06-native vocabulary verbatim (Context, Rule, RuleID, MO, CDA, field descriptors) and needs no change. Technical intent is stable everywhere; no protocol behaviour changes. The mapping decisions are clear and repeatable, so it is not Medium. |
| SCHC Architecture adaptation need | Trivial | No existing -06 normative text must change meaning, and no architectural concept, relationship, or scope is added, removed, or re-scoped. The SCHClet concept, single-Instance implicit selection, and Context-compatibility interop are all already present. So it is below Medium. | -06 §4.2.2.3 frames a SCHClet only as a subfunction *combined within an Instance* and never explicitly states the draft's central relationship — that a *minimal deployment may consist of a single SCHClet in a single Instance/Stratum, in which case Instance selection, Discriminator, and any Control ("Stratum") Header are implicit and MAY be elided*. Making this already-implied relationship explicit (plus a one-line terminology note that the draft's "SCHC Stratum Header" is the -06 Control Header) is a small additive clarification — hence not None. |

## Executive assessment

SCHC Architecture -06 can **naturally express** draft-ietf-schc-schclet-00. This is the strongest
possible starting position: -06 was authored with awareness of the SCHClet work, already carries a
normative **SCHClet** definition (Terminology §3 and a dedicated §4.2.2.3), already cites this draft
as `[DRAFT-SCHCLET]`, and already lists *SCHClets (modular subfunctions)* among the SCHC
functionalities selectable in an Instance Configuration (§4.2.1.1).

**Principal conceptual mapping.** A SCHClet maps **Direct** to the -06 SCHClet concept: a
self-contained modular subfunction executed within an Instance. The draft's supporting vocabulary
maps **Composite** but naturally: a *Full SCHC Implementation* is an Endpoint whose Instance runs the
full set of SCHC functions with a complete Instance Configuration and Context; a *Full Configuration*
/ *SCHClet Configuration* pair is a complete Instance Configuration + Context/Set of Rules versus a
constrained subset thereof. The draft's operative claim — that a SCHClet "operates on a single
Stratum and a single SCHC Instance" and MAY omit *SCHC Stratum Header, SCHC Instance, and
Discriminator* — is already sanctioned by -06, which states that when a single Instance is present,
"Instance selection is implicit" and the Discriminator/Control Header may be elided (§4.2.2.4,
Appendix A.2.1).

**Principal migration difficulty.** Only two recurring items need judgement rather than mechanical
substitution: (1) the term **SCHC Stratum Header**, which is not defined in -06 and must be read as
the -06 **Control Header**; and (2) the **framing** of a SCHClet as a standalone minimal
implementation, which must be reconciled with -06's "subfunction combined within an Instance" framing.
Both recur but are localised to the introductory and definitional sections; the technical examples are
already -06-aligned.

**Architecture gap.** There is a **Trivial** gap only: -06 never explicitly states the relationship
the draft depends on (a minimal deployment = a single SCHClet in a single Instance/Stratum, with
Instance/Discriminator/Control-Header implicit), and never notes that the draft's "SCHC Stratum
Header" is the Control Header. Both are additive clarifications that change no existing -06 meaning.
They are captured in `schc-architecture-edits.md`.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHClet | A self-contained unit implementing one specific SCHC function or a subset of SCHC operations (e.g. NoAck fragmentation only, IPsec compression only) | An implementation / endpoint that need not host a full SCHC stack | "A single Stratum and a single SCHC Instance" (§1, §4.1) | Its SCHClet Configuration (the profiles/parameters it supports) | A SCHClet MAY be combined with other SCHClets or integrated into a full SCHC implementation; several SCHClets may coexist; one SCHClet ↔ one Stratum + one Instance | Central concept; explicitly "inspired by chiplet architectures" |
| Full SCHC Implementation | An implementation covering all mandatory SCHC aspects (RFC 8724) plus possibly related RFCs | A capable device / endpoint | Whole SCHC apparatus | — (implicitly its Full Configuration) | MUST interoperate with any SCHClet given the corresponding configuration | Interop counterparty for a SCHClet |
| Full SCHC Implementation Configuration (Full Configuration) | The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation | Configuration state of the Full Implementation | Deployment / implementation | — | Superset of any SCHClet Configuration | Purely descriptive configuration state |
| SCHClet Configuration | A subset of a Full Configuration, implemented/supported by a given SCHClet (a single SCHC Profile, or a set) | Configuration state of the SCHClet | The SCHClet | The defining descriptor of the SCHClet | Subset of Full Configuration; fully defines the SCHClet | "A SCHClet is fully defined by its corresponding SCHClet Configuration" (§4) |
| Stratum | (Borrowed) the portion of the protocol stack SCHC processes; a SCHClet is confined to one | The Instance/SCHClet | Single per SCHClet | — | 1 Stratum per SCHClet | Used as an assumed term; defined in -06 §3 |
| SCHC Instance | (Borrowed) the executing SCHC component; a SCHClet is confined to one | The endpoint | Single per SCHClet | — | 1 Instance per SCHClet | Term the draft says MAY be omitted for a SCHClet |
| SCHC Stratum Header | A header notion that, for a single-Stratum SCHClet, is "always fully elided" and MAY be omitted from the spec | Carried with SCHC-processed data (when present) | Cross-Stratum multiplexing | — | Elided when a single Stratum | **Not defined in -06**; conceptually a multiplexing/control header |
| Discriminator | (Borrowed) value routing data to an Instance; MAY be omitted for a single-Instance SCHClet | Dispatcher | Multi-Instance demux | — | Not needed with a single Instance | Term the draft says MAY be omitted |
| Rule / RuleID / SCHC Context | Concrete compression rules, RuleIDs, and a JSON SCHC Context enabling interop | The SCHClet and its peer | Per Context / per Instance | RuleID (8-bit in example) | 2 rules in the example; RuleID selects a Rule | §5.3 uses the RFC 9363-style data model verbatim |
| Rule Management (discovery, installation, update) | Machinery a SCHClet MAY omit entirely or support only partially (e.g. read-only) | Management function | Domain / management | — | Optional; may be absent | §3.1 "Exclusion / Simplification of Rule Management" |
| MO / CDA (CoDA) | Matching Operators / Compression-Decompression Actions; a SCHClet may use only a subset | The C/D function | Per Rule/field | — | Subset of the full MO/CDA set | §5.1, §5.3 |
| Interoperability requirement | A Full SCHC Implementation with the right configuration MUST interoperate with a specific SCHClet; the SCHClet's fixed behaviour can be "reinterpreted as a full SCHC implementation would" | Both peers | Peer-pair / Session | Shared/compatible configuration | N:1 (many SCHClets ↔ one Full Implementation) | Interop rests on a shared/compatible Context |
| SCHClet citation convention | A document MAY declare "Using a SCHClet of the SCHC Framework, with the following supported configuration/parameters/profiles: …" | Specification text | Document-level | — | — | Editorial/registration convention |

## Native architectural model

The draft is not a protocol specification; it is a **framing document** that proposes a way of
*packaging and describing* SCHC functionality. Its central move is to name a unit — the **SCHClet** —
that is smaller than a complete SCHC implementation. Where RFC 8724 and its successors are read as one
monolithic apparatus, the draft argues that in practice many deployments use only a slice of it (it
cites RFC 9011, which has no rule discovery/management), and that this slice deserves a first-class
name and a lightweight way to be specified.

A SCHClet is defined **entirely by its configuration**: "a SCHClet is fully defined by its
corresponding SCHClet Configuration," where that configuration is a subset of the Full Configuration
of a hypothetical Full SCHC Implementation. The draft therefore treats configuration, not code
structure, as the identity of a SCHClet. Two implementations supporting the same SCHClet Configuration
are the same SCHClet regardless of how they are built (the §5.3 example is a fixed, constant-time,
byte-level C function with no rule engine at all).

The draft's key **simplifying claim** is scope confinement: a SCHClet "operates on a single Stratum
and on a single SCHC Instance." From that confinement it derives that three "architecture notions" —
**SCHC Stratum Header, SCHC Instance, and Discriminator** — become unnecessary and MAY be omitted from
a SCHClet's specification. The reasoning is that these three exist to *separate and route among*
multiple strata/instances; with exactly one of each, there is nothing to separate or route, so the
Stratum Header is "always fully elided" and no Discriminator is needed.

The draft is careful to preserve **interoperability** as the invariant that makes a SCHClet still
"SCHC." A minimal SCHClet — even a fixed one with no parameterisation — MUST interoperate with a Full
SCHC Implementation that has been given the corresponding configuration. The draft explicitly allows
that a SCHClet implementer "may never formally use Rule Management, Discriminators, SCHC Header or
other notions," because "these can be inferred by the knowledgeable SCHC practitioner" and
"reinterpreted as a full SCHC implementation would." Interoperability, in other words, is guaranteed
by a **shared/compatible Context**, even when one side never reifies the surrounding architecture.

The remainder of the draft is **illustrative**. §3.1 lists simplifications (excluding or reducing rule
management; omitting Stratum Header/Instance/Discriminator; encapsulating optional functions such as
Compound ACK or advanced fragmentation modes in separate SCHClets). §5 gives use cases: an IPsec
compression SCHClet (only compression rules and a subset of CoDAs; the Diet-ESP case), three
fragmentation-mode SCHClets (NoAck, Ack-on-Err, Ack-Always), and a fully worked minimal fixed-field
IPv6 compression SCHClet with a JSON SCHC Context and a C implementation.

Two relationships in the native model deserve emphasis because they drive the mapping. First,
**cardinality is one-per-SCHClet on the confining axes** (one Stratum, one Instance) but
**many-per-implementation on the composition axis** (a SCHClet MAY be combined with other SCHClets).
Second, the **interoperability relationship is asymmetric and N:1**: many different minimal SCHClets
can each interoperate with one Full SCHC Implementation, provided that implementation is configured
with the matching (super)set. Neither relationship assumes point-to-point topology as a normative
constraint; the two-node examples (IPsec end-points) are illustrative.

Finally, the draft leaves several things **implicit**, which the analysis treats as ambiguity rather
than silently resolving. It never defines "SCHC Stratum Header" (it borrows the term). It never states
whether a SCHClet is architecturally a *sub-component of* an Instance or a *reduced form of* an
Instance/Endpoint — the text supports both readings ("operates on a single SCHC Instance" suggests
sub-component; "an endpoint may implement a single SCHClet" suggests reduced Endpoint). And it leaves
the provisioning of the shared configuration to "proper configuration and negotiation mechanisms …
essential," without specifying them.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHClet | Self-contained modular SCHC subfunction / subset | SCHClet (§3 Terminology; §4.2.2.3; §4.2.1.1 Instance Configuration item) | Direct | Aligned — -06 scopes a SCHClet within an Instance; draft scopes it to a single Instance | Aligned — -06: "MAY be combined with other SCHClets within an Instance"; draft: "MAY be combined with other SCHClets" | Framing emphasis differs: -06 = subfunction *within* an Instance; draft = also a standalone minimal deployment. Reconcilable, not contradictory | -06 literally defines the term and cites this draft |
| Full SCHC Implementation | Implementation of all mandatory SCHC + related RFCs | Endpoint hosting an Instance whose Instance Configuration Manifest requires the full function set (C/D, F/R, SCHClets) over a complete Context | Composite | Aligned | Aligned (N:1 interop counterparty) | -06 has no single term "Full SCHC Implementation"; it is an Instance/Endpoint at maximal configuration | Natural composite; no reinterpretation |
| Full Configuration | Set of Profiles/configs/params of a Full SCHC Implementation | Instance Configuration + Context (Set of Rules) at full extent | Composite | Aligned | Superset relation preserved | Splits across two -06 concepts (per-Instance config vs shared Context) | The split is a clarification, not a conflict |
| SCHClet Configuration | Subset of Full Configuration realised by a SCHClet; fully defines the SCHClet | A constrained Instance Configuration + a subset/compatible Context (Set of Rules) | Composite | Aligned | Subset relation preserved | Same split as above | -06's "compatible partial Contexts" (§6.2, Appendix A.3) directly supports the subset relation |
| Stratum | Portion of the stack SCHC processes | Stratum (§3 Terminology; §4.2.1.1 packet-interception criteria) | Direct | Aligned | 1 per SCHClet ⊆ -06's Stratum-per-Instance framing | None | Borrowed term; identical meaning |
| SCHC Instance | Executing SCHC component | Instance (§3; §4.2.1) | Direct | Aligned | Aligned | None | Borrowed term; identical meaning. Draft's "MAY be omitted" = "left implicit," since -06's Instance always exists conceptually |
| SCHC Stratum Header | Header elided for a single-Stratum SCHClet; MAY be omitted | Control Header (§4.2.5.1) — specifically its Multiplexing service | Partial | Aligned in spirit — both are elided/absent when a single Stratum/Instance is used | Aligned — absent with one Instance | -06 does not use the term "Stratum Header"; the Control Header multiplexes Session/Instance/Context (Stratum implied via Instance). Requires interpretation | Terminology-migration item; drives the Trivial architecture note |
| Discriminator | MAY be omitted for a single-Instance SCHClet | Discriminator (§3; §4.2.2.4) | Direct | Aligned — -06: single Instance ⇒ implicit selection, Discriminator may be elided | Aligned | None | -06 §4.2.2.4 and Appendix A.2.1 already state the implicit-Discriminator case |
| Rule / RuleID / SCHC Context | Concrete rules, RuleIDs, JSON Context for interop | Rule / RuleID / Context / Set of Rules (§3; §4.2.5) | Direct | Aligned | Aligned (RuleID selects a Rule within a Context) | None | §5.3 JSON matches the RFC 9363 data model referenced by -06 |
| Rule Management (omit / simplify) | Discovery/installation/update a SCHClet may omit or reduce | Domain Manager / Instance Manager / Context Repository functions, which -06 does not make mandatory for an Instance | Profile-specific | Aligned — -06 permits deployments (e.g. RFC 9011) with pre-provisioned static Contexts and no runtime management | Aligned | -06 never requires rule discovery/management at the Instance; omission is a natural profile constraint | Natural use of -06; not a gap |
| MO / CDA (CoDA) subset | Subset of Matching Operators / CD Actions | MO / CDA (§3) applied per Rule/field | Direct | Aligned | Aligned | None | Using a subset is inherent to authoring Rules |
| Interoperability requirement | Full Implementation MUST interoperate with a SCHClet given matching config | Context consistency / compatible partial Contexts (§6.2, Appendix A.3); shared Context (§4.1.2) | Composite | Aligned — interop rests on shared/compatible Context within a Session | Aligned (N:1) | -06 frames interop through Context compatibility rather than "reinterpretation by a practitioner," but the invariant is identical | Direct architectural support |
| SCHClet citation convention | "Using a SCHClet … with the following configuration/parameters/profiles: …" | Deployment Profiles (§5) declaring the Instance Configuration / Context extent | Profile-specific | Aligned | — | Editorial convention; -06 handles the same need via profile declaration | No architectural content |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Implied by "SCHClet Configuration" (subset of Full Configuration); not explicitly owned | Context is shared by two or more Instances; provisioned by the Context Repository/Domain Manager | Aligned | Draft's "SCHClet Configuration" Context part = an Instance's (possibly partial) Context; no conflict |
| Ownership of Set of Rules | Part of the SCHClet Configuration; a subset of the full SoR | SoR is the collection of Rules available to an Instance; may be a compatible subset (§6.2) | Aligned | Subset-SoR is explicitly permitted by -06; the draft's core simplification is natural |
| Ownership of Set of Variables (SoV) | Not mentioned by the draft | Per-Session runtime state owned per Session (§3; Appendix A.2.1) | Not applicable (draft silent) | For a stateless SCHClet (§5.3) the SoV is empty; for fragmentation SCHClets the SoV is per-Session as in -06 |
| Endpoint ↔ SCHC Instance | Draft: a SCHClet occupies "a single SCHC Instance"; "an endpoint may implement a single SCHClet" | Endpoint MAY host multiple Instances; each Instance independent (§4.2.1, §4.2.2.4) | Aligned | Draft describes the 1-Instance special case of -06's 1:N Endpoint↔Instance; no constraint violated |
| SCHC Instance ↔ Session | Not addressed by the draft | One Instance may serve multiple Sessions (Appendix A.2.1), or one Instance per Session | Not applicable (draft silent) | Draft neither asserts nor forbids; -06's flexibility is preserved |
| Sharing of Context between Sessions / Instances | Interop implies a shared/compatible Context across peers | Same Context shared across Instances; one Context may back many Sessions (Appendix A.2.1) | Aligned | Interoperability requirement = -06 shared/compatible Context |
| RuleID scope | 8-bit RuleID selecting a Rule within the SCHClet's Context (§5.3) | RuleID identifies a Rule within a Context; Datagram starts with RuleID (§4.2.5) | Aligned | Identical selector semantics; RuleID unique within a Context |
| Discriminator scope | MAY be omitted for a single-Instance SCHClet | Optional element used by the Dispatcher to route to an Instance; implicit when a single Instance (§4.2.2.4) | Aligned | Draft's omission = -06's implicit-Discriminator single-Instance case |
| Control Header ("SCHC Stratum Header") processing scope | "Always fully elided" for a single-Stratum SCHClet | Control Header presence/placement/format defined by profile; decodable before Context-dependent bits; absent when unneeded (§4.2.5.1) | Partial (terminology) | Draft's Stratum Header = -06 Control Header; elided-when-single-Stratum matches -06 |
| Domain membership and boundaries | Not addressed by the draft | Instances sharing a common set of Contexts form a Domain; IDs unique within a Domain (§4.1.2, §4.2.4) | Not applicable (draft silent) | Draft operates below Domain granularity; a SCHClet's Instance simply belongs to whatever Domain its deployment defines |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| SCHC Stratum Header | Direct → Control Header | The term is absent from -06; -06's Control Header multiplexes Session/Instance/Context but does not name "Stratum," and the draft asserts the header is "always fully elided," which is a property, not an identity. Claiming Direct would hide that -06 has no "Stratum Header" object. | **Partial** → Control Header (Multiplexing service) | The concept is expressible via the Control Header, but the mapping needs interpretation and a terminology note; it is not a clean one-to-one term. |
| SCHClet | Direct | Does -06's "combined within an Instance" framing contradict the draft's "an endpoint may implement a single SCHClet" (standalone) framing? Tested against multi-SCHClet composition and single-SCHClet minimal deployment. -06 permits a single minimal Instance (§4.2.2.4, Appendix A.2.1), so the standalone case is the 1-SCHClet-in-1-Instance instance of -06's model — compatible. | **Direct** (unchanged) | The framing difference is emphasis, not semantics; both readings live inside -06's Instance model. Retained as Direct, with the framing reconciliation flagged as a Trivial architecture clarification. |

Two mappings were re-examined; only *SCHC Stratum Header* changed classification (Direct → Partial).
The *SCHClet* mapping survived the adversarial pass as Direct. All Profile-specific mappings (Rule
Management omission; citation convention) survived: they are natural constraints/declarations that -06
already permits (RFC 9011 precedent, Deployment Profiles §5), not reinterpretations of an -06 concept.

## Architectural risk points

**Risk 1 — "SCHC Stratum Header" is an undefined, imported term.**
- **Why it matters:** The draft repeatedly treats *SCHC Stratum Header* as one of three canonical
  architecture notions, but -06 defines no such object; the nearest -06 concept is the Control Header.
  A reader aligning the two documents could wrongly conclude -06 is missing a concept.
- **Consequence for migration:** Requires a deliberate mapping decision (Stratum Header → Control
  Header) at every occurrence; drives the single Trivial architecture terminology note. It is not a
  purely mechanical replacement because the draft sometimes means "the header object" and sometimes
  "the multiplexing that is elided."

**Risk 2 — SCHClet as a *reduced Endpoint/Instance* vs a *subfunction within an Instance*.**
- **Why it matters:** -06 §4.2.2.3 defines a SCHClet strictly as a subfunction combined within an
  Instance. The draft's rhetoric ("an endpoint may implement a single SCHClet," "avoid deploying a
  full SCHC stack") can be read as a SCHClet *being* the (reduced) Instance/Endpoint. If left
  unreconciled, the two documents describe the SCHClet's architectural altitude differently.
- **Consequence for migration:** A one-time framing clarification is needed (a minimal deployment =
  one SCHClet hosted in one Instance). No technical behaviour changes; the risk is purely one of
  consistent architectural altitude.

**Risk 3 — Interoperability described as "practitioner reinterpretation" rather than Context
compatibility.**
- **Why it matters:** The draft grounds interop in a knowledgeable practitioner inferring the missing
  notions, whereas -06 grounds interop in a shared/compatible Context within a Session. Both reach the
  same invariant, but the draft's phrasing is informal and could obscure the actual technical
  requirement (compatible Contexts / Set of Rules).
- **Consequence for migration:** Migration should re-anchor the interop statements on -06's Context
  consistency (§6.2, Appendix A.3). This is a rewording, not a behavioural change.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §1, §3.1, §4, §4.1 (each "SCHC Stratum Header" occurrence) | "SCHC Stratum Header … always fully elided" | Rename to "Control Header" (per -06 §4.2.5.1) and state it is the Control Header's multiplexing role, elided when a single Stratum/Instance is used | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns an undefined imported term with the actual -06 concept; no behaviour change |
| 2 | §1 ("A SCHClet operates on a single Stratum and on a single SCHC Instance"), §4, §4.1 | SCHClet framed as possibly a standalone implementation | Add one clause stating that a SCHClet is a modular subfunction hosted within a single Instance, and that a minimal deployment may consist of a single such SCHClet | REQUIRED FOR TERMINOLOGY MIGRATION | Reconciles the draft's altitude with -06 §4.2.2.3 while preserving the "minimal deployment" intent |
| 3 | §3.1, §4 (interoperability paragraphs) | "these can be inferred by the knowledgeable SCHC practitioner … reinterpreted as a full SCHC implementation would" | Re-anchor on -06 Context consistency: interoperability holds because the SCHClet's Context/Set of Rules is compatible with the peer's, per -06 §6.2 and Appendix A.3 | REQUIRED FOR TERMINOLOGY MIGRATION | Ties the interop invariant to the -06 mechanism that actually guarantees it; keeps the same requirement |
| 4 | §2 Terminology (SCHClet, Full SCHC Implementation, Full/SCHClet Configuration) | Standalone definitions | Cross-reference -06: map SCHClet to -06 §4.2.2.3; express Full/SCHClet Configuration as (subset of) Instance Configuration + Context/Set of Rules | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the composite mapping explicit; avoids parallel vocabularies |
| 5 | §4.1 ("Proper configuration and negotiation mechanisms are essential") | Undefined "negotiation" | Clarify that -06 assumes static, pre-provisioned Contexts (no negotiation); provisioning is via the Domain/Context Repository, or note negotiation as out of scope | OPTIONAL CLARIFICATION | -06 §1 states no negotiation takes place; avoids implying a negotiation mechanism the architecture does not define |
| 6 | §5.1 Terminology usage | "CoDAs" / "CoDA" | Use "CDA" consistently with -06 §3 and RFC 8724 | EDITORIAL | Terminology consistency |
| 7 | §5.1 | "draft-ietf-IPsecme-diet-esp-05" (capitalisation) | Normalise to "draft-ietf-ipsecme-diet-esp" and cite as an informative reference | EDITORIAL | Reference hygiene |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §4.2.2.3 (SCHClets) | SCHClet as subfunction within an Instance | "A SCHClet … MAY be combined with other SCHClets within an Instance, as specified in the Instance Configuration." | Add a sentence stating the already-implied relationship explicitly: a minimal deployment MAY consist of a single SCHClet hosted in a single Instance operating on a single Stratum, in which case Instance selection is implicit and the Discriminator and Control Header MAY be elided (cross-ref §4.2.2.4). | ARCHITECTURE GAP (additive; no existing text changes meaning) | Makes -06 naturally express the draft's central claim without inferring it from three separate sections |
| 2 | §3 Terminology / §4.2.5.1 | Control Header | -06 defines Control Header (§4.2.5.1); "SCHC Stratum Header" does not appear | Add a one-line terminology note that the term "SCHC Stratum Header" used in [DRAFT-SCHCLET] corresponds to the Control Header defined here. | ARCHITECTURE GAP (additive terminology note) | Prevents the two documents from appearing to use disjoint vocabularies; closes the Partial mapping |
| 3 | §4.2.1.1 (Instance Configuration → SCHClets) | SCHClets as a selectable functionality | "SCHClets (modular subfunctions)" listed among required SCHC functionalities | (No change required) — already sufficient | OPTIONAL CLARIFICATION | Noted only to confirm this row is not a gap; -06 already lists SCHClets |

## Final migration assessment
- **Can the draft be migrated without changing technical behavior?** Yes — every change is
  terminology/framing; no protocol behaviour, wire format, or cardinality changes.
- **Can the migration be performed mechanically?** Mostly — the bulk is mechanical, but the "SCHC
  Stratum Header" → Control Header mapping and the SCHClet-altitude framing require limited,
  repeatable architectural judgement at a small number of locations.
- **Does the draft expose a SCHC Architecture -06 gap?** Yes, but only a **Trivial** one (two additive
  clarifications; no existing normative text changes meaning).
- **Is the gap required for this draft or merely useful generally?** Required for *this* draft to be
  expressed cleanly (the explicit single-SCHClet minimal-deployment relationship and the
  Stratum-Header ↔ Control-Header terminology note), and also generally useful.
- **What is the single most important migration issue?** Reconciling the draft's "SCHC Stratum Header,
  SCHC Instance, and Discriminator may be omitted" triad with -06's Control Header / Instance /
  Discriminator model — i.e. establishing that a single-SCHClet, single-Instance, single-Stratum
  deployment implicitly elides these, which is exactly what -06 already permits for single-Instance
  deployments.
