# Evidence Notes: draft-ietf-schc-protocol-numbers-06

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is representing the requested IANA protocol and port numbers as **Discriminators** that are processed by the **Dispatcher** to route incoming **SCHC Datagrams** to the appropriate **Instance** and **Context**. The principal migration difficulty is correcting minor terminology conflations in the draft, specifically renaming "SCHC Stratum Header" to outer **Discriminators** (and/or **Control Headers**) and resolving the conflated terms "session" and "instance". No SCHC Architecture -06 gaps exist, and no modifications to the architecture are required.

### Architectural risk points

- **Risk:** Terminology Conflation (Session vs. Instance vs. Endpoint)
  - **Why it matters:** The draft under study uses the phrase "SCHC session (called instance)" in Section 3.2 and conflates these concepts. In SCHC Architecture -06, an Endpoint is a logical entity hosting one or more Instances, and a Session is the communication relationship between Instances. Conflating them prevents proper implementation of multi-tenant or multi-interface nodes (like the uncrewed cargo aircraft mentioned in Section 3.1).
  - **Consequence for migration:** The draft's text in Sections 2, 3.2, 3.4, and 3.6 must be reframed to clearly separate the logical Endpoint, the Instances running on it, and the Sessions established between them.

- **Risk:** The "SCHC Stratum Header" Concept
  - **Why it matters:** The draft introduces the concept of a "SCHC Stratum Header" in Section 3.6 and claims its format includes the protocol/port numbers. This is technically incorrect because the protocol/port numbers are fields in the outer IP/UDP headers, not in a SCHC-specific header.
  - **Consequence for migration:** The draft must be revised to remove the "SCHC Stratum Header" terminology and instead describe the protocol and port numbers as outer **Discriminators** used by the **Dispatcher** to identify SCHC packets and route them to the appropriate **Instance**. Any actual SCHC-specific signaling should be referred to as a **Control Header**.

- **Risk:** RuleID Size Determination from IP Address
  - **Why it matters:** Section 4 states that an implementation should have a table mapping source IP addresses to RuleID sizes. This assumes that RuleID size is variable and dependent on the peer's IP address. However, in SCHC Architecture -06, the RuleID size is typically defined in the Context or the Instance Configuration.
  - **Consequence for migration:** The draft should clarify that this mapping table is a component of the **Instance Configuration** or **Context** metadata, ensuring it is managed within the SCHC -06 configuration framework.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3.6 | "In the current SCHC architecture, the SCHC Stratum Header adds signalling information... selects the correct instance and SoR..." | Rewrite to remove the concept of "SCHC Stratum Header" and replace it with outer **Discriminators** (the IP protocol or port numbers) processed by the **Dispatcher** to route to the correct **Instance** (which has an associated **Context** and **SoR**), and mention that any internal signaling can be carried in a **Control Header**. | REQUIRED FOR CONCEPTUAL ALIGNMENT | The draft's concept of a "SCHC Stratum Header" that includes outer protocol/port numbers is conceptually incorrect and violates the layered model of SCHC -06. |
| 2 | Section 4, Paragraph 2 | "An implementation should have a table of source IP address and RuleID size. The addresses should be represented in prefix format..." | Rewrite to: "An Instance Configuration or Context should associate the peer's IP address (or prefix) with the expected RuleID size to enable proper parsing of the SCHC Datagram." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Storing RuleID sizes in an ad-hoc table is outside the SCHC -06 architecture. It should be defined as metadata within the **Instance Configuration** or the **Context**. |
| 3 | Section 3.2, Paragraph 1 | "...the use of SCHC to compress the transported protocol, as well as the SCHC session (called instance) to use, are implicit. The MAC-Layer endpoints are preconfigured..." | Rewrite to: "...the use of SCHC to compress the transported protocol, as well as the SCHC Instance and Session to use, are implicit. The MAC-Layer Endpoints are preconfigured..." | REQUIRED FOR TERMINOLOGY MIGRATION | Align terminology with SCHC -06 by clearly distinguishing between **Endpoint**, **Instance**, and **Session**, and replacing "session (called instance)". |
| 4 | Section 3.3, Paragraph 1 | "...identifies the presence of a SCHC Stratum (defined in [schc-architecture]) atop UDP..." | Rewrite to: "...identifies that the payload of the UDP packet is a SCHC Datagram, which belongs to a Session operating on a specific Stratum (defined in [schc-architecture]) atop UDP..." | REQUIRED FOR TERMINOLOGY MIGRATION | A port number identifies the payload as a SCHC Datagram (serving as a Discriminator), not the presence of the Stratum itself. |
| 5 | Section 3.4, Paragraph 1 | "...both hosts must identify SCHC with the layer-4 port number and exchange and agree on the Set of Rules (SoR)." | Rewrite to: "...both Endpoints must identify SCHC using the layer-4 port number (acting as a Discriminator) and exchange and agree on the Context containing the Set of Rules (SoR)." | REQUIRED FOR TERMINOLOGY MIGRATION | The port number is a Discriminator. Agreeing on rules is part of Context provisioning/synchronization managed by the Domain/Instance Manager in SCHC -06. |
| 6 | Section 1, Paragraph 2 | "After applying SCHC, the protocol information is reduced to a RuleID and the compression residue (if any)." | Add a note clarifying that the resulting unit is a SCHC Datagram. | OPTIONAL CLARIFICATION | Makes the text explicit about the resulting architectural unit (SCHC Datagram). |
| 7 | Global / References | Reference to `[schc-architecture]` pointing to `draft-ietf-schc-architecture-05`. Typo "datgram" in Section 4. | Update reference `[schc-architecture]` to `draft-ietf-schc-architecture-06` and fix the typo. | EDITORIAL | Reference updates and typo fixes. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A
- What is the single most important migration issue? Replacing the confused "SCHC Stratum Header" concept with the clean architectural concepts of outer Discriminators and optional Control Headers.

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can **naturally express** the entire technical model of
draft-ietf-schc-protocol-numbers-06.

