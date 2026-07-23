# Architectural alignment review: rfc9363

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All concepts, structures, field descriptors, and rule parameters defined in RFC 9363 map directly and naturally into SCHC Architecture -06 concepts. In fact, SCHC Architecture -06 explicitly cites RFC 9363 as the standard Context Data Model. |
| Transition difficulty | Easy | Updating RFC 9363 to frame its data model within SCHC Architecture -06 terminology (Endpoint, Instance, Session, Domain, Set of Rules) requires contextual rewording across several sections rather than a single global search-and-replace. | Mapping decisions are completely clear, direct, and repeatable. No architectural redesign or modifications to technical data model behavior are required. |
| SCHC Architecture adaptation need | None | Highest grade | Zero ARCHITECTURE GAP items exist. SCHC Architecture -06 already fully defines all required architectural concepts and explicitly incorporates RFC 9363 as a supported Context Data Model in Section 4.1.2 and Appendix B.2. |

## Executive assessment

This document presents a rigorous architectural expressibility and migration analysis of **RFC 9363** (*A YANG Data Model for Static Context Header Compression (SCHC)*) against **SCHC Architecture -06** (`draft-ietf-schc-architecture-06`).

RFC 9363 formalizes the YANG data model (`ietf-schc`) used to represent SCHC compression and fragmentation Rules as defined in RFC 8724 and RFC 8824. The fundamental conceptual model of RFC 9363 is completely aligned with SCHC Architecture -06. In SCHC Architecture -06, a **Context** is explicitly defined as a Set of Rules (SoR) together with metadata, including a Data Model or Parser (Section 4.1.2), and RFC 9363 is explicitly cited as the canonical YANG data model for SCHC Rules.

Every native concept in RFC 9363—including RuleIDs, compression entries (Field IDs, Field Lengths, Field Positions, Direction Indicators, Target Values, Matching Operators, and Compression/Decompression Actions), fragmentation parameters (modes, window sizes, tile formats, timers, RCS algorithms), and rule natures—maps directly to -06 architectural concepts without requiring any reinterpretation.

