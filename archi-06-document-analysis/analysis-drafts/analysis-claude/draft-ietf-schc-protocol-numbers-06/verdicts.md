# Architectural alignment review: draft-ietf-schc-protocol-numbers-06

## Verdicts
- Conceptual equivalence: **High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | The draft's "SCHC Stratum Header" reuses -06's *defined* term **Stratum** to name what -06 calls the **Control Header**, and it conflates Instance with Session ("the SCHC session (called instance)"). These are Misleading/Composite mappings that require explicit decomposition, not a pure rename, so the model is not expressible by a terminology swap alone — hence not Very High. | Every native concept (SCHC Datagram, RuleID, the recognition/identifier value, Instance, Session, Set of Rules, Stratum) maps onto an existing -06 concept. Decisively, -06 Appendix A.2.3 already casts *these exact identifiers* (EtherType, IP Protocol Number, UDP Port) as the **Discriminator**. No part of the draft's technical model is unexpressible, so it is well above Medium. |
| Transition difficulty | Easy | A small number of edits need architectural judgment — splitting Instance vs. Session, renaming "SCHC Stratum Header" to "Control Header", and reframing "exchange and agree on the SoR" as Context provisioning/synchronization — so it is not a pure mechanical find/replace, hence not Very Easy. | The affected text is a handful of sentences in a short (≈5 pages of technical content) draft; the mapping decisions are clear and repeatable, and no section requires redrafting — hence not Medium. |
| SCHC Architecture adaptation need | None | Highest grade | Not Trivial: no notion required by the draft is missing, implicit, or insufficiently explicit in -06. Discriminator, Dispatcher, Control Header, Datagram, RuleID, Instance, Session, and Stratum are all defined, and -06 A.2.3 already anticipates this draft by name and by mechanism. Zero ARCHITECTURE GAP items arise. |

## Executive assessment

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

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC datagram | RuleID + compression residue (if any) + payload; the SCHC-processed unit on the wire | Produced/consumed by the SCHC process on each node | Peer-pair (sender↔receiver) | RuleID leads the datagram | 1 datagram carries exactly 1 RuleID | Explicitly "SCHC datagram [schc-architecture]" (Fig. 1) |
| RuleID | Variable-size identifier of the compression Rule that applies | Selected by sender, matched by receiver | Per SCHC process / Context | Is itself the selector of a Rule | 1:1 with a Rule; size may vary per source-address group | May be statically configured (RFC 8724) or negotiated (IKEv2/Diet-ESP) |
| Compression residue | Remaining bits after fields are compressed | SCHC process | Peer-pair | — | Part of the datagram | — |
| Recognition identifier / "protocol number or port number" | A value that lets the receiver know a header was SCHC-compressed and demultiplex it to SCHC processing | Carried in the lower/enclosing layer (IP Next Header, EtherType, L4 port, CCSDS IPE) | Global (IANA/SANA-registered, well-known) | The code point itself | One code point per layer of use; shared by all SCHC users at that layer | The document's core deliverable |
| SCHC Stratum | The portion of the stack targeted by SCHC ("SCHC Stratum atop UDP") | Conceptual, per layer of application | Stack-portion / per Session | — | — | Term explicitly attributed to [schc-architecture] |
| SCHC Stratum Header | Signalling info added to the datagram; "identifies the use of SCHC and selects the correct instance and SoR"; may be fully compressed | Prepended/attached to the datagram | Peer-pair | Carries the layer-dependent identifier (proto number / port) | Optional; may be elided (fully compressed) | Described as part of "the current SCHC architecture" (i.e., -05) |
| SCHC instance / SCHC session | The SCHC processing state to use for a flow; used loosely/interchangeably ("the SCHC session (called instance)") | Endpoint / node | Peer-pair or session | Selected implicitly (LPWAN) or by signalling | Implicit single instance in LPWAN; multiple when signalled | Conflation of two notions -06 keeps distinct |
| Set of Rules (SoR) | The Rules shared by the two ends; in connection-oriented use, exchanged/agreed and managed via YANG | Both endpoints | Peer-pair / session | Referenced by RuleIDs it contains | Shared 1:N across a session's ends; may hold dedicated ACK/termination Rules | Managed per schc-coreconf-management (YANG) |
| Endpoints (sender / receiver; "MAC-layer endpoints"; hosts) | The two communicating parties running SCHC | Physical/logical nodes | Peer-pair | Node/link identity (e.g., DevEUI, address, port) | Typically two; a server/gateway may serve many peers | "endpoints (sender and receiver)" |
| Node / mobile node / network; SCHC Gateway; ground server | Devices that apply SCHC, possibly across changing links | Physical device or router | Node-local | Interface/link identity | One node may host several interfaces; a router aggregates several nodes | Use-case actors (UA, cargo aircraft, IoT device) |
| Connection-oriented session establishment | 3-way handshake in which both ends identify SCHC via L4 port and agree on the SoR; dedicated Rules for ACK/termination | Both endpoints | Session | L4 port number | 1 session per connection; both ends kept consistent | Section 3.4 |
| Layer-dependent identifier scheme | Which value identifies SCHC depends on where SCHC is applied (L3 protocol number, L2 EtherType, L4 port, CCSDS IPE) | Enclosing layer | Global (registries) | Code point per layer | N layers → N code points | Sections 3.6, 4–7 |

