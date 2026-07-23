# Architectural alignment review: draft-ietf-schc-over-ppp-00

## Verdicts
- Conceptual equivalence: **Very High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | Every native concept of the draft maps to a -06 concept with the same semantics: the PPP virtual link → Session; each peer node → Endpoint hosting one Instance; the per-session SCHC context and its set of Rules → Context/SoR; C/D and F/R → C/D and F/R; RuleID and Compression Residue are shared verbatim; PPP demultiplexing → Dispatcher/Discriminator; "initiator = downstream = device" → the -06 role convention (§4.2.1.1) *word-for-word*. -06 even carries a worked PPP deployment (Appendix A.2.2) built from this very draft. No concept requires reinterpretation, so nothing pulls it below Very High. |
| Transition difficulty | Easy | The migration is not a pure token replacement: five locations (Section 3 virtual-link sentence, the asymmetry/role sentence, Section 4.1 endpoint description, the C/D obligation, the asymmetric-context paragraph) must be re-framed to make the Session / Instance / Context distinction explicit, which is more than mechanical substitution. | The re-framing decisions are clear and repeatable because -06 §4.2.1.1 and Appendix A.2.2 supply the exact target wording; the bulk of the draft (Section 4.2 profile parameters: RuleID numbering, No-ACK mode, padding, MAX_PACKET_SIZE) needs no conceptual change. The old model is not deeply embedded, so it is well short of Difficult. |
| SCHC Architecture adaptation need | None | Highest grade (fewest changes) | Zero ARCHITECTURE GAP items. Every notion the draft needs — peer-to-peer operation, one Instance per link, Context fetched on demand, the initiator-plays-Device role convention, Discriminator derived from a lower-layer link, optional F/R — is already present and sufficiently defined in -06. The URI-based rule-set signaling and the profile parameters are profile-specific uses of mechanisms -06 already permits, not architecture changes. |

## Executive assessment

SCHC Architecture -06 can **naturally and completely express** draft-ietf-schc-over-ppp-00. The
draft describes a two-peer, point-to-point (peer-to-peer) SCHC deployment in which a PPP session
establishes a virtual link, a SCHC context with a particular set of Rules is provisioned on both
ends (its URI signaled through an IPV6CP option extended from RFC 5172), both peers run SCHC
Compression/Decompression, optional No-ACK fragmentation is available, and — when Rules are
asymmetric — the session initiator takes the Device role.

The principal conceptual mapping is: **PPP session → SCHC Session; each peer node → Endpoint with
one Instance bound to the PPP connection; per-session SCHC context + set of Rules → Context/SoR;
PPP protocol demultiplexing → Dispatcher using the PPP connection as Discriminator; initiator =
Device → the -06 role convention.** This mapping is not merely plausible — SCHC Architecture -06
already documents it as its own PPP deployment example (Appendix A.2.2, Table 3), citing this
draft directly.

The principal migration difficulty is purely presentational: the draft (written against the older
`draft-pelov-lpwan-architecture-02`) treats "a SCHC context per PPP session" as a single notion,
whereas -06 factors it into Session (the communication), Instance (the processing) and
Context/SoR (the shared state). Making that factoring explicit requires local rewording in a
handful of sentences, plus updating the architecture citation. No technical behavior changes.

