# Architectural alignment review: draft-pelov-schc-header-format-00

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | **High** — Almost all concepts are naturally expressible, but the concept of "SCHC Shape" is a composite that requires combining the Datagram Format's framing parameters with a Context Identifier/Discriminator. However, this is a natural mapping and doesn't require any reinterpretation of the -06 model. |
| Transition difficulty | Easy | **Very Easy** — The draft is already written using -06 terminology and framework. However, there are minor terminology mismatches (such as "Data Header" not existing in -06, and the claim that "SCHC Control Header" and "SCHC Data Header" are defined in Section 3 of `[SCHC-ARCH]`). These require local rewording and updates to references, preventing it from being purely mechanical (Very Easy). | **Medium** — The edits do not require any architectural judgment or technical changes to the draft's model. They are straightforward terminology corrections. |
| SCHC Architecture adaptation need | Trivial | **Medium** — No existing normative text in -06 needs to be changed. The required additions are purely additive clarifications (definitions of "RuleID Encoding" and a hook to reference the "SCHC Header Format" for delineation by non-C/D nodes). | **None** — -06 does not currently contain the terms "delineate/delineation", "RuleID Encoding", or "SCHC Header Format". To make the relationship between the draft and -06 fully explicit and natural, adding these definitions and the cross-reference hook to -06 is required. |

## Executive assessment
SCHC Architecture -06 can naturally express the technical model of `draft-pelov-schc-header-format-00`. The draft's principal concepts map directly or compositely to -06 constructs: the "SCHC Header Format" maps to the profile-specific Datagram Format framing parameters, the "Shape Tag" maps to a Control Header carrying framing metadata, and the "Data Header" maps to the RuleID and Rule-dependent fields of the -06 Datagram.

The principal migration difficulty is updating the draft's terminology to align with -06 (specifically replacing "Data Header" with "SCHC Datagram" or "core SCHC Datagram", and correcting the terminology reuse claims in Section 2). An architectural gap exists in -06 because it lacks formal definitions for "RuleID Encoding" and "SCHC Header Format", and does not feature a hook to support delineation by non-C/D nodes (such as firewalls or capture tools). This gap is trivial as it can be closed through purely additive terminology and reference clarifications.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC Header Format | Reusable structural description of datagram framing: RuleID encoding and Control Header type. | Registries / specification time; used by any parsing node. | Global (defined in registries). | None (conveyed by Shape Tag or out-of-band config). | 1 Header Format can be used by many Shapes/deployments. | Structural description only; no rule content or Context metadata. |
| SCHC Shape | An instantiation of a Header Format for a specific Context. | Used by Endpoints and intermediate nodes. | Session/deployment-local. | Context reference / Shape ID. | 1 Shape maps to 1 Header Format and 1 Context. | Allows delineation of RuleID and Control Header, and optionally resolves to full Context. |
| Shape Tag | Self-describing wire format of a Shape's structural part. | Head of the SCHC Datagram. | Link/path-local (conveyed in-band). | CHT and RIE octets. | 1 Shape Tag corresponds to 1 Header Format. | Carries CHT, RIE, and params. |
| RuleID Encoding | How the RuleID is delimited. | Registered globally; parsed at datagram head. | Global. | RIE code (0 = fixed, 1 = context-defined, etc.). | 1 RIE code defines 1 delimitation scheme. | Can be fixed, context-defined, or self-delimiting. |
| Control-Header Type | The type of Control Header present (e.g., none, VOICI). | Registered globally. | Global. | CHT type code (0 = none, 1 = VOICI). | 1 CHT code defines 1 Control Header format and classification. | Categorized as multiplexing or terminal. |
| Data Header | RuleID followed by rule content (compression residue or fragment). | Inside the SCHC Datagram. | Session-local (interpreted by C/D endpoints). | RuleID. | 1 Data Header has 1 RuleID. | Contains the actual compressed payload. |
| Control Header | Header carrying multiplexing, integrity, OAM, or routing. | Precedes or succeeds RuleID. | Domain/link-local. | Control-Header Type. | 1 Datagram can have 0, 1, or 2 Control Headers (max depth 2). | Can be multiplexing or terminal. |
| Context Reference | Identifies specific Context associated with Shape. | Carried by protocol or out-of-band. | Domain/deployment-local. | Deployment/protocol-defined reference value. | 1 Context Reference maps to 1 Context. | Essential to resolve a Shape to a full Context. |

