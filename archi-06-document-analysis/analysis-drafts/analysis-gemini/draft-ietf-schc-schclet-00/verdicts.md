# Architectural alignment review: draft-ietf-schc-schclet-00

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | Very High | Highest grade | All native concepts, behaviors, and simplifying assumptions of the draft (including eliding the Stratum Header, Instance IDs, and Discriminators) map natively and without any technical reinterpretation to existing SCHC Architecture -06 concepts. |
| **Transition difficulty** | Easy | It is not "Very Easy" because it requires minor local rewriting and architectural judgment to resolve the definition of "SCHClet Configuration" and correct the confusing term "SCHC Stratum Instance" in Section 4.1 rather than being a purely mechanical search-and-replace. | The required edits are very small, localized to a few sentences and terminology definitions, and do not affect the draft's protocol behavior or the functionality of the C implementation example. |
| **SCHC Architecture adaptation need** | None | Highest grade | No modifications are needed to the reference architecture because the concept of SCHClets, the elision of Control Headers, and the use of implicit Dispatcher routing are already fully and natively supported by the existing -06 text. |

## Executive assessment
SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is the direct match between the draft's "SCHClet" and the architecture's "SCHClet" component, which operates within a single Instance. The principal migration difficulty lies in clarifying the relationship between SCHClets and Instances (specifically correcting a sentence that refers to an Instance itself being defined as a SCHClet) and aligning configuration terminology (mapping "SCHClet Configuration" to subsets of Context and Instance Configuration). No SCHC Architecture gap exists, as all simplifying assumptions (elided headers, lack of discriminators, and static provisioning) are native features of the -06 model.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **SCHClet** | A self-contained unit within the SCHC framework that implements a specific SCHC function or a subset of SCHC operations. | Endpoint / Instance | Single Stratum and single SCHC Instance | Predefined SCHClet Configuration | Operates on a single Instance; can be combined with other SCHClets to achieve a full Stratum implementation. | Omission of Stratum Header, Instance, and Discriminator is permitted. |
| **Full SCHC Implementation** | An implementation covering all mandatory aspects of SCHC as defined in RFC8724, potentially extended by subsequent RFCs. | Endpoint | Endpoint-wide / Network-wide | None | Must interoperate with any SCHClet, provided it has the corresponding configuration. | Represents the fully capable peer. |
| **Full Configuration** | The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation. | Domain Manager / Endpoint | Domain-wide / Endpoint-wide | None | 1:1 with Full SCHC Implementation. Contains multiple SCHClet Configurations. | Represents the global configuration space. |
| **SCHClet Configuration** | A subset of a Full Configuration, which are implemented and supported by a given SCHClet. | SCHClet / Endpoint | SCHClet-local / Session-local | None | Subset of a Full Configuration. | Fully defines the SCHClet's operation. |
| **Rule Management** | Processes for rule discovery, installation, and update. | Domain Manager / Instance Manager | Domain-wide / Endpoint-wide | None | Can be omitted or simplified (read-only) in a SCHClet. | Excluding this reduces overhead. |
| **SCHC Stratum Header, SCHC Instance, Discriminator** | Architectural notions that can be omitted or elided. | Datagram / Dispatcher | Session-local / Link-local | Omitted or implicit | Can be omitted when a SCHClet operates on a single Stratum/Instance. | Eliminates unnecessary overhead. |

## Native architectural model
The draft introduces the concept of a SCHClet, which is a modular sub-function within the Static Context Header Compression (SCHC) framework. Inspired by hardware chiplet architecture, a SCHClet encapsulates a specific SCHC function—such as compression, fragmentation, or acknowledgments—as a self-contained, autonomous unit. 

This modularization is motivated by the diversity of SCHC use cases and the need for resource optimization in highly constrained environments. A constrained device may implement only the specific functions it needs (e.g., NoAck fragmentation or a stateless, fixed-field compression), avoiding the overhead of deploying a full SCHC stack. By utilizing targeted SCHClets, implementations can significantly optimize memory, processing power, and energy usage.

A SCHClet operates within the scope of a single Stratum and a single SCHC Instance. Because of this single-stratum and single-instance context, there is no need for multiplexing or dynamic routing at the SCHC layer. Consequently, notions like the SCHC Stratum Header, the SCHC Instance, and the Discriminator can be completely omitted from both the specification of the SCHClet and the wire format of its datagrams.