**No Architecture gap exists.** The adaptation verdict is None; File 2 therefore states that no
change to -06 is required, and because conceptual equivalence is Very High and transition is Easy,
a complete terminology-migration diff is provided in File 3.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| PPP session / "virtual link" | A PPP session defines a virtual link over which a SCHC context is established with a particular set of Rules (§3) | The PPP layer between the two peers | Peer-pair / link | PPPoE Session ID at the PPPoE layer; the PPP connection itself | 1 SCHC context per PPP session; 2 peers per session | The carrier of SCHC operation; conceptually a communication relationship, not a node |
| SCHC context | State (set of Rules) provisioned on both ends before operation; may be per-application and asymmetric (§3, §4.1) | Both peer nodes | Peer-pair (per PPP session) | Indicated by URI at session setup | 1 context per PPP session; may be generated per upper-layer application | Draft treats "context" and "set of Rules" as tightly coupled |
| Set of Rules | The Rules that populate the context, referenced by a URI (§3) | Both peer nodes | Peer-pair | URI (RFC 3986); default YANG/JSON SCHC Data Model | One set per context/session | Fetched/located via URI carried in IPV6CP option |
| endpoint / end point | A node terminating SCHC: an IP Host (+ serial DTE) on one side; an IP Node — IP Host or Router — (+ serial DCE) or Ethernet device on the other (§4.1) | Physical/logical node | Node-local | Node identity (MAC, IP) | 2 endpoints per link; each MUST run C/D | Draft's "endpoint" denotes the node, described partly physically |
| SCHC Compressor/Decompressor (C/D) | Function performing header compression/decompression (§4.1, Fig 2, Fig 5) | Each endpoint | Node-local, applied per session | — | Mandatory on both endpoints | Same as RFC 8724 C/D |
| SCHC Fragmenter/Reassembler (F/R) | Optional function; used to obtain a small protocol-independent frame size (§4.1, §4.2) | Each endpoint | Node-local, applied per session | RuleID (fragmentation, 4 bits all-1) | Optional; No-ACK mode only | Not usually needed since MTU is large |
| RuleID (compression) | 2-byte identifier of a compression Rule; top 2 bits = 0, 14 bits index (§4.2) | Rule/Context | Per-context (peer-pair) | RuleID value | Selects one Rule within the context | Profile fixes size/format |
| RuleID (fragmentation) | 4-bit all-ones value marking a No-ACK fragmentation Rule (§4.2) | Rule/Context | Per-context | Fixed value 1111 | One fragmentation Rule in No-ACK | Profile-defined encoding |
| Compression Residue | Bits carried after the RuleID for non-elided fields (§4.2, Fig 3, Fig 6) | On the wire | Per-datagram | — | Follows RuleID | RFC 8724 term; must be L2-word aligned |
| IPV6CP signaling (IPv6-Compression-Protocol Configuration option) | RFC 5172 IPV6CP option (type 2) extended to signal SCHC and carry rule-set URI (§3) | PPP/IPV6CP control plane | Link setup | IPv6-Compression-Protocol value (new "SCHC" = 4) | One negotiation per PPP session | Provisioning/discovery mechanism |
| URI of the set of rules | Locator of the rule set carried in the option data; default YANG/JSON (§3) | Control plane → both nodes | Peer-pair | URI | One per session | How context content is obtained ("on demand") |
| Asymmetric context / role (initiator = downstream = Device) | If encoding is asymmetric, the session initiator is downstream and plays the Device role (§3, §4.1) | Both nodes / the relationship | Session | Determined by who initiates | 1 initiator (Device) + 1 responder per session | Directly matches -06's role convention |
| No-ACK fragmentation mode + Fragment Header | Only No-ACK supported; 2-byte header, DTag T=11, FCN N=1, no W (§4.2) | F/R function | Per-context | Fragmentation RuleID | Single mode | Profile parameter set |
| MAX_PACKET_SIZE | Aligned to PPP Link MTU (§4.2) | Profile | Per-link | — | One value per deployment | Profile parameter |
| Padding / L2-word alignment | Residue padded to the L2 word (1 byte for Ethernet); pad bit 0 (§4.2) | Profile | Per-datagram | — | — | Profile parameter |
| PPP protocol demultiplexing | PPP Protocol field (IPv6 = 0x0057), EtherType 0x8864, PPPoE Session ID identify/carry the flow (§4.2.1, Fig 6) | PPP/PPPoE layers | Link | PPP Protocol / EtherType / Session ID | Demultiplexes SCHC traffic on the link | Lower-layer selection of the SCHC flow |
| SCHC Data Model (YANG/JSON) | Default format of the rule set referenced by the URI (§3) | Context metadata | Peer-pair | — | One model per context | RFC 9363 / draft YANG model |

## Native architectural model