Migration of RFC 9363 to SCHC Architecture -06 framing is an **Easy**, mostly mechanical terminology alignment task. It involves replacing legacy LPWAN-specific framing ("Dev", "App", "SCHC table for a specific device") with -06 concepts (**Endpoint**, **SCHC Instance**, **Session**, **Domain**, **Set of Rules**, and **Domain Manager**). No architectural gaps exist in SCHC Architecture -06, so **no modifications to SCHC Architecture -06 are required**.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| `schc` (container) | Top-level YANG container representing the complete set of compression, no-compression, and fragmentation Rules for a device. | Network management datastore / SCHC entity | Device / link-pair scope | Path `/ietf-schc:schc` | 1:1 with device rule set; contains 1:N `rule` entries | Described in draft as "SCHC table for a specific device". |
| `rule` (list) | A list entry representing an individual SCHC Rule for compression, no-compression, or fragmentation. | Child of `/schc` container | Local to `/schc` rule set | `[rule-id-value, rule-id-length]` | 1:N per `/schc` container | Keyed by RuleID value and bit length. |
| `rule-id-value` / `rule-id-length` | Identifies a Rule and specifies its bit length. Length 0 denotes an implicit Rule. | `rule` list key | Unique within `/schc` rule list | `rule-id-value` (uint32), `rule-id-length` (uint8 0..32) | 1:1 per `rule` entry | Formats the wire RuleID header. |
| `rule-nature` | Specifies whether a Rule is for compression, no-compression, or fragmentation. | Leaf of `rule` | Local to `rule` | `nature-type` (identityref: `nature-compression`, `nature-no-compression`, `nature-fragmentation`) | 1:1 per `rule` entry | Selects the corresponding choice branch. |
| `compression-content` / `entry` | List of field descriptor entries defining how header fields are matched and compressed/decompressed. | Choice branch under `rule` | Local to `rule` | Keyed by `[field-id, field-position, direction-indicator]` | 1:N per compression `rule` | Corresponds to a line in the RFC 8724 Rule table. |
| `field-id` (FID) | Identifies the specific protocol header field to which a rule entry applies. | Leaf of `entry` | Global (YANG identityref) | `fid-type` (derived from `fid-base-type`, e.g., `fid-ipv6-version`, `fid-udp-dev-port`) | 1:1 per `entry` | Extensible hierarchy of protocol field identities. |
| `field-length` (FL) | Size of original packet header field in bits, or a variable-length function identifier. | Leaf of `entry` | Global | Union of `uint8` (bits) or `fl-type` identityref (`fl-variable`, `fl-token-length`) | 1:1 per `entry` | Defines expected length or length function. |
| `field-position` (FP) | Occurrence ordinal of a field within the header (1-indexed; 0 = don't care). | Leaf of `entry` | Header-local | `uint8` | 1:1 per `entry` | Handles repeated fields (e.g. CoAP options). |
| `direction-indicator` (DI) | Indicates packet travel direction to which field descriptor applies (`Up`, `Dw`, `Bi`). | Leaf of `entry` | Communication direction | `di-type` identityref (`di-up`, `di-down`, `di-bidirectional`) | 1:1 per `entry` | Enables asymmetric processing. |
| `target-value` (TV) | Value or list of binary values against which a header field is matched. | List under `entry` | Local to `entry` | Keyed by `index` (uint16) | 1:N for match-mapping; 1:0 or 1:1 for equal/MSB | Binary payload representation. |
| `matching-operator` (MO) | Function used to compare header field value with Target Value (`equal`, `ignore`, `MSB`, `match-mapping`). | Leaf of `entry` | Local to `entry` | `mo-type` identityref (`mo-equal`, `mo-ignore`, `mo-msb`, `mo-match-mapping`) | 1:1 per `entry` | May require MO arguments (`matching-operator-value`). |
| `comp-decomp-action` (CDA) | Action to compress field on transmit and reconstruct field on receive. | Leaf of `entry` | Local to `entry` | `cda-type` identityref (`cda-not-sent`, `cda-value-sent`, `cda-lsb`, `cda-mapping-sent`, `cda-compute`, `cda-deviid`, `cda-appiid`) | 1:1 per `entry` | Controls residue generation and header reconstruction. |
| `fragmentation-content` | Parameters defining SCHC fragmentation and reassembly behavior. | Choice branch under `rule` | Local to `rule` | `rule-id` | 1:1 per fragmentation `rule` | Includes mode, header sizes, timers, RCS algorithm. |
| `fragmentation-mode` | Reliability mode for fragmentation (`No-ACK`, `ACK-Always`, `ACK-on-Error`). | Leaf under `fragmentation-content` | Session / rule scope | `fragmentation-mode-type` identityref | 1:1 per fragmentation `rule` | Selects F/R protocol state machine. |
| `Dev` / `App` | LPWAN Device and LPWAN Application Server (RFC 8376 entities). | Physical/logical network endpoints | LPWAN domain | Device ID / IPv6 IID | Peer endpoints of LPWAN communication | Communicating SCHC entities. |
| `SCHC instance` | SCHC execution component at Dev or Network boundary performing C/D and F/R. | Device / Gateway node | Node-local | N/A (implicit in draft) | 1 per Dev implied in examples | Term used in RFC 9363 intro/abstract for SCHC engines. |

## Native architectural model

RFC 9363 specifies a formal YANG data model (`ietf-schc`) for representing Static Context Header Compression (SCHC) compression, no-compression, and fragmentation Rules, as specified informally in RFC 8724 and RFC 8824. The primary objective of RFC 9363 is to provide a standardized, machine-readable syntax for exchanging Rule definitions between SCHC processing entities ("SCHC instances") and for dynamically updating Rule parameters over network management protocols such as NETCONF or RESTCONF.

The native model of RFC 9363 is centered around the `/schc` top-level container, which acts as the root datastore representation of a device's SCHC Rule table. Within this container, a single list `rule` holds all active Rules for that device environment. Each Rule is uniquely identified by a composite key consisting of `rule-id-value` (an unsigned 32-bit integer) and `rule-id-length` (the bit-width of the RuleID, where 0 denotes an implicit Rule).

Each Rule carries a `rule-nature` leaf that specifies its operational type: `nature-compression`, `nature-no-compression`, or `nature-fragmentation`. For compression Rules, the payload consists of an `entry` list representing ordered field descriptors. Each entry models a single line of the RFC 8724 compression table, specifying a Field ID (`field-id`), Field Length (`field-length`), Field Position (`field-position`), Direction Indicator (`direction-indicator`), Target Value list (`target-value`), Matching Operator (`matching-operator`), and Compression/Decompression Action (`comp-decomp-action`), along with optional arguments for MOs and CDAs.

For fragmentation Rules, the payload defines the parameters governing SCHC Fragmentation/Reassembly (F/R) operations, including `fragmentation-mode` (No-ACK, ACK-Always, ACK-on-Error), Direction Indicator (restricted to `di-up` or `di-down`), Layer 2 word size (`l2-word-size`), header bit-widths (`dtag-size`, `w-size`, `fcn-size`), Reassembly Check Sequence algorithm (`rcs-algorithm`), timers (`inactivity-timer`, `retransmission-timer`), maximum packet size, and mode-specific parameters such as tile size, All-1 tile format, and ACK behavior.

Architecturally, RFC 9363 inherits the conceptual framework of RFC 8376 and RFC 8724, framing SCHC deployment around an LPWAN Device (`Dev`) communicating with an LPWAN Application Server (`App`) across a network gateway. Management operations assume that a network management client configures or updates the SCHC Rules on the remote SCHC instance, ensuring that both ends of a constrained link maintain identical Rule definitions. Security and access control (NACM) are framed around preventing unauthorized entities from tampering with a device's Rules, ensuring that a device can only modify its own Rule set on the remote gateway.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| `schc` (container) | Top-level YANG root representing the rule table for a device. | `Context` / `Set of Rules (SoR)` | Composite | High | Direct | In RFC 9363, `/schc` is framed as a single device's rule set; in -06, a Context / SoR is shared across Instances within a SCHC Domain. | A `/schc` container instance cleanly represents a Context / SoR object. |
| `rule` | List entry defining a compression, no-compression, or fragmentation Rule. | `Rule` | Direct | Exact | Exact | None. | Direct 1:1 mapping. |
| `rule-id-value` / `rule-id-length` | Identifies a Rule and its bit length. | `RuleID` | Direct | Exact | Exact | None. | Direct 1:1 mapping. |
| `rule-nature` | Indicates Rule type (compression, no-compression, fragmentation). | `Rule` type / nature | Direct | Exact | Exact | None. | Direct 1:1 mapping. |
| `compression-rule-entry` | Field descriptor row in a compression Rule table. | C/D Field Descriptor | Direct | Exact | Exact | None. | Direct 1:1 mapping. |
| `field-id` (FID) | Identity of protocol header field. | Field Identifier (FID) | Direct | Global | Exact | None. | Uses YANG `identityref` hierarchy. |
| `field-length` (FL) | Field length in bits or variable length function. | Field Length (FL) | Direct | Global | Exact | None. | Direct 1:1 mapping. |
| `field-position` (FP) | Occurrence ordinal of field in header. | Field Position (FP) | Direct | Header-local | Exact | None. | Direct 1:1 mapping. |
| `direction-indicator` (DI) | Direction of packet travel (`Up`, `Dw`, `Bi`). | Direction Indicator / Matching criteria | Direct | Session scope | Exact | None. | Direct 1:1 mapping. |
| `target-value` (TV) | Value sequence(s) for field matching. | Target Value (TV) | Direct | Entry-local | Exact | None. | Direct 1:1 mapping. |
| `matching-operator` (MO) | Function to compare field with Target Value. | Matching Operator (MO) | Direct | Entry-local | Exact | None. | Direct 1:1 mapping. |
| `comp-decomp-action` (CDA) | Action for field compression/decompression. | Compression/Decompression Action (CDA) | Direct | Entry-local | Exact | None. | Direct 1:1 mapping. |
| `fragmentation-content` | Parameters for fragmentation protocol. | F/R Rule parameters | Direct | Rule scope | Exact | None. | Direct 1:1 mapping. |
| `SCHC instance` | SCHC C/D and F/R execution engine. | `SCHC Instance` | Direct | Endpoint-local | Exact | None. | RFC 9363 already uses the term "SCHC instance". |
| `Dev` / `App` | LPWAN Device and Application endpoints. | `Endpoint` / `Instance` roles | Composite | Domain scope | 1:N in -06 | RFC 9363 assumes single-instance devices; -06 supports multi-instance Endpoints. | Mapped to Endpoints hosting Instances in a Session. |
| Datastore management | NETCONF/RESTCONF provisioning of `/schc`. | Domain Manager / Instance Manager Context synchronization | Direct | Domain scope | Exact | None. | Fits naturally into Domain Manager Context provisioning. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Attached to a specific device (`/schc` table for a device). | Shared by Instances within a SCHC Domain for a Session; managed by Domain Manager / Context Repository. | High | A `/schc` tree instance represents the Context / SoR associated with a SCHC Instance or Session. |
| Ownership of Set of Rules | Contained inside `/schc` as a list of `rule`. | Contained within `Context` (as SoR), loaded into `Instance`. | Exact | Direct mapping: `/schc/rule` list is the SoR. |
| Ownership of Set of Variables | Not modeled in RFC 9363 (static configuration only). | Maintained per-Session by Instance (`SoV`). | Compatible | RFC 9363 models static Context rules; runtime state (SoV) is managed dynamically by the Instance. |
| Endpoint ↔ SCHC Instance | Implicit 1:1 relationship per LPWAN device. | 1:N (an Endpoint can host multiple Instances). | High | Multiple `/schc` instances/datastore paths can be hosted on a single multi-instance Endpoint. |
| SCHC Instance ↔ Session | Implicit 1:1 relationship between Dev and Gateway. | 1:1 or 1:N (an Instance can serve multiple Sessions). | High | Compatible with both single-session and multi-session Instance models. |
| Sharing of Context between Sessions/Instances | Model supports transferring Rules between Dev and Gateway. | Explicitly defined: Context shared among Instances in a Domain. | Exact | Fully aligned. |
| RuleID scope | Keyed within `/schc/rule` list. | Scoped to Context / Set of Rules. | Exact | Fully aligned. |
| Discriminator scope | Not defined in RFC 9363 (assumes link-layer / management context). | Used by Dispatcher to route Datagrams to correct Instance. | Compatible | Discriminator selects the Instance; RuleID selects the Rule within the `/schc` Context. |
| Control Header processing scope | Not modeled in RFC 9363. | Optional header before or after RuleID. | Compatible | Control Headers operate outside or alongside `/schc` Rules. |
| Domain membership and boundaries | Implicit LPWAN network boundary (Dev + Gateway). | Explicitly managed by Domain Manager. | High | NETCONF/RESTCONF management of `/schc` forms the management interface of the Domain Manager. |

## Challenged mappings

No mapping classification changed during the adversarial pass.

## Architectural risk points

- **Risk:** RFC 9363 models the top-level container `/schc` as a single root container in the YANG schema, framing it as the "SCHC table for a specific device". In SCHC Architecture -06, a gateway or Endpoint may host multiple SCHC Instances across multiple Domains and Sessions.
- **Why it matters:** An implementer deploying RFC 9363 on a multi-instance gateway needs to know how multiple `/schc` Rule sets are scoped (e.g., via distinct NETCONF/RESTCONF datastore mounts, YANG mount points, or Instance-specific keys).
- **Consequence for migration:** Textual updates in RFC 9363 should clarify that a `/schc` container instance represents the Context / Set of Rules for a given SCHC Instance or Session within a SCHC Domain, aligning with -06 multi-instance architecture without altering the YANG module schema itself.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1, 3, 4, 6 | References to RFC 8376 "Dev", "App", and "SCHC table for a specific device" | Reframe text around SCHC Architecture -06 concepts: **Endpoint**, **SCHC Instance**, **Context**, **Set of Rules (SoR)**, **Session**, and **Domain**. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns document terminology with the formal SCHC Architecture framework. |
| 2 | Section 1 (Introduction) | "This document formalizes the description of the Rules for better interoperability between SCHC instances..." | Update to reference SCHC Architecture -06 (`draft-ietf-schc-architecture-06`), clarifying that the YANG module represents the Context / Set of Rules used by SCHC Instances within a Domain. | REQUIRED FOR TERMINOLOGY MIGRATION | Establishes explicit linkage with the reference architecture. |
| 3 | Section 3 (Terminology) | "Context: A set of Rules used to compress/decompress headers." | Update definition to align with -06: "Context: A Set of Rules (SoR) together with metadata (such as the YANG Data Model defined herein), shared by two or more Instances." Add definitions for Endpoint, Instance, Session, Domain, and SoR. | REQUIRED FOR TERMINOLOGY MIGRATION | Ensures precise alignment of normative and narrative terminology. |
| 4 | Section 6 (YANG Data Model docstrings) | "SCHC table for a specific device." / "A SCHC set of Rules is composed of a list of Rules..." | Update description docstring to: "A SCHC Context / Set of Rules is composed of a list of Rules used for compression, no-compression, or fragmentation by a SCHC Instance." | REQUIRED FOR TERMINOLOGY MIGRATION | Clarifies that `/schc` represents a Context / SoR instance in -06 terminology. |
| 5 | Section 8 (Security Considerations) | "...a device must be allowed to modify only its own rules on the remote SCHC instance." | Reframe security text: "...an Endpoint or management client must be authorized to modify only the Contexts and Rules of SCHC Instances within its authorized Domain, managed via the Domain Manager / NACM." | REQUIRED FOR TERMINOLOGY MIGRATION | Updates security considerations to reflect -06 Domain and Instance access control models. |
| 6 | Section 9.1 (Normative References) | Missing reference to SCHC Architecture | Add normative or informative reference to `draft-ietf-schc-architecture-06`. | OPTIONAL CLARIFICATION | Provides explicit reference to the underlying architecture specification. |

## Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

## Final migration assessment

- **Can the draft be migrated without changing technical behavior?** Yes. The YANG module schema (`ietf-schc@2023-03-01.yang`), data types, identityref hierarchies, list keys, and Rule structures remain 100% unchanged.
- **Can the migration be performed mechanically?** Mostly. Updating the draft requires text rewording in Sections 1, 3, 4, 6, and 8 to adopt -06 terminology, but all mapping decisions are direct and unambiguous.
- **Does the draft expose a SCHC theoretical gap?** No. SCHC Architecture -06 already fully accounts for RFC 9363 in Section 4.1.2 and Appendix B.2.
- **Is the gap required for this draft or merely useful generally?** Not applicable (no gap exists).
- **What is the single most important migration issue?** Reframing the document's introductory and terminology narrative from legacy LPWAN device-centric wording ("Dev", "App", "table for a device") to the multi-instance, domain-managed architectural model of SCHC Architecture -06 (Endpoints, SCHC Instances, Contexts, Sessions, and Domains).
