# Evidence Notes: draft-corneo-schc-compress-payload-02

## analysis-gemini
Verdicts: {'conceptual': 'High', 'transition': 'Easy', 'adaptation': 'Medium'}

### Executive assessment

- **Natural expressibility:** SCHC Architecture -06 cannot naturally express the draft under study in its current form because the architecture's core definitions (SCHC, C/D, and Stratum) restrict processing exclusively to protocol headers.
- **Principal conceptual mapping:** The draft's template-based payload compression maps to a profile-specific C/D operation on a parsed payload field. The `equal-template` MO maps to a custom Matching Operator (MO), and the payload template maps to the Target Value (TV) field of a rule.
- **Principal migration difficulty:** Terminology migration is straightforward (mostly mechanical substitutions of "SCHC node" to "SCHC Instance"). The main architectural challenge lies in the tight coupling of the `equal-template` MO with residue extraction, which deviates from the standard decoupled MO/CDA execution model of RFC 8724.
- **Architecture gap:** A clear architectural gap exists. SCHC Architecture -06 defines C/D, Stratum, and the C/D engine steps solely in terms of protocol headers. These definitions must be reworded to include "payloads" to naturally accommodate payload compression.

### Architectural risk points

- **Risk:** Tight coupling between Matching Operator (MO) and Compression/Decompression Action (CDA).
  - **Why it matters:** The SCHC framework (RFC 8724) decouples matching (MO) from compression (CDA). The `equal-template` MO breaks this decoupling by extracting substrings that are then encoded in the residue, which is typically the responsibility of the CDA.
  - **Consequence for migration:** Implementations must modify their core C/D engine execution pipeline to pass extracted variables from the MO to the CDA, rather than treating them as independent steps.
- **Risk:** Static Context limitation with dynamic JSON payloads.
  - **Why it matters:** Template-less compression uses FIDs like `payload:application/json:1:id` which encode array indices. If a JSON array has a variable number of elements, a static Set of Rules cannot represent it unless it contains rules for all possible indices.
  - **Consequence for migration:** Template-less compression is highly restricted and cannot naturally handle dynamic payloads. Operators must either use template-based compression or restrict payloads to fixed structures.
- **Risk:** Parser complexity and scope.
  - **Why it matters:** Delineating payload fields requires the Parser to understand application-level serialization formats (e.g., JSON). This increases the complexity of the Parser in the Context compared to simple protocol header parsing.
  - **Consequence for migration:** The Context must explicitly define the JSON parser and schema, and the C/D engine must support application-layer parsing.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1 (Introduction) | "extend the SCHC framework [RFC8724] to compress and decompress structured data payloads..." | Clarify that payload compression operates within a SCHC Instance using rules defined in the Context, and that the C/D engine of the Instance performs the compression/decompression. | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with -06 terminology (Instance, Context, C/D engine). |
