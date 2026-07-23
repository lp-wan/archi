# Architectural alignment review: draft-pelov-schclet-architecture-02

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **Very High** | Highest grade | The core concept of a SCHClet (a modular subfunction running in a single Instance on a single Stratum) is fully supported by the definitions in SCHC Architecture -06. There are no conceptual gaps or mismatches. |
| **Transition difficulty** | **Easy** | It is not completely mechanical (Very Easy) because references to "SCHC Stratum Header" and "SCHC Stratum Instance" do not exist in -06. Rewording is required to map these to -06's "Control Header" and "Instance", which requires minor architectural judgment rather than simple find-and-replace. | The required modifications are local, simple, and limited to a few specific sections. The mapping decisions are unambiguous and do not require any restructuring of the document's logical sections or arguments. |
| **SCHC Architecture adaptation need** | **None** | Highest grade | All architectural concepts required by the draft (including the term `SCHClet` itself) are already fully defined and integrated into -06. No modifications, clarifications, or additions to -06 are necessary. |

## Executive assessment
- **Can SCHC Architecture -06 naturally express the draft?** Yes. SCHC Architecture -06 already explicitly defines and incorporates the concept of a `SCHClet` (both in Terminology and focus sections) and defines the `Instance` and `Context` concepts in a way that fully accommodates modular subfunctions.
- **Principal conceptual mapping:** The draft's native concept of a `SCHClet` maps directly to -06's `SCHClet` component, which executes a subset of SCHC functions within an `Instance`.
- **Principal migration difficulty:** The draft references a non-existent "SCHC Stratum Header" and "SCHC Stratum Instance", which must be rephrased to use -06's "Control Header" and "Instance" concepts.
- **Does an Architecture gap exist?** No.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **SCHClet** | A self-contained unit implementing a specific SCHC function or a subset of SCHC operations. | Endpoint / Instance | A single Stratum and a single SCHC Instance. | SCHClet Configuration | One or more SCHClets belong to a single SCHC Instance. | The modular building block of the framework. |
| **Full SCHC Implementation** | An implementation covering all mandatory aspects of SCHC (RFC 8724) and related RFCs. | Endpoint | Multiple Strata, Instances, and Sessions. | N/A | One per Endpoint. | Serves as the traditional monolithic baseline. |
| **Full Configuration** | The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation. | Domain Manager / Endpoint | Domain-wide | N/A | One per Full SCHC Implementation. | Serves as the reference superset. |
| **SCHClet Configuration** | A subset of a Full Configuration that is implemented and supported by a given SCHClet. | SCHClet | SCHClet-local | Profile ID / parameters | One per SCHClet. | Defines the parameters needed for interoperability. |
| **SCHC Stratum Header** | An optional header used for stratum demultiplexing. Omitted or fully elided for a SCHClet. | Packet | Link-local | Header fields | Omitted (0:1) per packet. | Erroneously assumed by the draft to be defined by the SCHC Architecture. |
| **SCHC Instance** | Logical execution environment running SCHC operations. | Endpoint | Instance-local | Instance ID (omitted for SCHClet) | A SCHClet runs within exactly one SCHC Instance. | Omitted in SCHClet specifications when only a single Instance exists. |
| **Discriminator** | Value used to route incoming datagrams to the correct Instance. | Packet / Dispatcher | Endpoint-local | Discriminator value | Omitted (0:1) when using a SCHClet. | Omitted since a SCHClet is defined to operate on a single Instance. |
| **Rule Management** | Mechanisms for discovery, installation, and update of Rules. | Endpoint / Instance / Domain Manager | Instance-local or Domain-local | N/A | N/A | Excluded or simplified (e.g. read-only) to optimize resource usage. |

## Native architectural model

The draft under study describes a modular approach to the Static Context Header Compression (SCHC) framework, introducing the concept of a "SCHClet". Inspired by hardware chiplet design, a SCHClet represents an atomic, self-contained sub-function of the overall SCHC process (such as compression, fragmentation, or acknowledgments). This allows developers to implement and deploy only the relevant subset of SCHC functionality required for a given constrained environment, minimizing implementation complexity and memory/processing overhead.

In the draft's model, a traditional "Full SCHC Implementation" implements all mandatory aspects of RFC 8724 and subsequent extensions. However, as the standard evolves, monolithic implementations risk becoming bloated and overly complex for simple use cases. A system using SCHClets remains fully compliant with the SCHC framework and can interoperate with a Full SCHC Implementation, provided compatible configurations are used.