The draft does one architectural thing: it requests well-known code points (an IP Protocol
Number, an EtherType, transport port numbers, and a CCSDS/SANA IPE codepoint) whose purpose is to
let a receiver **recognize** that a data unit is SCHC-processed and to **route/select** the SCHC
processing that applies. In -06 vocabulary this is precisely the **Discriminator** consumed by the
**Dispatcher** to route a **Datagram** to the appropriate **Instance**. -06 not only defines this
mechanism, its Appendix A.2.3 already states that an EtherType/IP Protocol Number/UDP Port "serves
as the Discriminator" and references this very draft. The principal conceptual mapping is therefore
**identifier → Discriminator (Direct)**.

The principal migration difficulty is purely terminological and local: the draft (written against
architecture **-05**) uses "SCHC Stratum Header" for what -06 now calls the **Control Header**,
uses "session (called instance)" where -06 cleanly separates **Session** from **Instance**, and
describes connection-oriented SoR handling as "exchange and agree" (negotiation), whereas -06's
base model provisions/synchronizes Contexts rather than negotiating them in band. All three are
resolved by rewording a few sentences; none requires changing the draft's technical intent (with
the marginal exception of framing "agree on the SoR" as provisioning, flagged below).

There is **no Architecture gap**. Every concept the draft needs already exists in -06, and -06 was
evidently drafted with this document in mind. No modification to SCHC Architecture -06 is required.

### Architectural risk points

- **Risk:** The draft's "SCHC Stratum Header" reuses -06's defined term *Stratum* for a different
  structure (the Control Header) and simultaneously for the Discriminator role.
  - **Why it matters:** A reader cross-referencing -06 will find "Stratum" defined as a *background
    concept identifying a portion of the stack*, not a header; the draft's usage collides with that
    definition and blurs the Discriminator/Control-Header distinction that -06 is careful to make.
  - **Consequence for migration:** Requires deliberate re-wording (not a blind replace): the
    recognition/selection role → Discriminator; any in-band signalling attached to the Datagram →
    Control Header. Mechanical but needs judgment on which role is meant in each sentence.

- **Risk:** "exchange and agree on the Set of Rules" (§3.4) reads as in-band negotiation.
  - **Why it matters:** -06's base model explicitly excludes negotiation between the compressing and
    decompressing entities; presenting SoR agreement as negotiation could be read as contradicting
    the architecture's stated assumptions.
  - **Consequence for migration:** Frame the step as Context provisioning/synchronization (the YANG-
    based mechanism the draft already cites), which -06 supports. This is the one edit that lightly
    touches technical framing (classified REQUIRED FOR CONCEPTUAL ALIGNMENT), though the underlying
    behavior — both ends end up with the same SoR — is unchanged.

- **Risk:** Instance/Session conflation ("the SCHC session (called instance)").
  - **Why it matters:** -06 relies on the distinction to describe a server that serves many Sessions
    with one Instance/Context (A.2.1). Carrying the conflation forward would make later multi-peer
    statements ambiguous.
  - **Consequence for migration:** Disambiguate on a per-occurrence basis. Low effort, but not a
    single global substitution.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §3.4 | "both hosts must identify SCHC with the layer-4 port number and **exchange and agree on** the Set of Rules (SoR)" | "both Instances identify SCHC with the layer-4 port number (used as a Discriminator) and **provision and synchronize the Context (its Set of Rules, SoR)**" | REQUIRED FOR CONCEPTUAL ALIGNMENT | -06 base SCHC assumes no in-band negotiation; recast the "agree" step as provisioning/synchronization (the YANG mechanism the draft already cites), which -06 supports. Behavior (both ends share the same SoR) is preserved. |