The draft is a short technology-profile document. Its purpose is narrow: extend RFC 5172 so that
"SCHC" can be signaled as an IPv6 datagram-compression method on a PPP link, and — combined with
PPPoE (RFC 2516) — over Ethernet and Wi-Fi. Everything else in the draft is the profile
information that Appendix D of RFC 8724 requires a technology document to supply.

The central organizing object is the **PPP session**, which the draft calls a "virtual link."
When a PPP session is set up, a **SCHC context** with a **particular set of Rules** is established
across it. The draft therefore ties SCHC state to the communication relationship (the link)
rather than to a node: the context lives "on both ends" and exists for the life of the session.

The two participants are called **endpoints**. The draft describes them partly in physical/serial
terms (an IP Host and possibly a serial DTE on one side; an IP Node — an IP Host or a Router — and
possibly a serial DCE, or a modern Ethernet device, on the other). Both endpoints MUST run the
SCHC **Compressor/Decompressor (C/D)**. The SCHC **Fragmenter/Reassembler (F/R)** is optional and
expected to be rarely needed, because serial/Ethernet MTUs are large; its stated use is to obtain
a *small, protocol-independent* frame size for deterministic scheduling (DetNet/TSN), transporting
one PDU as N fragments.

Provisioning is explicit and control-plane-driven, which distinguishes this draft from classic
LPWAN pre-provisioning. The draft extends the RFC 5172 **IPv6-Compression-Protocol Configuration
option** (an IPV6CP option) with a new value for SCHC, and uses the option's data field to carry a
**URI** that points at the **set of Rules**. The default rule-set format is the SCHC YANG Data
Model encoded in JSON. Thus the context content is discovered/fetched at session establishment
rather than being assumed present a priori.

The draft explicitly contemplates **asymmetric** operation. If the encoding is asymmetric, "the
initiator of the session is considered downstream, playing the role of the device in an LPWAN
network." It also motivates asymmetry by upper-layer relationships — primary/secondary, client/
server, PLC/sensor-or-actuator. This is a role assignment tied to who initiates the session.

The remaining substance is a conventional **SCHC profile**: the compression RuleID is 2 bytes with
the top two bits forced to 0 (14 usable bits); the compressed packet is RuleID + Compression
Residue + Payload, byte-aligned. Fragmentation, when used, is restricted to **No-ACK mode** with a
2-byte header (DTag T=11, FCN N=1, no W field), and the draft notes No-ACK assumes in-order
delivery, hinting a DetNet PREOF reorder function may be required. MAX_PACKET_SIZE tracks the PPP
Link MTU; the Compression Residue is padded to the L2 word (one byte for Ethernet) with zero bits.

Demultiplexing is handled entirely by the lower layers: on the wire the SCHC datagram is preceded
by the PPP Protocol field (IPv6 = 0x0057) inside a PPPoE/Ethernet frame (EtherType 0x8864, a PPPoE
Session ID). The draft does not define any SCHC-level multiplexing header, session identifier, or
control field of its own — the PPP/PPPoE encapsulation performs that role.

State ownership is stated only loosely. The draft does not enumerate multiple Instances, multiple
Sessions per node, Domains, or a Set of Variables; it works implicitly with exactly one SCHC flow
per PPP session and one context per that flow. Security is handled by inheritance: the draft simply
inherits RFC 8724's SCHC threat considerations and adds nothing structural.