## Native architectural model
The native architectural model of the draft is centered on the concept of **delineation** of SCHC datagrams by intermediate network nodes (such as firewalls, classifiers, segment boundaries, or capture tools) that are not Compression/Decompression (C/D) endpoints. In standard SCHC, the framing structure (specifically the RuleID size and the presence of a Control Header) is deployment-specific. While this is sufficient for C/D endpoints because they possess the static Context, it prevents other nodes along the path from identifying where the RuleID ends and where the rule content (residue or fragment) begins.

To resolve this, the draft introduces the **SCHC Header Format**, which is a reusable, structural description of a SCHC datagram's framing. It consists of two elements: the **RuleID encoding** and the **Control-Header type**. The RuleID encoding specifies how the RuleID is delimited (fixed, context-defined, or self-delimiting), and the Control-Header type specifies which Control Header accompanies the data.

An instantiation of a Header Format for a specific Context is a **SCHC Shape**. At a minimum, a Shape enables any holder to delineate the datagram (i.e. locate and delimit the RuleID and any Control Header present). A Shape may also optionally resolve to the full Context (the actual rule definitions), but this is not required, and the details of such resolution are deferred to future work.

Shapes can be conveyed in-band (via a self-describing **Shape Tag** prefixing the datagram) or out-of-band (via configuration, demux point binding, or signaling protocols). The Shape Tag carries the structural part of the Header Format: the Control-Header Type (CHT) octet, the RuleID-Encoding (RIE) octet, and any encoding-specific parameters.

To prevent infinite recursion and excessive parsing complexity, the draft defines strict composition and stacking rules for Control Headers. Control Headers are classified as either **multiplexing** or **terminal**. A multiplexing header can carry a terminal header, but cannot contain another multiplexing header. A terminal header cannot be followed by another Control Header. This limits the maximum Control Header depth to two.