## Native architectural model

The draft is a code-point-allocation document. Its architectural content is thin and instrumental:
it exists so that SCHC can be *recognized* at several points in a protocol stack. In the draft's own
framing, "after applying SCHC, the protocol information is reduced to a RuleID and the compression
residue (if any)", and "we need to identify SCHC to recognise when a protocol header has been
compressed by SCHC." That recognition value "has to be unambiguous to ensure correct SCHC
processing at the receiver side; it could be a protocol number or port number."

The central actor set is minimal: two communicating parties (variously called nodes, hosts,
endpoints, sender/receiver, device/gateway/server) each running a SCHC process, exchanging SCHC
datagrams. The datagram model is inherited verbatim from RFC 8724 / the SCHC architecture: a RuleID
followed by a compression residue and payload.

The draft's key native concept is the **recognition identifier**, realized differently per layer:
an IP Protocol Number when SCHC sits directly on IP (so SCHC is independent of UDP/ESP), an EtherType
for native SCHC over IEEE 802 links, a UDP/TCP port when SCHC-compressed units (e.g., SCHC-compressed
CoAP) ride atop UDP, and a CCSDS IPE codepoint for space links. The motivating problem is
*demultiplexing*: with ESP the incoming SPI can be abused to imply SCHC, and DTLS offers no safe
equivalent, so a clean, explicit "this is SCHC" indicator at the enclosing layer is needed. This is,
in essence, a discriminator argument.

A second native concept is the **SCHC Stratum Header** (Section 3.6). The draft treats it as an
element of "the current SCHC architecture" that "adds signalling information to the SCHC datagram",
"may be fully compressed", "helps to identify the use of SCHC and selects the correct instance and
SoR", and whose "format includes an identifier that depends on the compressed stack layer" — the
protocol number at L3, the port at L4. This single sentence bundles two distinct roles: (a) an
identifier used to recognize/select SCHC processing (a discriminator role, typically carried in the
enclosing layer), and (b) optional in-band signalling attached to the datagram.

State in the draft is minimal and mostly inherited: RuleIDs and the SoR (statically configured per
RFC 8724, or negotiated as in IKEv2/Diet-ESP, or managed via YANG in the connection-oriented case).
The draft asserts an implementation "should have a table of source IP address and RuleID size",
i.e., the RuleID length used may depend on the source-address group — an implementation-selection
detail, not a new architectural relation.