Taken together, the native model is a **single, point-to-point, peer-to-peer SCHC association per
PPP link, with control-plane rule-set discovery and an initiator-based role convention** — a clean,
minimal instance of a general SCHC deployment.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| PPP session / "virtual link" | Virtual link carrying one SCHC context | **Session** (communication between Instances sharing a Context), realized over the PPP link | Composite | Aligned — both peer-pair/session scope | Aligned — 2 Instances per Session | Draft bundles "link + context + processing"; -06 factors this into Session + Instance + Context | -06 A.2.2: "each Endpoint associates one Instance with each PPP connection" |
| SCHC context (per session) | Provisioned state (set of Rules) on both ends | **Context** (SoR + metadata), shared by the two Instances | Direct | Aligned — shared across the Session | Aligned — 1 Context per Session | -06 separates Context (SoR + metadata) from SoR; draft conflates them but compatibly | Metadata (Parser/Data Model) present via the YANG default |
| Set of Rules | Rules referenced by URI | **Set of Rules (SoR)** | Direct | Aligned | Aligned — one SoR per Context | None | -06 term identical in intent |
| endpoint / end point (node) | Node terminating SCHC (Host/Router/Ethernet dev) | **Endpoint** hosting one **Instance** | Composite | Aligned — Endpoint is node-local, logical | Aligned — 1 Instance per PPP connection per Endpoint | Draft describes the node partly physically; -06 Endpoint is explicitly logical (may share equipment) | -06 A.2.2 Table 3: "Endpoint: 1 per peer; Instance: 1 per PPP connection, per Endpoint" |
| SCHC C/D | Header compression/decompression | **C/D** function of the Instance | Direct | Aligned | Mandatory both sides | None | Identical to RFC 8724 |
| SCHC F/R | Optional fragmentation for small frames | **F/R** function of the Instance | Direct | Aligned | Optional | None | -06 states F/R optional, mode fixed by profile |
| RuleID (compression) | 2-byte, top 2 bits 0 | **RuleID** | Direct | Per-Context, aligned | Selects one Rule | None (profile fixes size) | -06 Datagram starts with RuleID |
| RuleID (fragmentation) | 4-bit all-ones, No-ACK | **RuleID** (F/R Rule) | Direct | Per-Context | One F/R Rule | None | Profile constraint, allowed by -06 |
| Compression Residue | Post-RuleID residue bits | **Compression residue** within the **Datagram** | Direct | Per-datagram | — | None | -06 Datagram = RuleID + result (residue/fragment) + payload |
| IPV6CP signaling option | RFC 5172 option extended to signal SCHC + URI | **Context provisioning / "Context fetched on demand"** (management plane); a profile-specific signaling mechanism | Profile-specific | Aligned — link-setup provisioning | One negotiation per Session | -06 does not define this signaling but explicitly permits on-demand Context fetch | Natural use of -06's provisioning model, not an architectural element |
| URI of the set of rules | Locator for the SoR | **Context Repository reference / on-demand Context retrieval** | Profile-specific | Aligned | One per Session | -06 leaves the retrieval mechanism open | A.2.2: "the Context can be fetched on demand" |
| Asymmetric context / initiator = Device | Session initiator is downstream, plays Device role | **Instance Role** + the -06 convention: the Instance initiating the connection plays the Device role (§4.2.1.1) | Direct | Aligned — Session scope | Aligned — 1 initiator + 1 responder | -06 generalizes "Device" beyond LPWAN and uses Upside/Downside roles; draft says "device in an LPWAN network" | Near-verbatim match; only the "LPWAN" qualifier needs generalizing |
| No-ACK mode + Fragment Header | Single fragmentation mode + header layout | **F/R mode fixed by profile** (RFC 8724 No-ACK) | Profile-specific | Per-Context | Single mode | None | -06 §4.2.2.2: mode "typically fixed by the deployment or by a technology-specific profile" |
| MAX_PACKET_SIZE | Aligned to PPP MTU | **Profile parameter** | Profile-specific | Per-link | One value | None | Appendix D of RFC 8724 parameter |
| Padding / L2-word alignment | Residue padded to L2 word | **Profile parameter** | Profile-specific | Per-datagram | — | None | Profile-level framing constraint |
| PPP protocol demultiplexing | PPP Protocol / EtherType / PPPoE Session ID select the flow | **Dispatcher** using the PPP connection as **Discriminator** | Composite | Aligned — link scope | Aligned — one flow/link | Draft never names a Dispatcher; the function is performed by PPP/PPPoE | A.2.2 Table 3: "Discriminator: PPP connection; Dispatcher: PPP demultiplexing" |
| SCHC Data Model (YANG/JSON) | Default rule-set format | **Context metadata** (Data Model, e.g., RFC 9363) | Direct | Per-Context | One model per Context | None | -06 §4.1.2 / §4.2.1.2: Context may specify Parser/Data Model |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Context established per PPP session, held "on both ends" | Context shared by two or more Instances; provisioned by the Domain Manager / Context Repository | Aligned | Draft's per-session shared context is a natural Context; ownership just needs naming |
| Ownership of Set of Rules | SoR referenced by URI, part of the context | SoR is the rule collection available to an Instance, inside the Context | Aligned | Direct; SoR ownership is per-Context/per-Instance |
| Ownership of Set of Variables (SoV) | Not mentioned | Per-Session runtime state (timers, counters) | Not applicable (implicit) | With one Session per link, a single implicit SoV per session; no conflict, only unstated |
| Endpoint ↔ Instance | "endpoint" = node running C/D; one SCHC flow per PPP session | Endpoint hosts one or more Instances; here 1 Instance per PPP connection | Aligned | Draft's node maps to Endpoint + one Instance; no 1:1 device assumption violated |
| Instance ↔ Session | One SCHC association per PPP session | An Instance participates in Sessions; here one Instance ↔ one Session (the PPP connection) | Aligned | Clean 1:1 in this profile; a legitimate constraint, not a gap |
| Sharing of Context between Sessions/Instances | Each PPP session has its own context | -06 permits a Context/SoR shared across Sessions/Instances, or per-Instance | Aligned (draft uses the per-session case) | Draft picks the simplest permitted case; -06 also allows sharing if desired |
| RuleID scope | RuleID unique within the context of the PPP session | RuleID identifies a Rule within a Context | Aligned | RuleID is per-Context; no cross-session meaning assumed by either doc |
| Discriminator scope | PPP Protocol field / PPP connection selects the SCHC flow on the link | Discriminator (here the PPP connection) routes Datagrams to the Instance; unique within the Domain | Aligned | -06 A.2.2 names exactly this; Discriminator derived from lower-layer context |
| Control Header processing scope | No SCHC-level control header; PPP/PPPoE headers carry framing | Optional Control Header for multiplexing/metadata; not required when the Discriminator comes from lower layers | Aligned (not needed here) | Draft's reliance on PPP framing is the "Discriminator from lower-layer context" case in -06 §4.2.2.4 |
| Domain membership and boundaries | Not mentioned; a single peer-pair | Instances sharing a common set of Contexts form a Domain; identifiers unique within the Domain | Not applicable (implicit single Domain) | A.2.2 Table 3 lists "Domain: single"; the trivial one-Domain case, no boundary issues |

