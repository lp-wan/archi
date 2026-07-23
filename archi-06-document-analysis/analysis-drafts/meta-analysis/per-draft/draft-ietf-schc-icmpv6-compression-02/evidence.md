# Evidence Notes: draft-ietf-schc-icmpv6-compression-02

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

The Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express `draft-ietf-schc-icmpv6-compression-02` in its entirety. The principal conceptual mapping is direct: the "SCHC Core" maps to the network-side Endpoint/Instance, the "SCHC Device" maps to the device-side Endpoint/Instance, and the "SCHC instance" channel maps to a SCHC Session. The draft's payload compression mechanism (using `mo-rev-rule-match` and `cda-rev-compress-sent` to compress the inner IPv6 packet payload in the reverse direction) is a natural use of the extensibility of Matching Operators and Compression Decompression Actions defined in [RFC8724] and supported by -06. The principal migration difficulty is purely editorial terminology alignment (converting "End-Point" to "Endpoint", "SCHC instance" to "Session", "SCHC message" to "Datagram", and rephrasing "direction of the End-Point" to "direction of the Session"). No architecture gap exists in SCHC Architecture -06; all its concepts are fully sufficient for this draft.

### Architectural risk points

- **Risk: Terminology collision on "Instance" vs "SCHC instance"**
  - **Why it matters:** In -06, "Instance" is a logical component running on an Endpoint. In the draft, "SCHC instance" is used to refer to the peer-to-peer relationship (which -06 calls a "Session"). This collision could lead to confusion for developers implementing both specifications.
  - **Consequence for migration:** Wording in the draft must be adjusted to use "Session" when referring to the communication link and "Instance" when referring to the processing entity.
- **Risk: Endpoint Directionality Overloading**
  - **Why it matters:** In Sections 7.1 and 7.2, the draft refers to the "direction of the End-Point" (e.g., "in the same direction of the End-Point"). Under the SCHC Architecture, Endpoints are logical nodes and do not have a "direction". Direction (UP/DOWN) is a property of the transmission path or session roles.
  - **Consequence for migration:** The text must be rephrased to refer to "the direction of transmission within the Session" or "the direction of the Session" to remain architecturally coherent.
- **Risk: Implicit 1:1 Ping Assumption**
  - **Why it matters:** The draft states that ignoring the Identifier and setting it to 0 "implies that only one single ping can be launched at any given time on a device." While this is a profile constraint, it assumes a simple single-application/single-instance scenario. In a multi-instance or multi-session endpoint, multiple applications could try to ping.
  - **Consequence for migration:** Clarification is needed that this constraint applies per Session or per Instance, not necessarily globally to the physical device.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 5.1 & Section 3 | "...implies that only one single ping can be launched at any given time on a device." | "...implies that only one single ping can be active at any given time per SCHC Session." | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | A physical device may host multiple SCHC Instances or Sessions. The ping constraint is a consequence of the Session's Context (where the Identifier is elided to 0), not the physical device as a whole. |
| 2 | Section 1, 2, 6, 7, 7.1, 7.2, 8 | "SCHC End-Point", "End-Point", "end point", "End-Points" | "SCHC Endpoint", "Endpoint", "Endpoints" | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align terminology spelling with SCHC Architecture -06 which uses "Endpoint" (no hyphen). |
| 3 | Section 2 | "* SCHC Device: The other end of the SCHC instance formed with the SCHC core." | "* SCHC Device: The other Endpoint in the SCHC Session established with the SCHC Core." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with SCHC Architecture -06 which uses "Session" for the peer-to-peer relationship and "Endpoint" for the nodes. |
| 4 | Section 7, 7.1, 7.2 | "...direction of the End-Point", "...direction of the end point..." | "...direction of transmission within the Session", "...direction of the Session..." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Endpoints do not have a direction in SCHC Architecture -06; direction is a property of the Session's transmission path. |
| 5 | Section 7.1 | "...current Set of Rule..." | "...current Set of Rules..." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with the standard term "Set of Rules (SoR)" (plural) as defined in -06. |
| 6 | Section 8 | "...included in the SCHC message as a variable length residue." | "...included in the SCHC Datagram as a variable length residue." | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align terminology with SCHC Architecture -06 which uses the term "Datagram" or "SCHC Packet" instead of "SCHC message". |
| 7 | Section 8 & Section 9 (YANG) | "Macthing Operator", "Macthing operator" | "Matching Operator", "Matching operator" | **EDITORIAL** | Fix typographical error. |
| 8 | Section 7.3 (Line 657-658) | "...An unsued field MUST not appear in the compressoin rules." | "...An unused field MUST NOT appear in the compression rules." | **EDITORIAL** | Fix typographical errors ("unsued" -> "unused", "compressoin" -> "compression") and capitalize normative keyword "MUST NOT". |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- **Can the draft be migrated without changing technical behavior?** Yes
- **Can the migration be performed mechanically?** Mostly
- **Does the draft expose a SCHC Architecture -06 gap?** No
- **Is the gap required for this draft or merely useful generally?** Not applicable (no gap exists)
- **What is the single most important migration issue?** Terminology alignment around "Endpoint" (unhyphenated), "Session" (replacing "SCHC instance" for communication channels), and "direction of the Session" (replacing "direction of the End-Point").

## analysis-claude
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

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

### Architectural risk points

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

### Needed modifications to the draft under study

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

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | §4.2.2 Endpoint / §6.1 Error handling | Endpoint co-located functions | -06 describes Endpoints providing SCHC functionality; it does not mention an Endpoint originating protocol (e.g. ICMPv6) messages on behalf of a peer. | (Non-normative, optional) One sentence noting that an Endpoint MAY be co-located with non-SCHC functions (e.g., an IP router) that can originate or absorb control-plane messages, and that such behavior is outside the SCHC processing model. | OPTIONAL CLARIFICATION | Would make the surrogate behavior easier to place, but is **not required**: the behavior is IP-layer and already expressible as a co-located function. No architectural concept is added. |

No ARCHITECTURE GAP rows exist; the single architecture row above is an optional convenience, not a
gap, and does not affect the adaptation verdict.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (two judgment points: "instance"→Session,
  and decomposing Core/Device into Endpoint+Instance+Role; everything else is substitution)
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? Not applicable — there is no gap;
  the only architecture suggestion is an optional, generally-useful clarification.
- What is the single most important migration issue? Resolving the draft's overloaded "instance":
  "the SCHC instance formed with the SCHC core" is a **Session** in -06, not an **Instance**.

No modification to SCHC Architecture -06 is required.
