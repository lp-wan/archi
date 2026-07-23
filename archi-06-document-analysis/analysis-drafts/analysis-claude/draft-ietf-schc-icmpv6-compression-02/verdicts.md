# Architectural alignment review: draft-ietf-schc-icmpv6-compression-02

## Verdicts
- Conceptual equivalence: **High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | Two native notions are not one-to-one direct matches and need explicit interpretation before mapping: the draft's "SCHC Core"/"SCHC Device" resolve to *Endpoint + Instance + Role* composites, and the proxy/surrogate behavior (Core synthesizing ICMPv6 on behalf of the Device) is only partly a SCHC function — its ICMPv6-generation part is a co-located IP-router function that -06 neither names nor prohibits. So it is not a pure "terminology-only" (Very High) case. | Every concept in fact maps to an -06 concept with preserved semantics: the new Field IDs, MOs, and CDAs are RFC 8724/RFC 9363 extension points that -06 explicitly inherits; reverse-direction compression is RFC 8724 Direction applied to the current Set of Rules; no concept requires reframing, extra constraints, or unnatural use of an extensibility mechanism, which Medium would require. |
| Transition difficulty | Easy | Not Very Easy because two locations need genuine (if small) architectural judgment rather than blind substitution: the overloaded phrase "the SCHC instance formed with the SCHC core" must be recognized as a *Session*, and the "SCHC Core"/"SCHC Device" definitions must be re-anchored on *Endpoint/Instance/Role* rather than word-swapped. | The document is short, the affected terms are few and localized (Terminology plus a handful of prose lines in Sections 1, 6, 7), technical behavior is untouched, and a complete migration diff can be produced without inventing any architecture wording — so it is well above Medium. |
| SCHC Architecture adaptation need | None | There are zero ARCHITECTURE GAP items: every concept the draft needs (Endpoint, Instance, Session, Context, Set of Rules, Rule/RuleID, MO, CDA, Data Model, Direction/Role, Dispatcher) already exists in -06, and the new MOs/CDAs/Field IDs are additions to RFC 8724/RFC 9363, not to the architecture. | Lowest grade. |

## Executive assessment

SCHC Architecture -06 can naturally express draft-ietf-schc-icmpv6-compression-02. The draft is,
architecturally, a **profile/data-model extension**: it (a) augments the RFC 9363 YANG Data Model
with ICMPv6 Field IDs, (b) defines two new Matching Operators and two new
Compression/Decompression Actions (RFC 8724 extension points that -06 references as-is), and (c)
describes deployment behaviors (ping compression, surrogate ICMPv6 error generation, and
reverse-direction compression of the invoking packet embedded in an ICMPv6 error). None of these
requires a new architectural concept.

The **principal conceptual mapping** is that the draft's pre-architecture vocabulary — "SCHC
Core", "SCHC Device", "SCHC End-Point", and the overloaded "SCHC instance" — resolves cleanly onto
-06's *Endpoint / Instance / Session / Role* model: the Core and Device are two Endpoints, each
hosting an Instance, related by a Session, differing by Role. The new compression primitives sit
below the architecture entirely, inside the Rule/MO/CDA/SoR machinery that -06 delegates to
RFC 8724 and RFC 9363.

The **principal migration difficulty** is terminological, not conceptual: the draft predates -06
and uses "End-Point" and especially "instance" in senses that collide with -06's precise
definitions of *Instance* (a component of an Endpoint) versus *Session* (a communication between
Instances). Resolving that overload is the only place real judgment is needed; everything else is
mechanical rewording confined to a few lines.