| 2 | Section 2.1 (Matching Procedure) | "The equal-template MO MUST perform the following steps..." | Clarify that the C/D engine of the compressing Instance executes these steps when evaluating the rule. | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with -06 terminology. |
| 3 | Section 2.4 (Match Failure) | "...the SCHC compressor MUST proceed to evaluate the next rule in the rule set, as specified in Section 7.2 of [RFC8724]." | Change "SCHC compressor" to "C/D engine of the compressing Instance". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with -06 terminology. |
| 4 | Section 4 | "...the keyword payload MUST be used whenever payload compression is needed. In such cases, the keyword payload MUST be specified in the Field IDentifier (FID)." | Clarify that these FIDs are defined in the Context's Set of Rules (SoR), and that the Parser associated with the Context is responsible for extracting the payload field(s) matching the FID. | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | In -06, field extraction is the responsibility of the Parser and Data Model in the Context, not an implicit property of the FID. |
| 5 | Section 5 | "When a SCHC node computes the rule above..." | Change "SCHC node" to "SCHC Instance". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with -06 terminology. |
| 6 | Section 5 | "...the payload keyword in the FID signals the node that application data needs to be compressed." | Clarify that the C/D engine uses the Parser defined in the Context to identify the payload field corresponding to the `payload` FID. | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | Align with the -06 parser-based field extraction model. |
| 7 | Section 6 | "...defined using the new payload keyword." | Change "SCHC node" to "SCHC Instance". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Align with -06 terminology. |
| 8 | Section 6 | "The FIDs in the rule above carry semantics that can be used by the SCHC node to perform successful compression and decompression." | Clarify that the Parser and Data Model defined in the Context map the structured JSON payload to these specific FIDs. | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | FIDs themselves do not carry parsing semantics; the Parser/Data Model in the Context does. |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | Section 3 | C/D definition | "C/D: SCHC function that performs the Compression and Decompression of headers." | Change to: "C/D: SCHC function that performs the Compression and Decompression of headers and/or payloads." | **ARCHITECTURE GAP** | The architecture currently restricts C/D to headers, which prevents natural expressibility of payload compression. |
| 2 | Section 3 | Stratum definition | "Stratum: A background concept that identifies a portion of the network protocol stack targeted by SCHC, i.e., the contiguous layers within which SCHC processing can be applied. The Stratum defines the scope of the protocol headers that the SCHC Rules in the associated Context can address." | Change to: "Stratum: A background concept that identifies a portion of the network protocol stack targeted by SCHC, i.e., the contiguous layers within which SCHC processing can be applied. The Stratum defines the scope of the protocol headers and/or payloads that the SCHC Rules in the associated Context can address." | **ARCHITECTURE GAP** | Expand Stratum to cover payloads to naturally express payload compression. |
| 3 | Section 4.2.2.1 | C/D Engine Scope | "This component is responsible for compressing and decompressing headers using the SCHC framework..." | Change title to "Compression and Decompression (C/D)" and text to "...compressing and decompressing headers and/or payloads..." | **ARCHITECTURE GAP** | Align the C/D engine description with the expanded C/D scope. |
| 4 | Section 4.2.2.1 | C/D Processing Steps | "* applies the compression Rule to the fields of the header(s);" | Change to: "* applies the compression Rule to the fields of the header(s) and/or payload;" | **ARCHITECTURE GAP** | Align the processing steps with payload compression capability. |
| 5 | Section 4.2.2.1 | C/D Processing Steps | "* applies the decompression Rule to reconstruct the original header;" | Change to: "* applies the decompression Rule to reconstruct the original header and/or payload;" | **ARCHITECTURE GAP** | Align the processing steps with payload compression capability. |
| 6 | Section 4.2.1.1 | Interception Criteria | "* Packet interception criteria (e.g., Stratum - the protocol headers that the SCHC Rules in the associated Context can address..." | Change to: "...Stratum - the protocol headers and/or payloads that the SCHC Rules in the associated Context can address..." | **ARCHITECTURE GAP** | Consistency with Stratum re-definition. |

### Description of Gaps and Required Conceptual Changes (Prose)
To naturally express payload compression as defined in `draft-corneo-schc-compress-payload-02`, the SCHC Architecture -06 must undergo a conceptual extension. Currently, the architecture is strictly bounded to the compression of protocol headers. This header-only assumption is hardcoded in the definitions of the C/D function, the Stratum, and the C/D engine processing steps. 

To resolve this, the architectural boundary of the Stratum must be expanded to include protocol payloads. Correspondingly, the C/D engine must be redefined as a component capable of processing both headers and payloads. No new architectural concepts or components are required; the logical structure of Endpoints, Instances, Contexts, Sessions, and Domains remains fully valid and capable of managing payload rules.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft**
- What is the single most important migration issue? **Rewording the core architecture's "header-only" definitions (C/D, Stratum, and C/D engine steps) to include "payloads", and addressing the tight coupling between the equal-template MO and CDA execution.**