## Challenged mappings

Adversarial re-examination of the Direct, Composite, and Profile-specific mappings:

- **PPP session → Session (Composite).** Challenge: is "Session" being stretched? No — -06 defines
  Session as a communication between Instances sharing a Context, and A.2.2 explicitly labels the
  PPP association a Session. Preserves scope (peer-pair), cardinality (2 Instances), and ownership.
  Survives.
- **endpoint → Endpoint + Instance (Composite).** Challenge: the draft describes the endpoint
  physically (DTE/DCE/Ethernet device); does mapping to a *logical* Endpoint hide a semantic
  difference? No — -06 states an Endpoint is logical and "multiple Endpoints can operate on the
  same physical equipment," which is a superset of the draft's usage; the physical description is
  illustrative. Survives.
- **initiator = Device → -06 role convention (Direct).** Challenge: the draft says "device in an
  LPWAN network," while the PPP deployment is explicitly non-LPWAN. Is this misleading? -06
  generalizes the Device role beyond LPWAN and states the initiator convention in §4.2.1.1 and
  reiterates it for PPP in A.2.2. The mapping is exact; only the "LPWAN" qualifier is a wording
  artifact to be dropped in migration. Survives (Direct), with a terminology note.
- **IPV6CP option / URI → on-demand Context provisioning (Profile-specific).** Challenge: RFC 8724
  and -06 both say SCHC involves *no negotiation* between compressing/decompressing entities — does
  IPV6CP signaling violate that? No: the IPV6CP exchange negotiates *which compression protocol and
  where to fetch the rule set*, i.e., Context provisioning/discovery, not per-field negotiation of
  the compression itself. -06 explicitly relaxes the "pre-provisioned" assumption to "Contexts may
  be fetched on demand," and A.2.2 says the PPP Context "can be fetched on demand." This is a
  natural profile use of -06's provisioning model, not a reinterpretation. Survives.
