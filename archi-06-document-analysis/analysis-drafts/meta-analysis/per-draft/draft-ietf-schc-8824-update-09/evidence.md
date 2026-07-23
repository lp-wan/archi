# Evidence Notes: draft-ietf-schc-8824-update-09

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can naturally express the draft under study without any modification. The principal conceptual mapping involves representing the Device, NGW, App, and Proxy as physical hosts running logical Endpoints, with Instances executing SCHC C/D within Sessions. The OSCORE Inner/Outer layered compression is mapped to separate SCHC Instances operating at different Strata (Inner CoAP vs. Outer CoAP) on the same Endpoint. The principal migration difficulty is updating the text in Sections 1, 2, and 9 to align with these -06 concepts. No architectural gaps exist.

### Architectural risk points

- **Risk:** Chaining of Instances (Inner/Outer) on the same Endpoint.
  - **Why it matters:** The draft relies on OSCORE, which splits CoAP into Inner and Outer headers. This requires applying SCHC twice (Inner SCHC and Outer SCHC) on the same message, with an encryption step in between.
  - **Consequence for migration:** The architecture must allow a packet to be routed from the network stack to the Inner Instance, then back to the security layer (OSCORE), and then to the Outer Instance. If this interface is not well-defined, implementations may struggle to integrate the two SCHC layers.
- **Risk:** Provisioning and management of Dual-Domain Contexts.
  - **Why it matters:** The Inner Context (shared between Device and App) and the Outer Context (shared between Device and NGW/Proxy) may come from different provisioning domains.
  - **Consequence for migration:** The physical device must support multiple Endpoints or Domains, meaning the Instance Manager must coordinate Contexts from different Domain Managers, which may have different security policies.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1 (page 4, line 203) | compressing CoAP headers requires installing common Rules between the two SCHC instances | compressing CoAP headers requires installing a common Context containing Rules shared between the communicating SCHC Instances within a Session | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with the -06 concept of Instances communicating in a Session using a Context. |
| 2 | Section 2 (pages 7-9, lines 364-374, 399-421, 453-491) | Figure 1, 2, 3 descriptions and mentions of "SCHC instances", "adaptation layers", and "provisioning domains" | Update text to describe the physical nodes (Device, NGW, App) hosting SCHC Endpoints and Instances communicating within Sessions using Contexts, and clarify the stratification of Inner/Outer Instances. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the applicability scenarios with the -06 terminology. |
| 3 | Section 9 (pages 46-47, lines 2555-2666) | Proxy descriptions and hop-by-hop processing using "adjacent hops" and "application endpoints" | Frame the CoAP proxy as hosting a SCHC Endpoint with separate ingress and egress Instances participating in separate Sessions with adjacent hops. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns proxy hop-by-hop forwarding with the -06 Instance/Session model. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable (no gap exists)
- What is the single most important migration issue? The single most important migration issue is ensuring that the layering of Inner and Outer SCHC Instances (for OSCORE) and the hop-by-hop proxying Sessions are clearly framed and defined using the Endpoint/Instance/Session model of -06.

## analysis-claude
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

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

### Architectural risk points

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

### Needed modifications to the draft under study

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

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Appendix A.2 (Deployment Models) | Multiple Instances / Stratum / Session | Deployment examples cover LPWAN, PPP, Ethernet/IPv6/UDP | Optionally add a staged-Instances deployment example (OSCORE Inner/Outer per draft-ietf-schc-8824-update): two Instances on one Endpoint at different Strata, one Session end-to-end and one per leg | OPTIONAL CLARIFICATION | Purely illustrative; the concepts (multiple Instances, Stratum, per-leg Sessions, implicit Discriminator) are already explicit in -06 |
| 2 | Section 4.2.2.4 (Multiple Instances) | Dispatcher / Instance selection | "Datagrams are routed to the appropriate Instance by the Dispatcher…" | Optionally add one sentence noting that when Instances operate at different Strata, Instance selection may follow directly from the position of SCHC processing in the stack (a form of implicit Discriminator) | OPTIONAL CLARIFICATION | Already derivable from "the Dispatcher may be integrated directly into the network stack" and the Stratum-based interception criteria |

There are **zero ARCHITECTURE GAP items**.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** — ~10 local rewrites in Sections 1, 2, 9, and 12 require classifying overloaded terms and adding short framing sentences; everything else is untouched or pure capitalization
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable — no gap** (the two optional clarifications above are illustrative conveniences, not gaps)
- What is the single most important migration issue? **Resolving the overloaded lowercase terms — "endpoint" (CoAP/OSCORE vs SCHC), "instance" (SCHC Instance vs CoAP option occurrence), and "context" (SCHC Context vs OSCORE Security Context) — so that only the SCHC-architectural uses are migrated, while framing the hop-by-hop and Inner/Outer rule sharing as -06 Sessions over shared Contexts**

No modification to SCHC Architecture -06 is required.
