# Evidence Notes: draft-ietf-schc-schclet-00

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is the direct match between the draft's "SCHClet" and the architecture's "SCHClet" component, which operates within a single Instance. The principal migration difficulty lies in clarifying the relationship between SCHClets and Instances (specifically correcting a sentence that refers to an Instance itself being defined as a SCHClet) and aligning configuration terminology (mapping "SCHClet Configuration" to subsets of Context and Instance Configuration). No SCHC Architecture gap exists, as all simplifying assumptions (elided headers, lack of discriminators, and static provisioning) are native features of the -06 model.

### Architectural risk points

- **Risk 1: Ambiguity of the term "SCHC Stratum Instance"**
  - **Why it matters**: Mixing up "Instance" and "SCHClet" in the hierarchy can lead to implementation confusion about which component owns the lifecycle, Context, and configurations.
  - **Consequence for migration**: Text in Section 4.1 must be rewritten to align with the -06 hierarchy (where Instances contain SCHClets).
- **Risk 2: Ambiguity in the mapping of "SCHClet Configuration"**
  - **Why it matters**: A SCHClet's configuration contains both static rules (Context) and runtime parameters (Instance Configuration). If a specification is not clear about which parameters belong to the shared Context versus the local Instance Configuration, interoperability could be broken (e.g., if one end assumes a parameter is local, while the other assumes it is part of the shared Context).
  - **Consequence for migration**: The definition of "SCHClet Configuration" in Section 2 must be aligned to explicitly state that it encompasses subsets of both the Context and the Instance Configuration.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4.1, paragraph 2 (lines 307-310) | "While not recommended, a SCHC Stratum Instance MAY be defined as a SCHClet, and combined with other SCHClets to achieve the functionality of a complete SCHC Stratum implementation." | "While not recommended, a SCHC Instance operating on a specific Stratum MAY be implemented using a single SCHClet, or combined with other SCHClets to achieve the functionality of a complete SCHC Instance." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Corrects the hierarchical relationship. In -06, an Instance hosts SCHClets, so an Instance cannot be defined *as* a SCHClet. Instead, an Instance can be composed of or implemented by SCHClets. |
| 2 | Section 2 (Terminology - Full Configuration) | "Full SCHC Implementation Configuration (Full Configuration): The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation." | "Full SCHC Implementation Configuration (Full Configuration): The union of the Context (including Set of Rules) and the Instance Configuration supported by a Full SCHC Implementation." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the definition with the architecture's terms of Context and Instance Configuration. |
| 3 | Section 2 (Terminology - SCHClet Configuration) | "SCHClet Configuration: A subset of a Full Configuration, which are implemented and supported by a given SCHClet. This may be a single SCHC Profile, or a set of such." | "SCHClet Configuration: A subset of the Context (including Rules) and/or Instance Configuration that is implemented and supported by a given SCHClet. This may be a single SCHC Profile, or a set of such." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the definition of "SCHClet Configuration" with the architecture's concepts of Context and Instance Configuration. |
| 4 | Section 1, paragraph 5 (line 136) | "In addition, the SCHC Architecture introduces the notions of SCHC Stratum Header..." | "In addition, the SCHC Architecture [I-D.ietf-schc-architecture] introduces the notions of SCHC Stratum Header..." | EDITORIAL | Adds explicit citation to the SCHC Architecture document. |
| 5 | Section 8 (Normative References) | Missing reference to `draft-ietf-schc-architecture-06`. | Add normative reference to `[I-D.ietf-schc-architecture]`. | EDITORIAL | Includes the reference architecture in the normative references section. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable**
- What is the single most important migration issue? **Aligning the terminology of configuration and hierarchy (specifically the relationship between SCHClets and Instances) to match the architecture's definitions.**

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'Trivial'}

### Executive assessment

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

### Architectural risk points

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

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §1, §3.1, §4, §4.1 (each "SCHC Stratum Header" occurrence) | "SCHC Stratum Header … always fully elided" | Rename to "Control Header" (per -06 §4.2.5.1) and state it is the Control Header's multiplexing role, elided when a single Stratum/Instance is used | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns an undefined imported term with the actual -06 concept; no behaviour change |
| 2 | §1 ("A SCHClet operates on a single Stratum and on a single SCHC Instance"), §4, §4.1 | SCHClet framed as possibly a standalone implementation | Add one clause stating that a SCHClet is a modular subfunction hosted within a single Instance, and that a minimal deployment may consist of a single such SCHClet | REQUIRED FOR TERMINOLOGY MIGRATION | Reconciles the draft's altitude with -06 §4.2.2.3 while preserving the "minimal deployment" intent |
| 3 | §3.1, §4 (interoperability paragraphs) | "these can be inferred by the knowledgeable SCHC practitioner … reinterpreted as a full SCHC implementation would" | Re-anchor on -06 Context consistency: interoperability holds because the SCHClet's Context/Set of Rules is compatible with the peer's, per -06 §6.2 and Appendix A.3 | REQUIRED FOR TERMINOLOGY MIGRATION | Ties the interop invariant to the -06 mechanism that actually guarantees it; keeps the same requirement |
| 4 | §2 Terminology (SCHClet, Full SCHC Implementation, Full/SCHClet Configuration) | Standalone definitions | Cross-reference -06: map SCHClet to -06 §4.2.2.3; express Full/SCHClet Configuration as (subset of) Instance Configuration + Context/Set of Rules | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the composite mapping explicit; avoids parallel vocabularies |
| 5 | §4.1 ("Proper configuration and negotiation mechanisms are essential") | Undefined "negotiation" | Clarify that -06 assumes static, pre-provisioned Contexts (no negotiation); provisioning is via the Domain/Context Repository, or note negotiation as out of scope | OPTIONAL CLARIFICATION | -06 §1 states no negotiation takes place; avoids implying a negotiation mechanism the architecture does not define |
| 6 | §5.1 Terminology usage | "CoDAs" / "CoDA" | Use "CDA" consistently with -06 §3 and RFC 8724 | EDITORIAL | Terminology consistency |
| 7 | §5.1 | "draft-ietf-IPsecme-diet-esp-05" (capitalisation) | Normalise to "draft-ietf-ipsecme-diet-esp" and cite as an informative reference | EDITORIAL | Reference hygiene |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §4.2.2.3 (SCHClets) | SCHClet as subfunction within an Instance | "A SCHClet … MAY be combined with other SCHClets within an Instance, as specified in the Instance Configuration." | Add a sentence stating the already-implied relationship explicitly: a minimal deployment MAY consist of a single SCHClet hosted in a single Instance operating on a single Stratum, in which case Instance selection is implicit and the Discriminator and Control Header MAY be elided (cross-ref §4.2.2.4). | ARCHITECTURE GAP (additive; no existing text changes meaning) | Makes -06 naturally express the draft's central claim without inferring it from three separate sections |
| 2 | §3 Terminology / §4.2.5.1 | Control Header | -06 defines Control Header (§4.2.5.1); "SCHC Stratum Header" does not appear | Add a one-line terminology note that the term "SCHC Stratum Header" used in [DRAFT-SCHCLET] corresponds to the Control Header defined here. | ARCHITECTURE GAP (additive terminology note) | Prevents the two documents from appearing to use disjoint vocabularies; closes the Partial mapping |
| 3 | §4.2.1.1 (Instance Configuration → SCHClets) | SCHClets as a selectable functionality | "SCHClets (modular subfunctions)" listed among required SCHC functionalities | (No change required) — already sufficient | OPTIONAL CLARIFICATION | Noted only to confirm this row is not a gap; -06 already lists SCHClets |

### Final migration assessment

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