A SCHClet is formally defined by its "SCHClet Configuration", which is a subset of the "Full Configuration" supported by a Full SCHC Implementation. For instance, a SCHClet may implement only a single SCHC Profile (e.g. for IPsec ESP header compression) or a specific fragmentation mode (e.g. NoAck fragmentation) with fixed parameters.

A crucial design simplification of a SCHClet is that it operates on a single Stratum and within a single SCHC Instance. Because of this single-stratum and single-instance scope, complex routing, multiplexing, and layer-selection features are unnecessary. Specifically, the notions of the "SCHC Stratum Header", "SCHC Instance" identifier, and "Discriminator" can be completely omitted in the specification and operation of a SCHClet, with the Stratum Header always being fully elided.

Interoperability is maintained because a generic SCHC framework implementation on the peer side (such as a gateway) can handle the matching configuration and communicate with the simplified SCHClet. On the constrained side, the SCHClet can be stateless, can omit rule management (discovery, installation, updates), and can even be implemented as a simple constant-time function.

The draft demonstrates this with a minimal fixed-field compression SCHClet that matches a constant 4-byte IPv6 prefix (Version, Traffic Class, Flow Label) and elides it. The draft defines a simple 8-bit RuleID Context (using RuleID 0x60 for pass-through and RuleID 0xFF for compression) to show how a highly constrained node can implement standard-interoperable SCHC in a few lines of C code without any complex parsing or state machines.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **SCHClet** | A self-contained unit implementing a specific SCHC function or a subset of SCHC operations. | `SCHClet` (Terminology and Section 4.2.2.3) | **Direct** | Aligned. Both define it as operating on a single Stratum and Instance. | Aligned. 1 or more SCHClets can compose an Instance. | None. | -06 already explicitly integrates the SCHClet definition from the draft. |
| **Full SCHC Implementation** | An implementation covering all mandatory aspects of SCHC (RFC 8724) and related RFCs. | Endpoint running a complete set of `SCHC Functions` (C/D and F/R) across one or more `Instances`. | **Composite** | Aligned. | Aligned. | The draft focuses on implementation packaging, whereas -06 defines logical Endpoint and Instance components. | Conceptually equivalent. |
| **Full Configuration** | The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation. | Combined `Context` (Set of Rules) and `Instance Configuration`. | **Composite** | Aligned. | Aligned. | None. | Maps to the logical parameters and rules. |
| **SCHClet Configuration** | A subset of a Full Configuration that is implemented and supported by a given SCHClet. | Subset of `Context` and `Instance Configuration` applicable to the SCHClet. | **Composite** | Aligned. | Aligned. | None. | Maps to the subset of parameters and rules. |
| **SCHC Stratum Header** | An optional header used for stratum demultiplexing. Omitted or fully elided for a SCHClet. | None (concept does not exist in -06). | **Missing** | N/A | N/A | -06 does not define a "Stratum Header", only "Stratum" as a background concept, and uses "Control Header" for optional metadata/multiplexing. | The draft incorrectly assumes -06 defines a "Stratum Header". |
| **SCHC Instance** | Logical execution environment running SCHC operations. | `Instance` | **Direct** | Aligned. | Aligned. | None. | Maps directly. |
| **Discriminator** | Value used to route incoming datagrams to the correct Instance. | `Discriminator` | **Direct** | Aligned. | Aligned. | None. | -06 defines the Discriminator as optional, which allows it to be elided/omitted. |
| **Rule Management** | Mechanisms for discovery, installation, and update of Rules. | `Instance Manager` and `Domain Manager` context synchronization. | **Profile-specific** | Aligned. | Aligned. | -06 baseline assumes Context is statically provisioned, making omission of management functions fully aligned. | Statically provisioned contexts are the baseline of both. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Shared between communicating entities. | Shared by two or more Instances. | **Aligned** | Conceptually identical. |
| **Ownership of Set of Rules** | Contained in the Context. | Contained in the Context. | **Aligned** | Conceptually identical. |
| **Ownership of Set of Variables** | Not explicitly mentioned (assumed stateless or local to the fragmentation state machine). | Managed per-Session as runtime parameters. | **Aligned** | Stateless SCHClets simply do not use or maintain a Set of Variables. |
| **Endpoint↔SCHC Instance** | Endpoint hosts the Instance (implied). | Endpoint hosts 1 or more Instances. | **Aligned** | Aligned. |
| **SCHC Instance↔Session** | An Instance participates in a Session (implied). | Session is a communication between two or more Instances sharing a Context. | **Aligned** | Aligned. |
| **Sharing of Context between Sessions/Instances** | Multiple Sessions/Instances can use compatible configurations. | Multiple Instances in a Domain share Contexts. | **Aligned** | Aligned. |
| **RuleID scope** | Identifies a Rule within a Context. | Identifies a Rule within a Context. | **Aligned** | Aligned. |
| **Discriminator scope** | Omitted for SCHClet (assumed single-instance). | Optional; unique within the Domain. | **Aligned** | Omission is permitted since the Discriminator is optional in -06. |
| **Control Header processing scope** | Omitted for SCHClet. | Optional; defined by profiles or framing. | **Aligned** | Omission is permitted in -06. |
| **Domain membership and boundaries** | Not explicitly defined (implicit). | Domain is a logical grouping of Instances sharing Contexts. | **Aligned** | Aligned. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| **SCHC Stratum Header** | Direct mapping | -06 does not define a "Stratum Header" anywhere, only "Stratum" as a background concept and "Control Header" for optional metadata/multiplexing. | **Missing** | Ensuring we do not map to non-existent architectural concepts in -06. The draft must be updated to replace "Stratum Header" with "Control Header". |
| **Rule Management** | Direct mapping | -06 does not define a standard Rule Management protocol, only the logical roles of Domain Manager and Instance Manager. A SCHClet does not run these protocols, which is consistent with static provisioning. | **Profile-specific** | Rule management is a deployment/management detail, not a core data-plane architecture concept. |