Communication is described as point-to-point in the simplest cases (space links "are typically
point-to-point"; LPWAN "MAC-layer endpoints are preconfigured so there can be only one session"),
but the draft is explicit that richer cases exist: a router aggregating multiple Ethernet-connected
avionics nodes, and a server terminating many secure paths. The draft therefore does **not**
normatively assume one-instance/one-session; it assumes it only in the constrained LPWAN example and
argues that Ethernet/more-capable endpoints need explicit signalling of "both the use of SCHC and
the SCHC session to be used."

The connection-oriented case (Section 3.4) is the only place the draft leans toward negotiation:
"both hosts must identify SCHC with the layer-4 port number and exchange and agree on the Set of
Rules (SoR)", with "management of the SoR uses the Yang data model" and "both endpoints must make
the same changes." Even here, the described *mechanism* (YANG management, symmetric changes) is
provisioning/synchronization; only the word "agree" implies in-band negotiation.

Management and provisioning are left largely to references: RFC 8724 for static configuration,
IKEv2/Diet-ESP for negotiated RuleIDs, schc-coreconf-management for YANG-based SoR management. Trust
assumptions are inherited ("None additional over already noted in [RFC8724], [RFC8824] and
[schc-architecture]"). The draft therefore introduces no independent management or security model.

In short, the draft's native model is: two SCHC processes exchange RFC 8724 datagrams; a
layer-appropriate, registry-assigned code point recognizes SCHC and steers a unit to the right SCHC
processing; optional in-band signalling (the "Stratum Header") can further select the instance/SoR;
and SoR state is provisioned, negotiated, or managed by mechanisms defined elsewhere.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC datagram | RuleID + residue + payload | **Datagram** (§3, §4.2.5) | Direct | Peer-pair ↔ "unit exchanged between Instances" | 1:1 with RuleID in both | None | Same wire model (RFC 8724) |
| RuleID | Selector of the compression Rule | **RuleID** | Direct | Per Context in both | 1:1 with a Rule | None | Variable size in both |
| Compression residue | Post-compression bits | Result of the SCHC operation within a **Datagram** | Direct | Peer-pair | Part of Datagram | None | — |
| Recognition identifier (proto number / EtherType / port / IPE codepoint) | Value that recognizes SCHC and steers demux | **Discriminator** (consumed by **Dispatcher**) | Direct | Global (registry) value used as external Discriminator — permitted by -06 A.2.3 | One per layer; many users share it | -06 also lets the Discriminator be *derived* from lower-layer context; the draft supplies a globally-assigned value for that role | -06 A.2.3 already names EtherType/IP-proto/UDP-port as the Discriminator and cites this draft |
| SCHC Stratum | Portion of stack targeted by SCHC | **Stratum** (§3 terminology; also an interception criterion in Instance Configuration §4.2.1.1) | Direct | Stack-portion in both | — | None | Term used identically |
| SCHC Stratum Header | In-band signalling attached to datagram that identifies SCHC and selects instance/SoR; may be fully compressed | **Discriminator** (identify/select) **+ Control Header** (§4.2.5.1: multiplexing of Session/Instance/Context, may itself be SCHC-compressed) | Composite | Peer-pair | Optional in both | The draft's *name* reuses -06's term "Stratum" for a different structure (the Control Header); its "identifier" role is really the Discriminator | Renaming to Control Header + Discriminator makes it Direct-per-part |
| SCHC instance / SCHC session | SCHC processing state / flow, used interchangeably | **Instance** and **Session** (kept distinct in §4.2.1, §4.2.3) | Composite | Both scoped within a Domain in -06 | Draft's "one session/instance" (LPWAN) = -06 one Instance + implicit Session | Draft conflates two distinct -06 notions | Disambiguation required, but both meanings exist in -06 |
| Set of Rules (SoR) | Shared Rules; may be agreed/managed | **Set of Rules** inside a **Context** | Direct (state); the "agree" step → **Context** provisioning/synchronization via **Domain Manager**/management | Partial (for the "agree" step) | Peer-pair / session | Shared across a session's ends | -06's base model provisions/synchronizes rather than negotiates in band | "agree on the SoR" is the one phrase implying negotiation |
| Endpoints / hosts / sender-receiver / MAC-layer endpoints | The two communicating parties | **Instance**(s) hosted on **Endpoint**(s), communicating in a **Session** | Composite | -06 Endpoint is logical (a device may host several) | Two ends; a server may serve many peers via one or many Instances (-06 A.2.1 Table 1/2) | Draft's "endpoint" ≈ device/host; -06 Endpoint is a logical SCHC entity | Terminology-level distinction |
| Node / mobile node / router / gateway / server | Physical actors applying SCHC | Physical equipment hosting one or more **Endpoints** | Direct | Node-local | One device → several Endpoints/Instances allowed in -06 | -06 explicitly separates logical Endpoint from physical device | Matches -06 §4.2.2 |
| Connection-oriented session establishment (3-way handshake; agree SoR; ACK/termination Rules) | Reliable connection setup with SoR agreement | **Session** setup + **Context** synchronization (management/YANG); ACK/termination Rules are ordinary **Rules** in the **SoR** | Profile-specific / Partial | Session | 1 Session per connection | -06 base SCHC "assumes ... no negotiation"; management-driven sync is in scope, in-band negotiation is future/other-doc | Draft defers to schc-coreconf-management; consistent with -06's management framing |
| RuleID-size-per-source-address table | Implementation selects RuleID length by source-address group | Implementation/profile detail within **Instance Configuration** / **Context** selection | Profile-specific | Instance-local | N address-groups → RuleID sizes | Not an architectural relation | §4 of the draft |
| Layer-dependent identifier scheme (L2/L3/L4/CCSDS) | Which value recognizes SCHC depends on layer | Multiple **Discriminator** realizations across **Strata** | Direct | Global per layer | N layers → N code points | None | -06 A.2.3 enumerates the same set |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Both ends share the SoR (implicitly/via YANG); not owned by a named entity | Context owned/synchronized by the **Domain Manager**; shared by ≥2 Instances | Aligned (draft is silent on the owner; -06 supplies one) | Draft can adopt -06's ownership without conflict |
| Ownership of Set of Rules | SoR belongs to the pair; may carry dedicated ACK/termination Rules | SoR is the rule content of a **Context** held by an Instance | Aligned | Direct |
| Ownership of Set of Variables (SoV) | Not mentioned | Per-Session runtime state (SoV) | Not applicable (draft raises no SoV) | No effect |
| Endpoint ↔ SCHC Instance | Draft uses "endpoint"/"node" loosely; an Instance is implied per SCHC process | One Endpoint MAY host several Instances | Aligned; draft never precludes multiple Instances | Draft's "endpoint" should be read as Endpoint hosting Instance(s) |
| SCHC Instance ↔ Session | Conflated ("session (called instance)") | Distinct: a Session is communication among Instances sharing a Context; one Instance may serve many Sessions | Misaligned in wording, not in substance | Requires disambiguation (terminology migration) |
| Sharing of Context between Sessions/Instances | LPWAN: one; Ethernet/server: many peers, implicitly shareable | Explicitly supported (A.2.1: one shared Instance/Context across many Sessions; per-Session SoV) | Aligned; -06 is more explicit | Draft's multi-peer server case is natively expressible |
| RuleID scope | Per Context; size may vary per source-address group | Per Context; a Datagram starts with a RuleID that indexes a Rule | Aligned | Direct |
| Discriminator scope | Globally assigned, well-known code point (IANA/SANA); the same value recognizes SCHC everywhere | Discriminator may be a lower-layer value (address/port/EtherType) or an explicit field; -06 does not require it to be Domain-scoped | Aligned | -06 treats externally-scoped Discriminators as normal (A.2.3); the draft simply standardizes the value |
| Control Header processing scope | "Stratum Header" may be fully compressed; carries the identifier | Control Header decodable independently of the C/D-or-F/R Rule; may itself be SCHC-compressed | Aligned once "Stratum Header" is renamed to Control Header | Direct-per-part |
| Domain membership and boundaries | Not addressed | Domain groups Instances sharing Contexts; identifiers unique within a Domain | Not applicable (draft raises no Domain) | No effect; draft is Domain-agnostic |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| SCHC Stratum Header | Direct → Control Header | The draft says its "identifier" *is* the protocol number (L3) / port (L4) — values carried in the **enclosing** layer, not inside a SCHC header. So the "Stratum Header" bundles a Discriminator role (recognize/select, lower-layer-carried) with an optional in-band signalling role (Control Header). Mapping it to Control Header alone hides the Discriminator role. | Composite → **Discriminator + Control Header** | Preserves both roles; avoids overloading the Control Header with the recognition function that -06 assigns to the Discriminator. |
| SoR "exchange and agree" (§3.4) | Direct → Set of Rules | -06 states base SCHC "assumes ... no negotiation ... between the compressing and decompressing entities." In-band peer negotiation is not part of -06's base model; -06 handles Context change via provisioning/synchronization (Domain Manager, on-demand fetch, management). | **Partial / Profile-specific** (Context provisioning & synchronization) | The *mechanism* the draft actually cites (YANG management, symmetric changes) is provisioning/sync, which -06 supports; only the word "agree" overreaches, so this is Partial, not Direct. |

All other Direct and Profile-specific mappings survived the adversarial pass unchanged. In
particular, the **identifier → Discriminator** mapping was tested against multi-Instance, multi-
Session-sharing-one-Context, and multi-Domain deployments and holds: -06 explicitly permits a
lower-layer/externally-assigned value as the Discriminator (A.2.3) and permits many Sessions to
share one Context/Instance (A.2.1).

## Architectural risk points

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

## Needed modifications to the draft under study

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

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §3 (Terminology: Discriminator) / A.2.3 | Discriminator scope | "Discriminator: An optional information element used by the Dispatcher to route SCHC Datagrams to the appropriate Instance." A.2.3 already states an EtherType/IP-proto/UDP-port "serves as the Discriminator." | (Optional) Add one sentence noting a Discriminator MAY be a globally assigned, registry-allocated code point (e.g., an IANA IP Protocol Number / EtherType / port, or a CCSDS/SANA IPE codepoint), and that such values additionally serve to *recognize* that a unit is a SCHC Datagram. | OPTIONAL CLARIFICATION | Purely additive readability; -06 A.2.3 already conveys this, so it is **not** an architecture gap. Omitting it does not block migration. |

No ARCHITECTURE GAP items were identified. **No modification to SCHC Architecture -06 is required.**

## Final migration assessment
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