To ensure interoperability, a SCHClet is defined by its SCHClet Configuration, which represents a subset of a Full SCHC Configuration (the set of profiles, rules, and parameters supported by a full implementation). Interoperability is achieved through asymmetry: one endpoint can deploy a minimal SCHClet, while the corresponding peer employs a Full SCHC Implementation configured to support that specific SCHClet Configuration.

Finally, SCHClets enable static and stateless deployment models. For example, a minimal fixed-field compression SCHClet can perform stateless, constant-time compression on known constant headers (e.g., IPv6 prefix matching) without needing rule management, context synchronization, or dynamic parameter negotiation. This modularity also provides a clean extensibility model for introducing future SCHC functions without altering the core framework.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **SCHClet** | A self-contained unit within the SCHC framework implementing a specific SCHC function or subset of operations. | **SCHClet** (Section 3 and 4.2.2.3) | Direct | Aligned (single Instance) | Aligned (Instance hosts SCHClets) | None | Semantics are identical. |
| **Full SCHC Implementation** | An implementation covering all mandatory aspects of SCHC. | **Endpoint** hosting one or more **Instances** executing full C/D and F/R functions. | Direct | Aligned | Aligned | None | Represents a fully conformant endpoint. |
| **Full Configuration** | The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation. | Union of **Context** (including Set of Rules) and **Instance Configuration** of the full endpoint. | Composite | Aligned | Aligned | None | Fully expressible as a complete configuration set. |
| **SCHClet Configuration** | A subset of a Full Configuration implemented by a SCHClet. | Subset of the **Context** (compatible partial context) and subset of the **Instance Configuration** (supported features manifest). | Composite | Aligned | Aligned | None | Represents a restricted configuration profile. |
| **Rule Management** | Processes for rule discovery, installation, and update. | Management functions of the **Instance Manager** and **Domain Manager**. | Direct | Aligned | Aligned | None | Omitting or simplifying rule management is fully supported by static provisioning. |
| **SCHC Stratum Header, SCHC Instance, Discriminator** | Omitted or elided architectural notions. | Elision of the **Control Header** and implicit routing by the **Dispatcher** (empty/implicit Discriminator). | Direct | Aligned | Aligned | None | Elision and implicit dispatching are native architectural options in -06. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **Ownership of Context** | Implicitly owned by the SCHClet (on the endpoint). | Shared between Instances in a Session. | Aligned | The SCHClet's configuration corresponds to a subset of the shared Context. |
| **Ownership of Set of Rules** | Part of the SCHClet Configuration. | Part of the Context. | Aligned | The SCHClet's rule subset is represented as a compatible partial Context's Rule Set. |
| **Ownership of Set of Variables** | Implicitly associated with the SCHClet's runtime execution. | Maintained per Session. | Aligned | Run-time state (timers, retransmission counters) belongs to the Session. |
| **Endpoint↔SCHC Instance** | A SCHClet operates on a single SCHC Instance within an Endpoint. | An Endpoint hosts one or more Instances. | Aligned | A SCHClet is contained within a single Instance hosted by an Endpoint. |
| **SCHC Instance↔Session** | A SCHClet operates within a single Instance; Session is implicit. | A Session is a communication between Instances sharing a Context. | Aligned | The SCHClet's communication represents an implicit point-to-point Session. |
| **Sharing of Context between Sessions/Instances** | A SCHClet uses a subset of a Full Configuration; peer must use a compatible configuration. | Instances participating in a Session can use compatible partial Contexts. | Aligned | Supported natively by partial Context compatibility (Section 6.2). |
| **RuleID scope** | Defined within the SCHClet Configuration. | Defined within the Context. | Aligned | RuleID scope is local to the Context/Session. |
| **Discriminator scope** | Omitted/elided since only a single Instance and Stratum exist. | Optional; used by Dispatcher when lower-layer context is insufficient. | Aligned | Discriminator is omitted when lower-layer or implicit routing suffices. |
| **Control Header processing scope** | Omitted/elided. | Optional; carries metadata, multiplexing, or protection info. | Aligned | Control Header is elided when multiplexing is not required. |
| **Domain membership and boundaries** | Implied that SCHClet participates in a Domain with the full implementation peer. | Domain is a grouping of Instances sharing Contexts. | Aligned | The SCHClet and the peer form a common Domain for Context compatibility. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| **SCHC Stratum Instance** | Direct mapping to Instance. | The draft states that a "SCHC Stratum Instance MAY be defined as a SCHClet, and combined with other SCHClets". In -06, a SCHClet is a sub-component within an Instance. An Instance hosts SCHClets, but an Instance itself cannot be defined *as* a SCHClet without violating the architectural hierarchy. | Misleading | Reclassified to highlight that the hierarchy between Instance and SCHClet is reversed in that specific sentence of the draft. The draft needs to be corrected to state that an Instance operating on a Stratum can be implemented using SCHClets. |