## Architectural risk points
- **Risk: References to "SCHC Stratum Header"**
  - **Why it matters:** The draft repeatedly refers to the "SCHC Stratum Header" as if it were a core part of the SCHC Architecture that must be elided, which could confuse implementers looking for this header in the Architecture specification.
  - **Consequence for migration:** These references must be removed or renamed to "Control Header" to avoid referencing non-existent concepts.
- **Risk: Overloading of "SCHClet" as both a specification tool and an implementation unit**
  - **Why it matters:** Implementers might assume a SCHClet is a distinct physical process, whereas architecturally it is just a modular subset of SCHC functions within a single Instance.
  - **Consequence for migration:** The draft should clarify that a SCHClet is a logical component of an Instance, and its boundary is defined by its configuration.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4.1, page 6 | "...a SCHC Stratum Instance MAY be defined as a SCHClet..." | Replace "SCHC Stratum Instance" with "SCHC Instance operating on a specific Stratum". | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | -06 does not define a "Stratum Instance", only "Instance" and "Stratum" as separate concepts. |
| 2 | Section 1, page 3 | "...the SCHC Architecture introduces the notions of SCHC Stratum Header, SCHC Instance and Discriminator..." | Replace "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | -06 does not define a "Stratum Header"; it uses "Control Header" for optional metadata or multiplexing. |
| 3 | Section 3.1, page 5 | "The notions of SCHC Stratum Header, SCHC Instance, and Discriminator MAY be omitted." | Replace "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Consistent terminology migration to match -06. |
| 4 | Section 4.1, page 6 (Title and Text) | "4.1. SCHC Stratum Header, SCHC Instance, Discriminator" and references to "SCHC Stratum Header" | Rename section to "4.1. Control Header, SCHC Instance, Discriminator" and replace occurrences of "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Corrects references to non-existent architecture headers. |
| 5 | Section 5.1, page 6 | "...focusing solely on compression without engaging in rule management or SCHC Stratum functions." | Replace "SCHC Stratum functions" with "multi-stratum operations". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Aligns with the -06 concept that a SCHClet operates on a single Stratum. |
| 6 | Section 2, page 4 | Definition of "SCHClet" | Align the definition verbatim with -06 Terminology: "A self-contained modular unit within the SCHC framework that implements a specific SCHC function or a subset of SCHC operations." | **OPTIONAL CLARIFICATION** | Ensures absolute terminology alignment between the two specifications. |
| 7 | Section 8, page 12 | No reference to draft-ietf-schc-architecture | Add normative reference to `draft-ietf-schc-architecture-06`. | **EDITORIAL** | The draft relies heavily on concepts defined in the architecture document. |

## Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (requires minor rephrasing of "Stratum Header" references)
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **N/A** (no gap exists)
- What is the single most important migration issue? **The draft's references to the non-existent "SCHC Stratum Header" must be migrated to refer to -06's "Control Header" concept.**