- **PPP demultiplexing → Dispatcher/Discriminator (Composite).** Challenge: the draft never names a
  Dispatcher; is this imposing machinery? No — -06 §4.2.2.4 explicitly covers the case where "the
  Discriminator is derived entirely from lower-layer context (e.g., a specific PPP link)," and the
  Dispatcher "can be integrated into the network stack." The draft's silence is the trivial
  single-Instance case. Survives.

No mapping classification changed during the adversarial pass. (All initial Direct / Composite /
Profile-specific mappings held; none degraded to Partial or Missing.)

### Architectural risk points

- **Risk:** The draft binds "a SCHC context" to a PPP session as one indivisible notion, whereas
  -06 factors the same reality into Session, Instance, and Context/SoR.
  - **Why it matters:** A reader migrating the text must not collapse the three -06 concepts back
    into one, or the distinction between the communication (Session), the processing (Instance),
    and the shared state (Context) is lost — the same conflation the older architecture draft made.
  - **Consequence for migration:** The re-wording must explicitly state "one Instance per PPP
    connection, sharing a Context, communicating in a Session," but this is a framing task with a
    ready template in A.2.2; it does not alter behavior.

- **Risk:** The draft's role sentence ("initiator … plays the role of the device in an LPWAN
  network") ties the Device role to LPWAN.
  - **Why it matters:** In a non-LPWAN PPP/Ethernet deployment the "LPWAN" qualifier is inaccurate;
    -06 defines the role convention generically and, separately, flags the Upside/Downside vs
    Device/Application role relationship as open future work (Appendix B).
  - **Consequence for migration:** Drop the "LPWAN" qualifier and reference the generic -06 role
    convention. No behavioral change; the initiator-as-Device outcome is identical.

- **Risk:** The draft assumes exactly one SCHC association per PPP link and defines no SCHC-level
  multiplexing.
  - **Why it matters:** If a future PPP deployment needed multiple Instances sharing one link, it
    would need a Discriminator/Control Header; the draft provides none.
  - **Consequence for migration:** None for the present profile — -06 treats "one Instance, implicit
    dispatch" as a first-class case. Worth a one-line note that additional Instances would require
    an explicit Discriminator, but not required to migrate.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §3, first sentence (lines 145–147) | "a PPP session defines a vitual link where a SCHC context is established with a particular set of Rules" | State that each PPP session carries a SCHC **Session** over a virtual link; each peer's **Endpoint** binds one **Instance** to the PPP session; the Instances share a common **Context** whose **Set of Rules** is indicated at setup | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the -06 Session/Instance/Context factoring explicit; no behavioral change |