## Architectural risk points
- **Risk 1: Ambiguity of the term "SCHC Stratum Instance"**
  - **Why it matters**: Mixing up "Instance" and "SCHClet" in the hierarchy can lead to implementation confusion about which component owns the lifecycle, Context, and configurations.
  - **Consequence for migration**: Text in Section 4.1 must be rewritten to align with the -06 hierarchy (where Instances contain SCHClets).
- **Risk 2: Ambiguity in the mapping of "SCHClet Configuration"**
  - **Why it matters**: A SCHClet's configuration contains both static rules (Context) and runtime parameters (Instance Configuration). If a specification is not clear about which parameters belong to the shared Context versus the local Instance Configuration, interoperability could be broken (e.g., if one end assumes a parameter is local, while the other assumes it is part of the shared Context).
  - **Consequence for migration**: The definition of "SCHClet Configuration" in Section 2 must be aligned to explicitly state that it encompasses subsets of both the Context and the Instance Configuration.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4.1, paragraph 2 (lines 307-310) | "While not recommended, a SCHC Stratum Instance MAY be defined as a SCHClet, and combined with other SCHClets to achieve the functionality of a complete SCHC Stratum implementation." | "While not recommended, a SCHC Instance operating on a specific Stratum MAY be implemented using a single SCHClet, or combined with other SCHClets to achieve the functionality of a complete SCHC Instance." | REQUIRED FOR CONCEPTUAL ALIGNMENT | Corrects the hierarchical relationship. In -06, an Instance hosts SCHClets, so an Instance cannot be defined *as* a SCHClet. Instead, an Instance can be composed of or implemented by SCHClets. |
| 2 | Section 2 (Terminology - Full Configuration) | "Full SCHC Implementation Configuration (Full Configuration): The set of SCHC Profiles/configurations/parameters supported by a Full SCHC Implementation." | "Full SCHC Implementation Configuration (Full Configuration): The union of the Context (including Set of Rules) and the Instance Configuration supported by a Full SCHC Implementation." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the definition with the architecture's terms of Context and Instance Configuration. |
| 3 | Section 2 (Terminology - SCHClet Configuration) | "SCHClet Configuration: A subset of a Full Configuration, which are implemented and supported by a given SCHClet. This may be a single SCHC Profile, or a set of such." | "SCHClet Configuration: A subset of the Context (including Rules) and/or Instance Configuration that is implemented and supported by a given SCHClet. This may be a single SCHC Profile, or a set of such." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the definition of "SCHClet Configuration" with the architecture's concepts of Context and Instance Configuration. |
| 4 | Section 1, paragraph 5 (line 136) | "In addition, the SCHC Architecture introduces the notions of SCHC Stratum Header..." | "In addition, the SCHC Architecture [I-D.ietf-schc-architecture] introduces the notions of SCHC Stratum Header..." | EDITORIAL | Adds explicit citation to the SCHC Architecture document. |
| 5 | Section 8 (Normative References) | Missing reference to `draft-ietf-schc-architecture-06`. | Add normative reference to `[I-D.ietf-schc-architecture]`. | EDITORIAL | Includes the reference architecture in the normative references section. |

## Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **Not applicable**
- What is the single most important migration issue? **Aligning the terminology of configuration and hierarchy (specifically the relationship between SCHClets and Instances) to match the architecture's definitions.**
