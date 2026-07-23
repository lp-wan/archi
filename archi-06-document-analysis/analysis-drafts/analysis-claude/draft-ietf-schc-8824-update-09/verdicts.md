# Architectural alignment review: draft-ietf-schc-8824-update-09

## Verdicts
- Conceptual equivalence: **Very High**
- Transition difficulty: **Easy**
- SCHC Architecture adaptation need: **None**

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | Not High: no concept of the draft requires reinterpretation or non-obvious decomposition. Every architectural touch point maps naturally: "SCHC instance" → Instance; the shared "static context" → Context/SoR; the two independent compression levels (IP/UDP and CoAP) → multiple Instances on one Endpoint distinguished by Stratum; "different provisioning domains" → Domains with Domain Managers; each hop-by-hop leg with consistently shared Rules → a Session between two Instances sharing a Context; Inner/Outer OSCORE Rule sets → two Contexts used by two Instances in two Sessions (one end-to-end, one per leg). The composite mappings (Inner/Outer, proxy legs) preserve the original semantics without any added constraint. The 95% of the draft that is field-level compression machinery (FID/FL/FP/DI/TV/MO/CDA, functions, YANG, IANA) is pure [RFC8724] content that -06 incorporates unchanged ("the SCHC compression and fragmentation mechanisms are used as defined there"). |
| Transition difficulty | Easy | Not Very Easy: the migration is not a pure find-and-replace. Three lowercase terms are overloaded and each occurrence must be classified before editing: "endpoint" (CoAP/OSCORE application endpoint vs. SCHC processing entity — only one occurrence, in Section 1, is the SCHC sense), "instance" (SCHC Instance vs. occurrence of a repeatable CoAP option, Sections 5.1/5.4), and "context" (SCHC Context vs. OSCORE Security Context). In addition, Sections 1, 2, 9.1, and 9.2 benefit from short framing sentences (Session/Domain) rather than one-word substitutions. These are local rewrites requiring light but real judgment. | Not Medium: the judgment locations are few (~10, confined to Sections 1, 2, 9, and 12), the classification decisions are clear and repeatable, no section requires restructuring, no normative statement changes meaning, and the bulk of the document (Sections 3–8, 10–13, both appendices) needs no change at all. The complete migration diff (`terminology-migration.diff`) was produced without any blocked location. |
| SCHC Architecture adaptation need | None | Highest grade | Not Trivial: no notion needed by the draft is missing or merely implicit in -06. Multiple Instances per Endpoint, per-Instance Contexts, the Stratum concept (which exactly captures the draft's two compression levels and the Inner/Outer split), Sessions per communication leg, an Endpoint hosting Instances in several Domains (-06 Figure 5), implicit Discriminators derived from lower-layer context, and Context-consistency requirements (-06 Section 6.2) are all already explicit in -06. Zero ARCHITECTURE GAP items resulted from the adversarial pass. |

## Executive assessment

SCHC Architecture -06 can naturally and completely express draft-ietf-schc-8824-update-09.
The draft is a compression specification: it defines how to construct SCHC C/D Rules
(Field Descriptors, MOs, CDAs, FL functions) for CoAP header fields and options, obsoleting
RFC 8824. Its content is almost entirely at the [RFC8724] mechanism level, which -06 adopts
unchanged; the draft touches architecture only at a handful of points.

The principal conceptual mapping: the draft's "SCHC instances" sharing a "static context"
are -06 Instances sharing a Context within a Session; the draft's two independent compression
levels (IP/UDP and CoAP, Figures 1–3) are multiple Instances on one Endpoint, each with its
own Context and Stratum, whose "different provisioning domains" are -06 Domains; the OSCORE
Inner/Outer Rule split is two Contexts used by two Instances — the Inner Context shared
end-to-end between the application endpoints' Instances (one Session), the Outer Context
shared per communication leg (one Session per leg); a CoAP proxy performing SCHC hosts an
Instance per leg and terminates each Session (it never forwards SCHC Datagrams as such).

The principal migration difficulty is lexical, not conceptual: the draft uses "endpoint",
"instance", and "context" in both SCHC and non-SCHC (CoAP/OSCORE) senses, so migration
requires classifying each occurrence rather than a blind replacement, plus a few short
framing sentences introducing Session/Domain vocabulary in Sections 1, 2, and 9.

No Architecture gap exists: every architectural notion the draft relies on is already
explicitly defined in -06.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC instance | Entity performing SCHC C/D per [RFC8724] at a given level of the stack | Hosted on Device, NGW, proxy, or Application Server | Node-local, per compression level | None explicit; implied by stack position / security processing | One node may run several (IP/UDP-level, CoAP-level; Inner and Outer); two (or more) instances share common Rules | Lowercase in the draft (Sections 1, 2) |
| Static context ("SCHC context") | The set of Rules shared between compressing and decompressing instances; prerequisite known to both before transmission | Installed on both instances; configuration/provisioning out of scope | The pair (or set) of instances sharing it, per compression level | None | One context per instance pair per level; "includes multiple Rules" | Draft once phrases sharing as "common contexts between Devices" (Section 1) |
| Rule | Ordered list of Field Descriptors describing a packet's entire header; selected when all MOs match | Inside the shared context | Context-local | RuleID | Many Rules per context; one Rule may serve both directions via DI; a dedicated RuleID exists for uncompressed packets | |
| RuleID | Identifies the Rule; first element of the compressed message | Assigned when the context is defined | Unique within the shared context (rule set) | RuleID value | 1:1 with Rule | Examples use disjoint values (0–4) across rule sets for readability only |
| Field Descriptor (FID, FL, FP, DI, TV, MO, CDA) | Per-field compression/decompression instruction | Inside a Rule | Rule-local | FID + FP + DI | Many per Rule; same FID may repeat (FP disambiguates); DI splits request/response handling | Core of the draft (Sections 3–6) |
| FID namespace ("CoAP.X", "CoAP.X.Y") | Global identifier of CoAP fields/subfields usable in Field Descriptors | IANA registry "SCHC Compression of CoAP Fields" (Section 13.4) | Global | FID string | One entry per field/subfield | |
| FL functions ("var", "var_bit", "tkl", "osc.piv") | Compute variable residue lengths; must be interpreted identically by both instances | Defined by this spec; referenced from Rules; modeled in YANG | Context-wide (both instances) | Function name | n/a | Sections 3.1, 4.6, 6.4 |
| Compression Residue | Residual bits following the RuleID after compression | In the compressed message | Per message | n/a | n/a | |
| Compressed message (SCHC Packet) | RuleID + Compression Residue (+ payload); unit sent on the wire | Between the two instances of a level/leg | Per leg / per level | Leading RuleID | n/a | Inner compressed unit is tunneled inside the OSCORE ciphertext |
| Device / NGW / App (Application Server) | [RFC8724] topology roles; Device role anchors the Up/Dw Direction Indicators | Physical/logical nodes | Deployment | n/a | Device ↔ NGW ↔ App | Sections 2, 8, 10 |
| Compression levels | SCHC applied at IP/UDP level and independently at CoAP level | Same node's stack | Per level | Implicit (stack position) | 1 node : N levels; independent rule sets | Figures 1–3 |
| Provisioning domain | Management source from which the Rules of a level come | External management entities | Administrative | None | Different levels may use different provisioning domains | Section 2, last paragraph |
| Inner SCHC Rules | Rules compressing the OSCORE Plaintext; shared end-to-end between the two application endpoints | The two OSCORE endpoints | End-to-end pair | RuleID within the Inner rule set | One Inner rule set per OSCORE endpoint pair | Sections 8.2, 9.2 |
| Outer SCHC Rules | Rules compressing the OSCORE-protected message; shared per adjacent-hop leg | The two entities of a leg | Peer-pair (leg) | RuleID within the Outer rule set | One Outer rule set per leg | Sections 8.2, 9.2, 10.2 |
| Application endpoint / OSCORE endpoint / origin, sender, recipient endpoint | CoAP origin client/server; OSCORE protection endpoints ([RFC7252]/[RFC8613] senses) | CoAP layer | CoAP messaging relationship | CoAP Token/MID (CoAP-level, not SCHC) | 2 per exchange, plus proxies between them | CoAP terminology, not a SCHC concept |
| CoAP proxy | Intermediary that decompresses with the Rules of one leg, rewrites CoAP fields (MID, Token, Proxy-Scheme removal), and recompresses with the Rules of the other leg | Co-located on the NGW in the examples | Between two legs | n/a | One proxy : two legs; chains possible (Hop-Limit option) | Sections 9, 10 |
| Communication leg | Adjacent-hop pair on which SCHC Rules are consistently shared; SCHC is optional per leg | Between neighbors in the chain | Peer-pair | Implicit | Each leg has its own shared rule set (and its own MID/Token values) | Section 9 |
| CoAP option instance | One occurrence of a (repeatable) CoAP option in a message | CoAP message | Message-local | Field Position (FP) | Many per message | Terminological collision with "SCHC instance" |
| YANG module ietf-schc-coap | Data model of the new FIDs and FL functions, extending [RFC9363] | Specification / management plane | Global | Module name and namespace | One module | Appendix A |
| Rule synchronization requirement | Rules MUST remain tightly coupled between compressor and decompressor; a Rule update on an OSCORE endpoint MUST trigger an OSCORE key update | Both instances plus the security association | Instance pair | n/a | n/a | Section 12 |

## Native architectural model

The draft is, in its own terms, a protocol-specific compression specification built directly
on the [RFC8724] framework. Its central object is the Rule: an ordered list of Field
Descriptors (FID, FL, FP, DI, TV, MO, CDA) that describes an entire CoAP header, selected by
matching, and identified on the wire by a RuleID followed by a Compression Residue. Almost
all of the document (Sections 3–8, 11, 13, Appendix A) specifies how each CoAP header field,
option, and option subfield is to be described in such Rules, including new FL functions
("var", "var_bit", "tkl", "osc.piv") and a semantic (as opposed to syntactic) treatment of
CoAP options.

The processing entities are called "SCHC instances" (lowercase) or, following [RFC8724],
described through the Device / Network Gateway (NGW) / Application Server roles. The
compression scheme's prerequisite is that "both endpoints know the static context before
transmission"; how the context is configured, provisioned, or exchanged is explicitly out of
scope. The context is a set of Rules common to the compressor and decompressor; the draft
requires Rules to "remain tightly coupled" between them and, when OSCORE is in use,
normatively couples any Rule update to an OSCORE key-material update.

The draft's stack model allows SCHC at two independent levels on the same node: at the
IP/UDP level (as in [RFC8724]) and at the CoAP application level (this document). The two
levels use different Rules, may be managed by different entities, and "the Rules may come
from different provisioning domains". Figures 1–3 show the three arrangements: compression
of the full stack at the LPWAN boundary; standalone end-to-end CoAP compression under DTLS;
and a doubled arrangement with OSCORE.

With OSCORE, the model becomes two-stage: an Inner rule set compresses the OSCORE Plaintext
(the original Code, Class-E options, payload) before encryption, and an Outer rule set
compresses the resulting OSCORE message (outer header, Class-I/U options including the OSCORE
Option, whose value is split into flags/piv/kid_ctx/kid subfields). The Inner rule set is
shared strictly end-to-end between the two application endpoints that share the OSCORE
Security Context; the Inner compressed unit travels inside the ciphertext and is invisible to
intermediaries. The Outer rule set is shared hop-by-hop.

The proxy model (Sections 9–10) makes the scoping explicit: SCHC is applied per communication
leg, each leg relying on "SCHC Rules that are consistently shared between two adjacent hops",
and SCHC may be used on one leg and not another. A proxy fully terminates SCHC on each side:
it decompresses an incoming compressed message with the rule set of the ingress leg, performs
normal CoAP proxy processing (rewriting MID and Token, removing Proxy-Scheme), and
recompresses with the rule set of the egress leg. RuleIDs are therefore meaningful only
within a given shared rule set; the worked examples use disjoint RuleID values (0–4) across
the several rule sets purely for readability.

The draft has no explicit session, dispatching, or identifier machinery of its own: which
rule set applies to a message is implied by the level of the stack at which SCHC operates,
by the leg on which the message is received, and, for Inner Rules, by OSCORE decryption
having occurred. There is no fragmentation content (no F/R state), no control-header
concept, and no negotiation. State beyond the static rule sets is limited to the CoAP and
OSCORE layers themselves. Management is deliberately absent; the only management-adjacent
artifacts are the YANG module extending [RFC9363] and the new IANA registry of compressible
CoAP fields, both of which are global specification-level namespaces rather than runtime
entities.

Finally, the draft reuses the words "endpoint", "instance", and "context" in non-SCHC senses:
"application endpoint", "origin/sender/recipient endpoint", and "OSCORE endpoint" are CoAP
and OSCORE terms; an "instance" of a CoAP option is an occurrence of a repeatable option in a
message (distinguished by FP); and "Security Context" is OSCORE state. These collisions are
lexical, not conceptual — the draft consistently keeps the meanings apart through
qualification.

## Concept mapping

(Final table, after Pass 3 corrections.)

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC instance | C/D-performing entity at a given level | Instance (hosted on an Endpoint) | Direct | Aligned (node hosts Endpoint hosting Instances) | Aligned (Endpoint MAY execute several Instances) | None | Capitalization + explicit Endpoint hosting |
| Static context | Set of Rules shared between the two instances | Context (SoR + metadata) shared by two or more Instances | Direct | Aligned (shared by the Instances of a Session) | Aligned | None; -06 adds optional metadata (Parser, Data Model), which the draft's YANG module naturally populates | |
| "Context includes multiple Rules" | Rule collection | Set of Rules (SoR) within the Context | Composite | Aligned | Aligned | None | Context = SoR + metadata in -06 |
| Rule / RuleID | Header description / its identifier on the wire | Rule / RuleID | Direct | RuleID unique within Context — matches draft's per-rule-set uniqueness | 1:1 | None | |
| Field Descriptor machinery (FID, FL, FP, DI, TV, MO, CDA) | [RFC8724] compression mechanics | [RFC8724] content of a Rule; -06 uses RFC 8724 unchanged | Direct | Rule-local in both | Aligned | None | Bulk of the draft; no migration needed |
| FID namespace / IANA registry | Global CoAP field identifiers | Data Model element referenced by Context metadata | Direct | Global in both | Aligned | None | |
| FL functions (var, var_bit, tkl, osc.piv) | Length computation shared by both sides | Rule/Field Descriptor semantics defined by this specification; captured in the Data Model | Profile-specific | Context-wide in both | n/a | None | Natural: this draft is precisely the specification -06 expects to define such mechanics |
| Compressed message (SCHC Packet) | RuleID + Residue (+ payload) | SCHC Packet; as the unit exchanged between Instances, a Datagram | Direct | Aligned (Datagram = RuleID + operation result) | n/a | None | Renaming to "Datagram" is optional; RFC 8724 terms remain valid |
| Device / NGW / App | [RFC8724] roles anchoring DI | Endpoints hosting Instances; the Device/Application role maps to the Instance Role in the Instance Configuration | Composite | Aligned | Aligned | None; -06 keeps the [RFC8724] Device role convention explicitly (Section 4.2.1.1) | |
| Compression levels (IP/UDP vs CoAP) | Independent SCHC at two stack levels | Multiple Instances on one Endpoint, each with own Context and Instance Configuration; the levels are distinct Strata | Composite | Aligned (Stratum defines exactly this) | 1 Endpoint : N Instances — aligned | None | Instance selection is positional (stack processing order), an implicit Discriminator per -06 |
| Provisioning domain | Management source of a level's Rules | Domain (+ Domain Manager / Context Repository) | Direct | Administrative grouping in both | Different levels in different Domains — aligned (-06 Figure 5: one Endpoint, Instances in two Domains) | None | |
| Inner SCHC Rules | End-to-end rule set over the OSCORE Plaintext | A Context shared by the two application endpoints' Instances; their communication is a Session (end-to-end) | Composite | Aligned; -06 Session has no adjacency/topology constraint | One Context : one end-to-end Session — permitted | None; the Inner Datagram is tunneled inside OSCORE, which -06 does not constrain | |
| Outer SCHC Rules | Per-leg rule set over the OSCORE message | A Context per leg; each leg is a distinct Session between the two Instances of adjacent hops | Composite | Aligned | One Context/Session per leg — permitted | None | |
| Application endpoint / OSCORE endpoint | CoAP/OSCORE messaging roles | No SCHC -06 mapping; mapping to -06 "Endpoint" would be Misleading. Retained as CoAP/OSCORE terminology; the node additionally hosts a SCHC Endpoint whose Instance performs the SCHC operations | Misleading (if mapped); resolved by non-mapping | n/a | n/a | -06 Endpoint is a logical SCHC-processing host, not a messaging role | Key overloaded term |
| CoAP proxy | Decompress–rewrite–recompress intermediary | Node hosting a SCHC Endpoint with one Instance per leg, participating in two Sessions (possibly two Domains); each Session is fully terminated | Composite | Aligned | 1 node : N Instances : N Sessions — aligned | None; no SCHC-level relay/forwarding is implied | Matches -06 Endpoint B pattern (Figure 5) |
| Communication leg | Adjacent-hop pair sharing Rules | Session (two Instances sharing a common Context) | Direct | Peer-pair ↔ Session — aligned | SCHC optional per leg — permitted | None | Implicit Session, as in -06's LPWAN example |
| CoAP option instance | Occurrence of a repeatable option | Not architectural; remains CoAP terminology (FP-selected within a Rule) | Not applicable | n/a | n/a | n/a | Must NOT be renamed during migration |
| YANG module ietf-schc-coap | FID/FL data model extension | Data Model ([RFC9363] family) referenced by Context metadata | Direct | Global in both | Aligned | None | |
| Uncompressed-packet RuleID | Dedicated RuleID for no-compression | No-compression Rule within the SoR | Direct | Context-local in both | Aligned | None | -06 SoR explicitly includes no-compression Rules |
| Payload marker handling | 0xFF elision/restoration during C/D | Behavior of the C/D function as specified by the profile-level Rule semantics | Profile-specific | Aligned | n/a | None | Natural profile content |
| Rule synchronization requirement | Rules tightly coupled; update ⇒ OSCORE key update | Context consistency (-06 Section 6.2) plus a draft-specific normative coupling to security state | Direct | Instance-pair / Session — aligned | n/a | The OSCORE-key coupling is additional profile-level normative behavior, which -06 permits and does not need to express itself | |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Rule set installed on both instances of a level/leg; provisioning out of scope | Context shared by two or more Instances; managed by the Domain Manager / Context Repository | Aligned | -06's management machinery is a superset the draft simply leaves out of scope; no conflict |
| Ownership of Set of Rules | "The SCHC context includes multiple Rules" — the rule set is the shared context | SoR is contained in the Context available to an Instance | Aligned | Pure terminology (Context = SoR + metadata) |
| Ownership of Set of Variables | Not applicable — the draft defines no F/R and no per-session runtime state | SoV holds per-Session runtime parameters | Not applicable | No migration action |
| Endpoint ↔ SCHC Instance | Implicit: a node may run several SCHC instances (two levels; Inner + Outer) | An Endpoint MAY execute several Instances, each with its own Context and Configuration | Aligned (1:N in both) | Stacked/staged instances are covered by Stratum + interception criteria |
| SCHC Instance ↔ Session | Implicit: one instance per leg per level; the AppServer/Device Inner instances communicate end-to-end | A Session is a communication between Instances sharing a Context; an Instance may serve one or several Sessions | Aligned | Draft deployments realize implicit point-to-point Sessions, exactly as -06's LPWAN example |
| Sharing of Context between Sessions/Instances | Each rule set shared by exactly one pair in the examples; nothing forbids wider sharing | A Context may be shared across Sessions and Instances (-06 Tables 1–2) | Aligned | Examples are illustrative, not constraints |
| RuleID scope | Unique within a shared rule set; disjoint values across rule sets in examples are illustrative | RuleID identifies a Rule within a Context | Aligned | No ambiguity: the Inner RuleID is inside the ciphertext, so Inner and Outer RuleID spaces never collide on the wire |
| Discriminator scope | Implicit: stack level, receiving leg, OSCORE decryption determine the applicable rule set | Discriminator optional; may be derived entirely from lower-layer context; Dispatcher may be integrated in the stack | Aligned | The draft's implicit selection is a natural -06 implicit-Discriminator deployment |
| Control Header processing scope | Not applicable — the draft defines no control header | Control Header optional, profile-defined | Not applicable | No migration action |
| Domain membership and boundaries | "Rules may come from different provisioning domains" (per level) | Domain = Instances sharing a common set of Contexts, with a Domain Manager; one Endpoint's Instances may belong to different Domains | Aligned | Direct vocabulary substitution |
| Instance/Session/Context identifiers | None defined; everything implicit | Identifiers unique within the Domain, needed for management | Aligned (management out of the draft's scope) | If a deployment adds -06 management, identifiers come from the Domain, not from this draft |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Application endpoint / OSCORE endpoint | Direct → -06 Endpoint (tempting via the shared word) | -06's Endpoint is a logical host of SCHC processing, not a CoAP messaging role. The draft's "recipient endpoint MUST prepend the 0xFF payload marker" concerns the CoAP endpoint whose Instance decompressed the message; capitalizing it as a SCHC Endpoint would misattribute CoAP-level behavior to a SCHC component and corrupt the OSCORE end-to-end statements (an OSCORE endpoint is defined by the Security Context, not by SCHC hosting). | Misleading if mapped; retained as CoAP/OSCORE terminology with an explicit terminology note; the SCHC operations are attributed to the Instance hosted on the node | Adversarial pass showed the one-word mapping changes meaning |
| Compression levels / Inner–Outer stacking | Direct → multiple Instances | -06's multiple-Instance text (Section 4.2.2.4) is written around a Dispatcher selecting among parallel Instances, whereas here the Inner Instance's input exists only after OSCORE processing and selection is positional (stack order). Checked against -06: Instance Configuration explicitly includes "Packet interception criteria (e.g., Stratum …)" and the Dispatcher "can be integrated into the network stack" with a Discriminator "derived entirely from lower-layer context". Positional selection is therefore a natural implicit-Discriminator case, not a stretch. | Composite (Instance + Stratum + Instance Configuration interception criteria) | Refined from Direct to Composite to make the Stratum/Configuration components explicit; no gap |
| Provisioning domain | Direct → Domain | Is the draft's notion (administrative provenance of Rules) really -06's Domain (Instances sharing a common set of Contexts)? Test: the draft's point is that the two levels' rule sets are managed and distributed by different authorities — exactly what a Domain plus its Domain Manager/Context Repository denote. Grouping-by-shared-Contexts and management authority coincide here. | Direct (Domain, with Domain Manager as the managing entity) | No change; challenge confirmed the mapping |

## Architectural risk points

- **Risk:** Overloaded lexicon — "endpoint", "instance", "context" each carry a non-SCHC meaning in the draft (CoAP/OSCORE endpoint; CoAP option instance; OSCORE Security Context).
  **Why it matters:** A mechanical replace-all migration would silently corrupt normative CoAP/OSCORE statements (e.g., Sections 5.1, 7, 8.2, 9.2, 12).
  **Consequence for migration:** Each occurrence must be classified before editing; a terminology note disambiguating the senses is the safest single edit. This is the reason Transition is Easy rather than Very Easy.

- **Risk:** The draft normatively couples Context state to security state ("any time the context Rules are updated on an OSCORE endpoint, that endpoint MUST trigger an update of the OSCORE key material") while keeping provisioning out of scope.
  **Why it matters:** Once migrated into -06 vocabulary, readers may assume the Domain Manager machinery of -06 governs these updates, importing a management model the draft deliberately excludes; conversely, a Domain-Manager-driven Context update must not bypass the draft's key-update requirement.
  **Consequence for migration:** Reference -06 management concepts informatively only; keep the draft's MUST intact and free-standing.

- **Risk:** Implicit Session and Instance identification throughout the draft (selection by stack level, leg, and OSCORE decryption).
  **Why it matters:** -06 states Instances, Contexts, and Sessions must be uniquely identifiable within a Domain for management purposes; the draft's deployments provide no such identifiers.
  **Consequence for migration:** None for the text itself (-06's own LPWAN example uses implicit Sessions and implicit Discriminators), but deployments that add -06 management must source identifiers from the Domain, not from this draft. Worth a sentence of framing, not a conceptual change.

- **Risk:** Worked examples use globally disjoint RuleID values (0–4) across five different rule sets.
  **Why it matters:** A reader could wrongly infer that RuleIDs are unique across Contexts; in -06 (and in the draft's actual model) a RuleID is meaningful only within its Context.
  **Consequence for migration:** No text change required; do not "fix" the examples, and do not derive any cross-Context RuleID scope from them.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1, ¶2 | "based on a static context … both endpoints know the static context before transmission. The way the context is configured…" | "based on a static Context … both SCHC Instances share the static Context before transmission. The way the Context is configured…" | REQUIRED FOR TERMINOLOGY MIGRATION | The only place "endpoints" means the SCHC entities; resolve to Instances and capitalize Context per -06 |
| 2 | Section 1, ¶3 | "installing common Rules between the two SCHC instances" | "installing a common Context, containing the common Set of Rules (SoR), between the two SCHC Instances"; note that independent levels are performed by distinct Instances, each with its own Context | REQUIRED FOR TERMINOLOGY MIGRATION | Align with -06 Instance/Context/SoR vocabulary |
| 3 | Section 1, ¶4 | "SCHC compresses and decompresses headers based on common contexts between Devices. The SCHC context includes multiple Rules." | "…based on a common Context shared between SCHC Instances. The SCHC Context includes multiple Rules in its Set of Rules (SoR)." | REQUIRED FOR TERMINOLOGY MIGRATION | In -06 the Context is shared between Instances (not Devices); framing fix only, technical model unchanged elsewhere in the draft |
| 4 | Section 1.1 (Terminology) | Familiarity list covers RFC 8724, CoAP, OSCORE | Add familiarity with the SCHC architecture terms (Endpoint, Instance, Context, SoR, Session, Domain) and an explicit disambiguation: "application/origin/sender/recipient/OSCORE endpoint" are CoAP/OSCORE terms, never SCHC Endpoints; a CoAP option "instance" is unrelated to a SCHC Instance | REQUIRED FOR TERMINOLOGY MIGRATION | Resolves the overloaded terms once, protecting every downstream occurrence |
| 5 | Section 2, ¶ after Figure 2 | "end-to-end context initialization … The context initialization is out of scope" | Capitalize: "end-to-end Context initialization … The Context initialization is out of scope" | REQUIRED FOR TERMINOLOGY MIGRATION | -06 Context capitalization |
| 6 | Section 2, last ¶ | "In the case of several SCHC instances …, the Rules may come from different provisioning domains." | "In the case of several SCHC Instances …, each Instance operates with its own Context, and the Contexts may be provided and managed by different SCHC Domains." | REQUIRED FOR TERMINOLOGY MIGRATION | "Provisioning domain" is exactly the -06 Domain |
| 7 | Section 9, intro | Leg-based description with no architectural framing | Add one framing sentence: each leg on which SCHC is used corresponds to a SCHC Session between two Instances sharing a common Context; an entity performing SCHC on several legs hosts an Instance per leg | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the leg ↔ Session, proxy ↔ multi-Instance Endpoint mapping explicit |
| 8 | Section 9.1, ¶1 | "SCHC Rules that are consistently shared between two adjacent hops" | Append: "i.e., on a Context shared within the SCHC Session established between the SCHC Instances of the two adjacent hops" | REQUIRED FOR TERMINOLOGY MIGRATION | Session framing of the hop-by-hop case |
| 9 | Section 9.2, ¶¶2–3 | Inner Rules end-to-end / Outer Rules hop-by-hop, no architectural framing | State that the Inner SCHC Rules form a Context shared end-to-end within a Session between the two application endpoints' Instances, and each Outer rule set is a per-leg Context within a distinct Session | REQUIRED FOR TERMINOLOGY MIGRATION | Composite mapping made explicit in the two normative anchor paragraphs |
| 10 | Section 12, ¶ on Rule updates | "any time the context Rules are updated on an OSCORE endpoint" | "any time the Rules of the Context are updated on an OSCORE endpoint" | REQUIRED FOR TERMINOLOGY MIGRATION | Capitalize Context; keep "OSCORE endpoint" (OSCORE sense) unchanged |
| 11 | Section 14.2 | No architecture reference | Add informative reference to draft-ietf-schc-architecture | REQUIRED FOR TERMINOLOGY MIGRATION | Anchor for the new terms |
| 12 | Sections 3–8 (compressed message) | "compressed message", "SCHC packet" | Optionally note that the compressed message (RuleID + Residue + payload) is, in -06 terms, a SCHC Datagram | OPTIONAL CLARIFICATION | RFC 8724 terms remain valid in -06; renaming not required |
| 13 | Section 2, Figures 1–3 discussion | Device/NGW/App stack figures | Optionally note that each SCHC layer in the figures is realized by a SCHC Instance hosted on a SCHC Endpoint of the node, with the level corresponding to the Instance's Stratum | OPTIONAL CLARIFICATION | Improves explicitness; not needed for correctness |
| 14 | Section 9/10 | Proxy behavior text | Optionally note that the proxy terminates each SCHC Session and never relays SCHC-compressed data across legs | OPTIONAL CLARIFICATION | Already unambiguous from the normative steps |
| 15 | Whole document | — | None identified | EDITORIAL | No editorial changes are required by the migration |

There are **no REQUIRED FOR CONCEPTUAL ALIGNMENT modifications**: no assumption, scope,
relationship, or cardinality of the draft conflicts with -06.

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Appendix A.2 (Deployment Models) | Multiple Instances / Stratum / Session | Deployment examples cover LPWAN, PPP, Ethernet/IPv6/UDP | Optionally add a staged-Instances deployment example (OSCORE Inner/Outer per draft-ietf-schc-8824-update): two Instances on one Endpoint at different Strata, one Session end-to-end and one per leg | OPTIONAL CLARIFICATION | Purely illustrative; the concepts (multiple Instances, Stratum, per-leg Sessions, implicit Discriminator) are already explicit in -06 |
| 2 | Section 4.2.2.4 (Multiple Instances) | Dispatcher / Instance selection | "Datagrams are routed to the appropriate Instance by the Dispatcher…" | Optionally add one sentence noting that when Instances operate at different Strata, Instance selection may follow directly from the position of SCHC processing in the stack (a form of implicit Discriminator) | OPTIONAL CLARIFICATION | Already derivable from "the Dispatcher may be integrated directly into the network stack" and the Stratum-based interception criteria |

There are **zero ARCHITECTURE GAP items**.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** — ~10 local rewrites in Sections 1, 2, 9, and 12 require classifying overloaded terms and adding short framing sentences; everything else is untouched or pure capitalization
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable — no gap** (the two optional clarifications above are illustrative conveniences, not gaps)
- What is the single most important migration issue? **Resolving the overloaded lowercase terms — "endpoint" (CoAP/OSCORE vs SCHC), "instance" (SCHC Instance vs CoAP option occurrence), and "context" (SCHC Context vs OSCORE Security Context) — so that only the SCHC-architectural uses are migrated, while framing the hop-by-hop and Inner/Outer rule sharing as -06 Sessions over shared Contexts**

No modification to SCHC Architecture -06 is required.