| 2 | §3, last sentence (lines 179–181) | "If the encoding is asymetrical, the initiator of the session is considered downstream, playing the role of the device in an LPWAN network." | "If the Rules are asymmetric, the SCHC Instance that initiates the PPP session plays the role of the Device defined in [SCHC], following the role convention of the SCHC Architecture." (drop "in an LPWAN network") | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with -06 §4.2.1.1 role convention; generalizes Device role beyond LPWAN; same outcome |
| 3 | §4.1, first paragraph (lines 191–196) | "leverages SCHC between an end point that is an IP Host … and another that is an IP Node …" | Recast each side as a SCHC **Endpoint** (hosted on the IP Host/DTE and on the IP Node/DCE/Ethernet device respectively) that associates one **Instance** with the PPP connection | REQUIRED FOR TERMINOLOGY MIGRATION | Distinguishes logical Endpoint/Instance from the physical node; matches A.2.2 |
| 4 | §4.1, "Both endpoints MUST support the function of SCHC Compressor/Decompressor (C/D)" (lines 198–199) | endpoints support C/D | "The Instance on each Endpoint MUST support the SCHC Compression/Decompression (C/D) function." Add: the PPP connection is the **Discriminator** and PPP demultiplexing is the **Dispatcher** | REQUIRED FOR TERMINOLOGY MIGRATION | Names the -06 Dispatcher/Discriminator already implied by PPP demux (§4.2.2.4, A.2.2) |
| 5 | §4.1, "A context may be generated … The context can be asymetric" (lines 218–231) | asymmetric "context" | "A **Context** may be generated … the Context may contain **asymmetric Rules**, in which case the two Instances play distinct roles." Capitalize "Context" | REQUIRED FOR TERMINOLOGY MIGRATION | Uses -06 Context term; asymmetry is a property of Rules/roles, not of a separate object |
| 6 | §4.2, RuleID numbering scheme heading text (lines 239–252) and Figure 3 caption | "A SCHC compressed packet is always in the form" / "SCHC Compressed Packet" | Refer to the wire unit as a **SCHC Datagram** (RuleID + Compression Residue + Payload), per -06 §4.2.5 | REQUIRED FOR TERMINOLOGY MIGRATION | -06 defines "Datagram" as exactly this structure; keeps the compressed-header content unchanged |
| 7 | Introduction (lines 106–108) and Informative References (lines 509–514) | Cites "[I-D.pelov-lpwan-architecture]" (draft-pelov-lpwan-architecture-02) | Cite `[I-D.ietf-schc-architecture]` (draft-ietf-schc-architecture-06) with updated author list/date | REQUIRED FOR TERMINOLOGY MIGRATION | The architecture has been adopted and renamed; terminology in this migration derives from -06 |
| 8 | §3 (lines 176–178) and Informative References | "Data Model for SCHC" [SCHC_DATA_MODEL], draft-ietf-lpwan-schc-yang-data-model-21 | Update to the published **RFC 9363** ("A YANG Data Model for SCHC"), consistent with -06 | OPTIONAL CLARIFICATION | The YANG model is now an RFC; -06 references RFC 9363. Improves currency, not required for the mapping |
| 9 | §4.1 (lines 212–216) | "The SCHC Fragmenter/Reassembler (F/R) is generally not needed …" | Optionally note F/R is the -06 F/R function, "typically fixed by the deployment or profile" (No-ACK here) | OPTIONAL CLARIFICATION | Ties the profile choice to -06 §4.2.2.2 wording; the technical content is already correct |
| 10 | Throughout | "vitual", "echange", "asymetrical", "protocol-independant", "provisionned" | Fix spelling | EDITORIAL | Typos; no semantic effect |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| — | — | — | — | *None* | — | -06 already contains a worked PPP deployment (Appendix A.2.2, Table 3) that expresses every concept this draft needs. No architectural concept, relationship, or scope must be added, removed, or re-scoped to accommodate draft-ietf-schc-over-ppp-00. |

*(No OPTIONAL CLARIFICATION to -06 is necessary either: Appendix A.2.2 and §4.2.1.1 already cover
the peer-to-peer role convention, the one-Instance-per-PPP-connection cardinality, Context fetched
on demand, and the Discriminator-from-lower-layer case.)*

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes** — every proposed change is
  terminology/framing; the RuleID numbering, No-ACK fragmentation, padding, MAX_PACKET_SIZE, and
  the IPV6CP/URI signaling are unchanged.
- Can the migration be performed mechanically? **Mostly** — most of the document (the profile
  parameters) is untouched; the Session/Instance/Context re-framing in ~5 sentences requires clear
  but non-mechanical local rewriting, guided directly by -06 §4.2.1.1 and Appendix A.2.2.
- Does the draft expose a SCHC Architecture -06 gap? **No.**
- Is the gap required for this draft or merely useful generally? **Not applicable** — there is no
  gap. -06 already documents this exact deployment.
- What is the single most important migration issue? Explicitly factoring the draft's single
  "SCHC context per PPP session" into the -06 triplet Session (communication) / Instance
  (processing) / Context+SoR (shared state), so the migrated text does not re-conflate them.

No modification to SCHC Architecture -06 is required.