| 2 | §3.6 (title + body), §3.2 | "SCHC Stratum Header" carrying the identifier; "selects the correct instance and SoR" | Split roles: the recognition/selection value is the **Discriminator**; any in-band signalling attached to the Datagram is the **Control Header**. Reword: "the Control Header adds signalling ... together with the Discriminator it helps to identify the use of SCHC and to select the correct **Instance** (and thereby its Context and SoR)." | REQUIRED FOR TERMINOLOGY MIGRATION | -06 reserves "Stratum" for a stack-portion concept and provides Discriminator + Control Header for these roles; avoids term collision. |
| 3 | §3.2 | "the SCHC **session (called instance)** to use, are implicit"; "signal both the use of SCHC and the SCHC **session** to be used" | "the SCHC **Instance** to use ... implicit"; "signal both the use of SCHC and the SCHC **Instance** (selected by the Discriminator) to be used" | REQUIRED FOR TERMINOLOGY MIGRATION | -06 distinguishes Instance from Session; the value that selects SCHC processing is the Discriminator, which routes to an Instance. |
| 4 | §3.3, §3.4, §4.2 wording; §3.6 | "endpoints (sender and receiver)", "two endpoints establish a session", "both hosts" | Use "Instances" (hosted on Endpoints) for the SCHC-processing peers; keep "hosts/nodes" for physical devices | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the actor vocabulary with -06's logical Endpoint / Instance / Session model. |
| 5 | §3.3, Abstract, Fig. 1 | "SCHC datagrams", "SCHC datagram", "SCHC instance establishment" | Capitalize -06 terms: "SCHC **Datagram**(s)", "SCHC **Instance** establishment" | REQUIRED FOR TERMINOLOGY MIGRATION | Consistent use of -06 defined terms. |
| 6 | §1, §3.6, §6 | "identify SCHC to recognise ...", "protocol number or port number", "port numbers are necessary to be aware that the protocol's header has been compressed" | Add a clause noting these values act as the -06 **Discriminator** consumed by the **Dispatcher** | OPTIONAL CLARIFICATION | Makes the architectural role explicit; not required for correctness. |
| 7 | §4 | "An implementation should have a table of source IP address and RuleID size." | Note this is Instance/Context-selection detail (Instance Configuration) | OPTIONAL CLARIFICATION | Situates an implementation detail within -06's model; behavior unchanged. |
| 8 | References; body citations | "[schc-architecture] ... draft-ietf-schc-architecture-**05**" | Update citation to **draft-ietf-schc-architecture-06** | EDITORIAL | The draft was written against -05; the "Stratum Header" wording predates -06's Control Header terminology. |
| 9 | §4 | "SCHC **datgram**" (typo) | "SCHC Datagram" | EDITORIAL | Spelling. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §3 (Terminology: Discriminator) / A.2.3 | Discriminator scope | "Discriminator: An optional information element used by the Dispatcher to route SCHC Datagrams to the appropriate Instance." A.2.3 already states an EtherType/IP-proto/UDP-port "serves as the Discriminator." | (Optional) Add one sentence noting a Discriminator MAY be a globally assigned, registry-allocated code point (e.g., an IANA IP Protocol Number / EtherType / port, or a CCSDS/SANA IPE codepoint), and that such values additionally serve to *recognize* that a unit is a SCHC Datagram. | OPTIONAL CLARIFICATION | Purely additive readability; -06 A.2.3 already conveys this, so it is **not** an architecture gap. Omitting it does not block migration. |

No ARCHITECTURE GAP items were identified. **No modification to SCHC Architecture -06 is required.**

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Mostly** — all edits are
  behavior-preserving except reframing §3.4 "agree on the SoR" as Context provisioning/
  synchronization (REQUIRED FOR CONCEPTUAL ALIGNMENT), which keeps the outcome (shared SoR) but
  aligns the wording with -06's no-in-band-negotiation assumption.
- Can the migration be performed mechanically? **Mostly** — most edits are local terminology
  substitutions; a few (Instance vs. Session disambiguation, Stratum Header → Discriminator/Control
  Header, the §3.4 reframing) require per-occurrence judgment.
- Does the draft expose a SCHC Architecture -06 gap? **No.**
- Is the gap required for this draft or merely useful generally? Not applicable — there is no gap;
  the single Architecture-side suggestion is an OPTIONAL CLARIFICATION already implied by A.2.3.
- What is the single most important migration issue? Disentangling the draft's "SCHC Stratum
  Header" into -06's **Discriminator** (recognition/selection, typically lower-layer-carried) and
  **Control Header** (optional in-band signalling), so the recognition role the whole draft is about
  is expressed with the -06 concept intended for it.