Finally, the draft establishes two global IANA registries: one for **SCHC RuleID Encodings** and one for **SCHC Control-Header Types**. These registries provide a common, standardized vocabulary that can be referenced by other specifications (e.g. SCHC over Ethernet) to define their framing precisely, rather than defining ad-hoc conventions.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC Header Format | Structural description of framing (RuleID encoding + Control Header type). | Profile-specific framing parameters / Datagram Format. | Profile-specific | Aligned | Aligned | -06 leaves framing details open-ended per profile, whereas the draft standardizes them in a reusable schema. | Can be defined as a profile-specific metadata parameter. |
| SCHC Shape | Header Format + Context reference. | Datagram Format + Context ID / Session ID / Discriminator. | Composite | Aligned | Aligned | -06 doesn't have a single "Shape" abstraction, but the combined concepts of framing and Context identification cover it. | Allows delineation and routing. |
| Shape Tag | In-band wire format of the structural Header Format. | Control Header (metadata). | Direct | Aligned | Aligned | In -06, any in-band non-rule header is a Control Header. The Shape Tag is a specific Control Header carrying framing metadata. | Placed at the front of the datagram. |
| RuleID Encoding | Delimitation scheme of the RuleID. | RuleID size / representation. | Direct | Aligned | Aligned | -06 assumes RuleID size is fixed or profile-defined; the draft formalizes RuleID Encoding as a registered attribute (fixed, context-defined, self-delimiting). | Standardizes RuleID parsing. |
| Control-Header Type | Type of Control Header present. | Control Header format/specification. | Direct | Aligned | Aligned | -06 refers to Control Header formats abstractly; the draft registers them in a global registry (none, VOICI). | Differentiates multiplexing/terminal. |
| Data Header | RuleID + rule content (residue or fragment). | RuleID + Rule-dependent fields (core Datagram). | Direct | Aligned | Aligned | -06 calls the entire unit (with Control Headers) the Datagram, and the compressed part "RuleID and Rule-dependent fields". | The draft separates Data Header from Control Header. |
| Control Header | Header for multiplexing, integrity, OAM, routing. | Control Header. | Direct | Aligned | Aligned | The draft adds specific composition and stacking rules (multiplexing/terminal, max depth 2) that -06 does not define. | Aligns with Section 4.2.5.1 of -06. |
| Context Reference | Identifies Context associated with Shape. | Context Identifier / Session Identifier / Discriminator. | Direct | Aligned | Aligned | -06 uses these to route datagrams to Instances; the draft's Context Reference serves the same purpose of linking to rule definitions. | Resolution method is deferred. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Associated with a Shape (via Context Reference). Private to C/D endpoints. | Shared between two or more Instances participating in a Session. | Aligned | None. |
| Ownership of Set of Rules (SoR) | Contained in the Context. | Contained in the Context, shared by Instances. | Aligned | None. |
| Ownership of Set of Variables (SoV) | Not explicitly discussed (out of scope). | Per-Session variables. | Not applicable | None. |
| Endpoint ↔ SCHC Instance | Reuses -06 definitions. | Endpoint can host multiple Instances. | Aligned | None. |
| SCHC Instance ↔ Session | Reuses -06 definitions. | Session is a communication between Instances. | Aligned | None. |
| Sharing of Context between Sessions/Instances | A Shape instantiates a Header Format for a Context. Multiple Shapes can refer to the same Context or different Contexts. | Instances share Contexts. Multiple Sessions can use the same Context. | Aligned | None. |
| RuleID scope | Local to the Context; delimited per RuleID Encoding. | Identifies a Rule within a Context/SoR. | Aligned | None. |
| Discriminator scope | Reuses -06 definitions. A Control Header (like VOICI) can act as a discriminator. | Optional element used by Dispatcher to route datagrams to the correct Instance. | Aligned | None. |
| Control Header processing scope | Decoded before the Data Header; can be parsed by intermediate nodes without Context. | Section 4.2.5.1 states that Control Headers can remain decodable when the Rule is unknown. | Aligned | Supports the draft's model of allowing intermediate nodes to delineate datagrams. |
| Domain membership and boundaries | Reuses -06 definitions. | Logical grouping of Instances sharing a set of Contexts. | Aligned | None. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Data Header | Direct mapping to -06 Datagram | In -06, "Datagram" refers to the entire unit including any Control Headers. The compressed part is "RuleID" + "Rule-dependent fields". Also, -06 allows the Control Header after the RuleID, which splits the "Data Header". | Direct mapping to the "RuleID and Rule-dependent fields" of the -06 Datagram Format | Clarify that it is not the entire -06 Datagram, but the core compressed/fragmented portion. |
| Shape Tag | Direct mapping to Control Header | If the Shape Tag is a Control Header, and it is followed by a multiplexing and a terminal Control Header, the total depth would be 3, violating the draft's depth limit of 2. | Composite mapping to a Control Header or a prefix component of the overall Control Header structure | In -06, there is no strict limit on Control Header depth, but the Shape Tag can be viewed as a prefix to the Control Header. |

## Architectural risk points
- **Risk:** Implicit assumption of Control-First ordering.
  - **Why it matters:** The draft's terminology ("separates a SCHC Control Header from a SCHC Data Header") and its parsing flow in Section 7 assume that Control Headers always precede the RuleID (control-first). However, -06 explicitly allows Control Headers to be placed after the RuleID.
  - **Consequence for migration:** If a deployment profile uses "data-first" ordering (Control Header after RuleID), the draft's Shape Tag parsing model and terminology cannot express it naturally. The draft must clarify that its Header Format and Shape Tag wire formats are designed specifically for control-first encapsulation.