There is **no Architecture gap**. The one behavior that -06 does not name — a SCHC Core acting as a
surrogate that originates ICMPv6 error messages on behalf of the Device — is an IP-layer/router
function co-located with the SCHC Endpoint, outside SCHC's compression/decompression scope. -06
does not need to model it; a one-line note would be an optional convenience, not a requirement.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC Core | A SCHC End-Point at the boundary between a regular IP network and a SCHC network; may also act as an IPv6 router/surrogate | The gateway/NGW side (typically powered, less constrained) | Deployment boundary; peer-pair with each Device | Routable IPv6 address (needed only for the surrogate/router behavior) | One Core serves many Devices (star, per figures); N:1 Devices→Core | Term predates -06; conflates an Endpoint, its Instance(s), and an optional co-located router role |
| SCHC Device | The constrained node at the far end of the SCHC association with the Core | The device | Node-local; peer-pair with Core | Device IPv6 address; LPWAN device identity (implicitly) | 1:1 with a Core-side association; typically one Context per Device | The compression subject and beneficiary of surrogate behavior |
| "SCHC instance" (draft usage) | "the SCHC instance formed with the SCHC core" — the association/relationship between Core and Device | Spans both endpoints | Peer-pair / communication relationship | none explicit | 1 association per Core–Device pair | **Overloaded** term: means the *communication relationship*, i.e. a Session — not -06's "Instance" |
| Application | Entity sending/receiving packets to/from the SCHC Device; usually on the regular Internet, may be co-located with Core | Internet host (or Core host) | Network/global | IPv6 address, port | Correspondent of the Device | Not a SCHC entity; context for ICMPv6 semantics |
| Regular Internet | Network location carrying uncompressed IPv6 packets | Beyond the Core | Network/global | n/a | n/a | Non-SCHC side of the boundary |
| NGW (Network Gateway) | Radio gateway shown in figures between Device and Core | Radio access | Link | n/a | Many Devices ↔ one NGW ↔ Core | Transport only; not a SCHC processing entity |
| ICMPv6 Field IDs (fid-icmpv6-*) | New field descriptors for ICMPv6 header fields and the ICMPv6 payload-as-field | Rule field descriptors / Data Model | Rule/Context scope | YANG identities under fid-icmpv6-base-type | Many fields per rule; type-dependent presence | Augmentation of RFC 9363 Data Model |
| ICMPv6 Payload treated as a SCHC field | The ICMPv6 payload (incl. the invoking IPv6 packet in error messages) modeled as a compressible field | Rule field descriptor | Rule scope | fid-icmpv6-payload | One payload field per ICMPv6 rule | Enables nested/recursive SCHC compression of the embedded packet |
| mo-rule-match / mo-rev-rule-match | Matching Operators returning true if a Rule in the current SoR matches the Target Value, in the same / reversed Direction | MO within a Rule | Set-of-Rules scope | MO identity | Used per field descriptor | RFC 8724 MO extension point |
| cda-compress-sent / cda-rev-compress-sent | CDAs that compress the Target Value using rules in the current SoR, in the same / reversed Direction | CDA within a Rule | Set-of-Rules scope | CDA identity | Paired with the matching MO | RFC 8724 CDA extension point; produces nested RuleID+residue |
| Direction (Up/Dw/Bi, "reverse direction") | RFC 8724 Direction Indicator; reverse = swap UP↔DOWN for the embedded packet | Field descriptor / rule application | Rule/Session scope | DI column | Per field descriptor | Reverse used to compress the invoking packet inside an ICMPv6 error |
| Proxy / surrogate behavior | Core anticipates the Device's reaction to bad traffic and originates ICMPv6 errors on the Device's behalf; forwards inbound ICMPv6 errors compressed | Core (Endpoint + co-located router) | Peer-pair / deployment | n/a (uses Core's routable address) | One Core acts for many Devices | IP-layer behavior; partly outside SCHC compression scope |
| Set of Rules / Rule / RuleID | Standard SCHC rule machinery | Endpoint/Instance Context | Context scope; RuleID local to Context | RuleID | Many Rules per SoR | As RFC 8724 / -06 |
| YANG Data Model extension | ietf-schc-icmpv6 module augmenting ietf-schc | Data Model | Global (IANA/module) | YANG identities | Extends RFC 9363 | -06 references the Data Model as an interoperability aid |

## Native architectural model

The draft describes a two-sided SCHC deployment. On one side is a highly constrained **SCHC
Device**; on the other is a **SCHC Core** sitting at the boundary between a SCHC-compressed network
(typically an LPWAN reached through a radio **NGW**) and the regular, uncompressed IPv6 Internet
where an **Application** lives. The Core and Device compress and decompress traffic for each other
using shared SCHC rules. This is the classic RFC 8724 star picture, and the draft inherits it
without redefining it.

The draft's own terminology, however, predates the architecture document. It calls each side a
"SCHC End-Point", and — critically — it uses the word "instance" not for a processing component but
for the *association* between the two ends ("the SCHC instance formed with the SCHC core"). In
-06's vocabulary that association is a **Session**, and the processing component inside each
Endpoint is an **Instance**. This is the single genuine vocabulary collision in the document.

The technical heart of the draft is an extension of the SCHC rule machinery to ICMPv6. It adds
**Field IDs** for every ICMPv6 header field (Type, Code, Checksum, MTU, Pointer, Identifier,
Sequence Number) and — notably — for the **ICMPv6 payload as a whole field**. Because an ICMPv6
error message carries, in its payload, "as much of the invoking packet as possible", treating the
payload as a field lets SCHC compress that embedded IPv6 packet with ordinary rules. All of this is
expressed as an augmentation of the RFC 9363 YANG Data Model.

To compress the embedded packet, the draft introduces two **Matching Operators**
(`mo-rule-match`, `mo-rev-rule-match`) and two **CDAs** (`cda-compress-sent`,
`cda-rev-compress-sent`). Their defining feature is *direction*: an ICMPv6 error travelling toward
the Device carries an invoking packet that originally travelled away from the Device, so it must be
compressed with the **reverse** RFC 8724 Direction, reusing the same Set of Rules. These are new
values plugged into RFC 8724's existing MO/CDA extension points; they do not change how rules are
structured or selected.

Three deployment scenarios organize the document. First, the Device performs a **ping**: Echo
Request/Reply are compressed with ordinary rules (Type/Code elided, Identifier forced to zero,
Sequence Number reduced to a few LSBs). Second, the Device would be the **source** of an ICMPv6
error: rather than send junk over the constrained link and have the Device reject it, the Core acts
as a **surrogate**, originating the appropriate "Destination/Port Unreachable", "Parameter
Problem", or "Packet Too Big" message toward the Internet on the Device's behalf. Third, the Device
is the **destination** of an ICMPv6 error coming back from the Internet: the Core forwards it to the
Device in compressed form, compressing the embedded invoking packet in the reverse direction.

The surrogate behavior is the only place the draft steps outside pure SCHC compression. Generating
an ICMPv6 error requires a **routable IPv6 address** and IP-router semantics; the draft says the
Core "MAY act as a router". This is an IP-layer function co-located with the SCHC Endpoint. It is
described as deployment behavior, not as a new SCHC primitive, and the draft does not require the
SCHC framework itself to define it.

State in the draft is conventional: rules and contexts are static and pre-provisioned; there is no
negotiation. The document adds no new persistent state beyond ordinary SCHC contexts (the ping rule
notes that forcing the Identifier to zero means only one ping may be outstanding, which is a rule
design choice, not new architectural state). Identifiers are the usual ones: RuleID scoped to a
Context, plus the Core's routable IPv6 address used solely by the surrogate function.

Management and provisioning are left implicit and static, exactly as in RFC 8724: rules and the
Data Model extension are assumed to be installed before use. The draft introduces no management
entity, no context-synchronization mechanism, and no control interface of its own.

Security is barely addressed (a placeholder noting that the return path could be flooded with ICMP
errors). Nothing in the draft's security posture constrains the architectural mapping, so it does
not affect this analysis.

In short, the draft's native model is: two SCHC endpoints in a star, exchanging compressed ICMPv6;
a set of new rule-level primitives (Field IDs, MOs, CDAs) built on RFC 8724/RFC 9363 extension
points; and one deployment behavior (surrogate ICMPv6 generation) that lives at the IP layer beside
the SCHC Core. All of this is expressible in -06 once the pre-architecture vocabulary is mapped.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC Core | Boundary SCHC end-point, optional router/surrogate | Endpoint hosting an Instance, with a core-side Role; the surrogate part is a co-located non-SCHC router function | Composite | Aligned: -06 Endpoint is a boundary logical entity; Role captures core side | Aligned: -06 Endpoint MAY host many Instances / serve many Sessions | The router/surrogate part is outside SCHC scope; -06 neither names nor forbids it | Not a single -06 term; Endpoint+Instance+Role |
| SCHC Device | Constrained far-end SCHC end-point | Endpoint hosting a Device-role Instance | Composite | Aligned | Aligned (typically one Instance/Context) | None substantive | Mirror of the Core mapping |
| "SCHC instance" (association) | The relationship between Core and Device | Session | Direct | Aligned: -06 Session is a communication between Instances sharing a Context | Aligned: one Session per Core–Device pair | -06 reserves "Instance" for a component; the draft's word must move to "Session" | Overloaded-term resolution; see Misleading note below |
| Application | Correspondent host | (Non-SCHC) Application/host as in -06 figures | Direct | Aligned | Aligned | None | Not an architectural entity in either doc |
| Regular Internet | Uncompressed IPv6 side | Deployment context (non-SCHC network) | Direct | Aligned | n/a | None | Illustrative |
| NGW | Radio gateway | Transport underlay (as in -06 LPWAN appendix) | Direct | Aligned | Aligned | None | Not a SCHC processing entity |
| ICMPv6 Field IDs | New field descriptors | Rule field descriptors via the Data Model (RFC 9363 augmentation), referenced by -06 as an interoperability aid | Profile-specific | Aligned: Rule/Context scope | Aligned | None | -06 explicitly defers field delineation to Parser/Data Model |
| ICMPv6 payload-as-field | Payload modeled as compressible field | Field descriptor enabling nested SCHC compression via CDA | Profile-specific | Aligned (Rule scope) | Aligned | -06 does not discuss nested compression, but RFC 8724 CDA extensibility permits it | Natural CDA use |
| mo-rule-match / mo-rev-rule-match | MO matching TV against a Rule in current SoR, same/reverse Direction | New MO values (RFC 8724 MO extension point; MO listed in -06 terminology) | Profile-specific | Aligned: SoR scope | Aligned | None; Direction is RFC 8724 | -06 names MO as an RFC 8724 concept |
| cda-compress-sent / cda-rev-compress-sent | CDA compressing TV using current SoR, same/reverse Direction | New CDA values (RFC 8724 CDA extension point; CDA listed in -06 terminology) | Profile-specific | Aligned: SoR scope | Aligned | None | Produces nested RuleID+residue; natural CDA use |
| Direction / reverse direction | RFC 8724 Direction Indicator, reversed for embedded packet | Direction as in RFC 8724; consistent with -06 Role (Upside/Downside) discussion | Direct | Aligned | Aligned | None | -06 §4.2.1 discusses Role/direction |
| Proxy / surrogate behavior | Core originates ICMPv6 errors on the Device's behalf; forwards inbound errors compressed | SCHC part: ordinary C/D on an Endpoint. ICMPv6-generation part: co-located IP-router function, not a SCHC concept | Partial | SCHC part aligned; router part outside -06 scope | Aligned (one Core for many Devices) | -06 has no "surrogate/on-behalf-of" notion; not required because the behavior is IP-layer | See Architectural risk points and OPTIONAL CLARIFICATION |
| Set of Rules / Rule / RuleID | Standard rule machinery | Set of Rules / Rule / RuleID | Direct | Aligned: RuleID local to Context | Aligned | None | Core -06 concepts |
| YANG Data Model extension | ietf-schc-icmpv6 module | Data Model (metadata in Context) | Direct | Aligned | Aligned | None | -06 §4.2.1.2 / §4.1.2 reference the Data Model |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Implicit: each end holds the shared SCHC rules/context; not discussed explicitly | Context is a SoR + metadata shared by two or more Instances | Aligned | Draft's "shared rules" = -06 shared Context; no change |
| Ownership of Set of Rules | Draft speaks of the "current Set of Rule(s)" available for (reverse) matching | SoR is the collection of Rules available to an Instance, inside the Context | Aligned | The MO/CDA "current SoR" is exactly the Instance's SoR |
| Ownership of Set of Variables (SoV) | Not addressed (static compression; the "one ping at a time" note is rule design, not SoV) | SoV = per-session runtime variables | Aligned (vacuously) | No SoV concerns raised by the draft |
| Endpoint ↔ Instance | Draft merges them under "SCHC End-Point"/"SCHC Core"/"SCHC Device" | Endpoint hosts one or more Instances | Partial (draft under-specifies) | Migration decomposes Core/Device into Endpoint+Instance; no behavior change |
| Instance ↔ Session | Draft's "SCHC instance formed with the core" is actually the association | A Session is a communication among Instances sharing a Context | Misaligned terminology only | Must rename draft's "instance" (association sense) to "Session" |
| Sharing of Context between Sessions/Instances | Not discussed; single static context per pair assumed | -06 allows one Context/SoR shared across many Sessions/Instances | Aligned (draft is a permitted special case) | Draft's single-pair assumption is a profile restriction, not a conflict |
| RuleID scope | RuleID identifies the rule used; reverse-compressed embedded packet carries its own RuleID | RuleID is scoped within a Context | Aligned | Nested RuleID is still Context-scoped; natural |
| Discriminator scope | Not used explicitly; Instance selection implicit (single pair) | Discriminator routes Datagrams to Instances within an Endpoint | Aligned (Not applicable in the simple case) | Draft's implicit selection = -06 implicit Dispatcher case |
| Control Header processing scope | Not used by the draft | -06 optional Control Header, framing-scoped | Not applicable | Draft carries no Control Header |
| Domain membership and boundaries | Not named; a single Core–Device deployment | Domain = Instances sharing a common set of Contexts | Aligned (single implicit Domain) | Draft sits within one Domain; no multi-Domain concerns |
| Core's routable IPv6 address | Selector/enabler for surrogate ICMPv6 generation | No -06 concept (IP-layer property of a co-located router) | Not applicable to SCHC model | Confirms surrogate behavior is outside SCHC scope, not a gap |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Proxy / surrogate behavior | Profile-specific | Is originating an ICMPv6 error a *natural use* of a SCHC mechanism, or is it being smuggled into "profile behavior"? A profile mechanism must be a natural use of -06 semantics; SCHC has no primitive that "generates a protocol message on behalf of a peer". Classifying it Profile-specific would overstate architectural alignment. | Partial | The SCHC-compression half is ordinary C/D (Direct/Profile-specific), but the ICMPv6-*generation* half is an IP-layer/router function with no -06 counterpart. It is expressible only by placing it outside SCHC scope (co-located router), so the honest classification is Partial, with the non-SCHC part explicitly acknowledged rather than hidden inside "profile". |

All other Direct, Composite, and Profile-specific mappings survived the adversarial pass: the new
MOs/CDAs are genuine RFC 8724 extension points (not creative reinterpretation), reverse Direction
is a real RFC 8724 feature reused on the current SoR, the Field IDs are a real RFC 9363
augmentation, and the Core/Device→Endpoint+Instance+Role composites preserve scope, cardinality,
and ownership under multiple Instances, multiple Sessions on one Context, and single-Domain
operation.

## Architectural risk points

**Risk 1 — Overloaded "instance".**
- **Risk:** The draft uses "SCHC instance" to mean the Core–Device *association*, which in -06 is a
  Session, whereas -06 uses "Instance" for a component of an Endpoint.
- **Why it matters:** A word-for-word migration that maps "instance"→"Instance" would silently
  invert the meaning, attaching a communication relationship to a single Endpoint component.
- **Consequence for migration:** The one location using "instance" in the association sense must be
  mapped to *Session*, not *Instance* — a judgment call, not a substitution.

**Risk 2 — Surrogate/router behavior has no SCHC home.**
- **Risk:** "The SCHC Core acts as a surrogate to the End-Point" and "MAY act as a router" describe
  the Core originating IP-layer ICMPv6 messages, which no SCHC concept in -06 models.
- **Why it matters:** A reader could mistake this for a SCHC function and look for (or invent) an
  architectural mechanism to sanction it.
- **Consequence for migration:** The migrated text must frame surrogate generation as an IP-layer
  function co-located with the SCHC Core Endpoint, keeping it clearly outside the SCHC
  compression/decompression model. This is a framing precaution, not an architecture change.

**Risk 3 — Nested/recursive compression is undiscussed in -06.**
- **Risk:** `cda-(rev-)compress-sent` compresses an embedded IPv6 packet using the same SoR,
  yielding a nested RuleID+residue inside a residue.
- **Why it matters:** -06 never illustrates a residue that itself contains a SCHC Datagram; a
  reviewer could question whether this is a natural use of the model.
- **Consequence for migration:** None mechanically — it is a legitimate RFC 8724 CDA definition —
  but the draft (not the architecture) is where this must be specified precisely.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §2 Terminology, "SCHC Device" | "The other end of the SCHC instance formed with the SCHC core." | Re-anchor on -06: the Device is the SCHC **Endpoint** at the other end of the **Session** formed with the Core; it hosts the Device-role **Instance**. | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves the overloaded "instance" (association sense = Session) and aligns "end" with Endpoint. Behavior unchanged. |
| 2 | §2 Terminology, "SCHC Core" | "SCHC End-Point located at the boundary of a regular IP network and a network that applies SCHC compression and fragmentation" | Define as a SCHC **Endpoint** (per [I-D.ietf-schc-architecture]) at that boundary, hosting the core-role **Instance** of the Session; note the optional co-located IP-router/surrogate function. | REQUIRED FOR TERMINOLOGY MIGRATION | Maps "End-Point"→Endpoint and separates the SCHC role from the IP-router role. |
| 3 | §1, §3, §7.1, §7.2 | "SCHC End-Point(s)", "End-Point", "end point" | Use "Endpoint" consistently (the -06 spelling), and where the sentence means the association, use "Session". | REQUIRED FOR TERMINOLOGY MIGRATION | Consistent -06 vocabulary. |
| 4 | §1, third bullet & prose | "produced by the SCHC entity"; "The core SCHC forwards…" | "produced by the SCHC **Instance**"; "The **SCHC Core** forwards…". | REQUIRED FOR TERMINOLOGY MIGRATION | Replace informal "SCHC entity"/"core SCHC" with defined -06/draft terms. |
| 5 | §6 | "the SCHC C/D MAY act as a router (i.e. it MUST have a routable IPv6 address…)" | "the SCHC **Core** MAY act as a router …", framing ICMPv6 generation as an IP-layer function co-located with the Core Endpoint, distinct from its C/D function. | OPTIONAL CLARIFICATION | Prevents reading surrogate generation as a SCHC primitive (Risk 2). Behavior unchanged. |
| 6 | §7.1 | "if a Rule exists in the current **Set of Rule**"; "in the same direction of the End-Point"; "in the reverse direction of the end point" | "current **Set of Rules**"; "in the same Direction as the Endpoint"; "in the reverse Direction relative to the Endpoint". | REQUIRED FOR TERMINOLOGY MIGRATION | Uses -06/RFC 8724 spellings ("Set of Rules", "Direction"). |
| 7 | Throughout | "SCHC compression rules", "co-compression rule", "current Set of Rules" | Where a rule collection is meant, use "Set of Rules"; where the shared store is meant, "Context". | OPTIONAL CLARIFICATION | Distinguishes -06 SoR vs Context explicitly; improves precision. |
| 8 | §2 | "re-uses the Terminology defined in [RFC8724] and the **achitecture** document" | "…and the SCHC Architecture document [I-D.ietf-schc-architecture]" (fix typo; add reference). | EDITORIAL | Typo + missing citation. |
| 9 | §4, §7.3, §8 | "compressoin", "Macthing", "origine", "compresssed", "serie", "unsued", "it an EtherType" (misc. typos) | Correct spelling. | EDITORIAL | Purely textual. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §4.2.2 Endpoint / §6.1 Error handling | Endpoint co-located functions | -06 describes Endpoints providing SCHC functionality; it does not mention an Endpoint originating protocol (e.g. ICMPv6) messages on behalf of a peer. | (Non-normative, optional) One sentence noting that an Endpoint MAY be co-located with non-SCHC functions (e.g., an IP router) that can originate or absorb control-plane messages, and that such behavior is outside the SCHC processing model. | OPTIONAL CLARIFICATION | Would make the surrogate behavior easier to place, but is **not required**: the behavior is IP-layer and already expressible as a co-located function. No architectural concept is added. |

No ARCHITECTURE GAP rows exist; the single architecture row above is an optional convenience, not a
gap, and does not affect the adaptation verdict.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (two judgment points: "instance"→Session,
  and decomposing Core/Device into Endpoint+Instance+Role; everything else is substitution)
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? Not applicable — there is no gap;
  the only architecture suggestion is an optional, generally-useful clarification.
- What is the single most important migration issue? Resolving the draft's overloaded "instance":
  "the SCHC instance formed with the SCHC core" is a **Session** in -06, not an **Instance**.

No modification to SCHC Architecture -06 is required.