- **Risk:** Ambiguity of Context Reference resolution.
  - **Why it matters:** The draft defines "SCHC Shape" as a Header Format together with a "Context reference" but defers the in-band resolution of the Context reference to future work (Section 9).
  - **Consequence for migration:** Without a defined way to resolve the Context reference, intermediate nodes cannot resolve the RuleID to actual rule definitions (though they can delineate it if the RuleID encoding is fixed or self-delimiting). Implementations cannot use the Shape Tag to perform RuleID-based operations (like firewalling or classification) if the RuleID encoding is "context-defined" (since the size is unknown without the Context) or if they need to check rule contents, until the Context reference resolution is specified.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3 & 6 | Implicit assumption of Control Header placement. | Explicitly state that the Header Format and Shape Tag assume control-first encapsulation order (where Control Headers precede the RuleID). | REQUIRED FOR CONCEPTUAL ALIGNMENT | -06 allows Control Headers before or after the RuleID, but the draft's parsing and tags only support control-first placement. |
| 2 | Section 3 / Table 1 | `How the RuleID at the head of the Data Header is delimited` | `How the RuleID at the head of the core SCHC Datagram (RuleID and rule-dependent fields) is delimited` | REQUIRED FOR TERMINOLOGY MIGRATION | -06 does not use "Data Header"; it uses "Datagram" and "RuleID and Rule-dependent fields". |
| 3 | Section 2 / Terminology | `reuses SCHC Control Header, SCHC Data Header, RuleID...` | `reuses RuleID, Dispatcher, Discriminator, Instance, Context, and Session from [SCHC-ARCH], Control Header from Section 4.2.5.1 of [SCHC-ARCH]...` | REQUIRED FOR TERMINOLOGY MIGRATION | "SCHC Data Header" is not in -06, and "Control Header" is not in the Terminology list of -06 (though it is in Section 4.2.5.1). |
| 4 | Section 12.1 / Ref 12.1 | `[SCHC-ARCH] lp-wan SCHC Architecture Design Team, "SCHC Architecture", 2026` | `[SCHC-ARCH] Pelov, A., Thubert, P., Minaburo, A., Lampin, Q., and M. Dumay, "Static Context Header Compression (SCHC) Architecture", draft-ietf-schc-architecture-06, Work in Progress, July 2026.` | REQUIRED FOR TERMINOLOGY MIGRATION | Updates reference to the specific -06 draft. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 | Terminology | None | Add definition for `RuleID Encoding`: `How a RuleID at the start of a Datagram is delimited or represented (e.g., fixed-length, context-defined, or self-delimiting).` | ARCHITECTURE GAP | Required by the draft to characterize RuleID delimitation options. |
| 2 | Section 3 | Terminology | None | Add definition for `SCHC Header Format`: `A reusable, structural description of a SCHC Datagram's framing, specifying the RuleID encoding and the Control Header type.` | ARCHITECTURE GAP | Required by the draft as the core architectural metadata entity. |
| 3 | Section 4.2.5.1 | Control Header for Advanced Use Cases | `The presence, placement, and format of the Control Header must be clearly identified...` | Add a new paragraph (as proposed in draft's Appendix A): `The format of the SCHC Control Header, the RuleID encoding, and the encoding of the Discriminator are deployment-specific. A node that processes a SCHC datagram without being a C/D endpoint for it - a segment boundary, firewall, classifier, or capture tool - requires a description of the datagram's framing (the RuleID encoding and the Control Header type) in order to delineate it. Such a description is a SCHC Header Format, specified in [draft-pelov-schc-header-format]. It may be self-describing in band or fixed out of band, including by an RFC that binds it to a demux point such as an EtherType.` | ARCHITECTURE GAP | Implements the proposed hook to connect the architecture with the header format spec. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft** to have an explicit hook in the architecture, but also useful generally for any non-C/D delineation.
- What is the single most important migration issue? **The term "Data Header" vs the -06 "Datagram" concepts**, and the implicit assumption of control-first order in the draft.
