# Architectural alignment review: draft-corneo-schc-compress-payload-02

## Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Medium

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| **Conceptual equivalence** | **High** | The draft's template-based compression introduces a template variable extraction mechanism within the MO and custom residue packing, which stretches the standard decoupled MO/CDA model of RFC 8724 and the architecture. Also, template-less compression cannot naturally handle dynamic array sizes within static rules. | The draft preserves the core SCHC rule structure (FID, TV, MO, CDA). It doesn't introduce any new architectural entities; Endpoints, Instances, Contexts, Sessions, and Domains remain fully compatible. Once C/D is extended to payloads, the technical model fits well. |
| **Transition difficulty** | **Easy** | Transition is not "Very Easy" (essentially mechanical) because some sections (e.g., Sections 2.1 and 6) require minor architectural rewording to explain how the parser and context relate to the new FIDs and MO, rather than simple global search-and-replace. | The draft is already written in SCHC terminology (RFC 8724). No technical behaviors or logic need to be modified; the migration is purely a terminology mapping to -06 concepts (e.g., replacing "SCHC node" with "SCHC Instance"). |
| **SCHC Architecture adaptation need** | **Medium** | No new architectural concepts or relationships are added or removed. Endpoint, Instance, Context, Session, and Domain remain unchanged. | The architecture -06 explicitly limits the definitions of SCHC, C/D, and Stratum to protocol *headers*. To naturally support payload compression, these core definitions and C/D engine processing steps must be reworded to include "payloads", which shifts the meaning of these existing statements. |

## Executive assessment
- **Natural expressibility:** SCHC Architecture -06 cannot naturally express the draft under study in its current form because the architecture's core definitions (SCHC, C/D, and Stratum) restrict processing exclusively to protocol headers.
- **Principal conceptual mapping:** The draft's template-based payload compression maps to a profile-specific C/D operation on a parsed payload field. The `equal-template` MO maps to a custom Matching Operator (MO), and the payload template maps to the Target Value (TV) field of a rule.
- **Principal migration difficulty:** Terminology migration is straightforward (mostly mechanical substitutions of "SCHC node" to "SCHC Instance"). The main architectural challenge lies in the tight coupling of the `equal-template` MO with residue extraction, which deviates from the standard decoupled MO/CDA execution model of RFC 8724.
- **Architecture gap:** A clear architectural gap exists. SCHC Architecture -06 defines C/D, Stratum, and the C/D engine steps solely in terms of protocol headers. These definitions must be reworded to include "payloads" to naturally accommodate payload compression.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| **Template-based compression** | Payload compression utilizing a pre-shared model (template) that only requires the values that are changing in the payload. | Rule in Context | Session | RuleID | 1:1 relationship between a rule entry and a template | Relies on the `equal-template` MO |
| **Template variable ($n:length)** | A placeholder for variable fields in a template definition, carrying position index and fixed size in bytes. | TV template of a rule | Local to the template repetition block or template | Positional index `n` | 1:1 between variable placeholder and its extracted residue value | Right-padded with zeros if extracted value is shorter than length |
| **Template function ($repeat())** | A function used to repeat a sub-template multiple times in the payload separated by a separator. | TV template of a rule | Local to the template | Function name `repeat` | 1:N relationship between the repeat function and its repetitions | Requires encoding a repetition count |
| **Repetition count** | The number of repetitions of a repeat block, encoded as an 8-bit unsigned integer at the start of the residue block. | Compression residue | Datagram | None (implicit first byte of repeat block residue) | 1:1 with the repeat function instance in the payload | Max 255 repetitions |
| **payload keyword** | A keyword used in the FID to signal that payload compression is being performed. | Rule's Field Identifier (FID) | Context / Rule | Literal string "payload" (or prefix) | Can be used alone (template-based) or as a prefix (template-less) | Mandated by the draft |
| **equal-template MO** | A Matching Operator that evaluates equality between a field value and a template in the TV, and extracts variable substrings. | Rule's Matching Operator (MO) | Rule-local | Name `equal-template` | Associated 1:1 with a rule's TV containing a template | Binds matching logic with residue extraction |
| **Template-less payload fields** | Individual structured data fields specified using a path-like prefix syntax in the FID. | Rule's Field Identifier (FID) | Context | FID string `payload:<media-type>:<index>:<field-name>` | 1:1 mapping between a rule entry and a specific structured field path/index | Semantics of the FID prefix are non-normative |

## Native architectural model
The native architectural model of `draft-corneo-schc-compress-payload-02` extends the Static Context Header Compression (SCHC) framework to compress and decompress structured data payloads (such as JSON) rather than just protocol headers. It assumes that the static structure of payload datagrams is known in advance and can be shared between the sender and receiver.

To achieve payload compression, the draft introduces two main approaches: template-based compression and template-less compression. 

In template-based compression, the payload is treated as a single field value. A template containing static text, positional variables, and functions is stored in the Target Value (TV) of a rule. The Field Identifier (FID) is set to the keyword `payload`. A new Matching Operator (MO), `equal-template`, is used to evaluate the payload. During matching, the compressor parses the template in the TV, compares the fixed portions of the template against the payload, and extracts the variable parts. If the match is successful, the extracted variables are packed into the compression residue, right-padded with zero bytes to their declared fixed length. Upon decompression, the receiver strips the padding and reconstructs the payload by substituting the residue values into the template variables.

To handle variable-length arrays or repeating patterns in structured payloads, the template syntax supports a `$repeat(template, separator)` function. The compressor determines the number of repetitions during matching and prepends a 1-byte repetition count to the residue block. Variables inside the repeating template are scoped locally to each repetition.

In template-less payload compression, structured payloads are compressed by mapping individual fields to separate rules or rule entries. The FIDs carry semantic path information, such as `payload:<media-type>:<index>:<field-name>`, while the TV contains the static value of the field. This allows standard SCHC matching operators (like `equal` or `ignore`) and compression actions (like `elide` or `send`) to be applied to individual fields within the payload.

The draft assumes that the C/D engine operates on the serialized textual representation of the fields and does not require knowledge of application-layer data types. The actual template matching algorithm is implementation-specific.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| **Template-based compression** | Compression using a template in TV. | C/D operation on a parsed payload field. | `Profile-specific` | Aligned. Both reside in the Context (SoR) and apply to a Session. | Aligned. A Rule carries the TV and MO/CDA. | The draft assumes a single C/D operation can compress a whole payload structure, whereas standard C/D operates on individual header fields. | Requires the Parser to pass the entire payload as a single field value. |
| **Template variable ($n:length)** | Placeholder in TV template. | Represented as sub-fields within the TV and extracted as part of the residue. | `Profile-specific` | Aligned. It is local to the rule's TV. | Aligned. | In standard SCHC, variables are represented by separate rule entries with their own FIDs, whereas here they are embedded inside a single TV template. | Extends the semantics of TV. |
| **Template function ($repeat())** | Repeating pattern in TV template. | Part of the template grammar stored in TV. | `Profile-specific` | Aligned. Local to the TV. | Aligned. | Standard TV does not support syntax/functions; it is a static value. | Evaluated by the custom MO. |
| **Repetition count** | Number of repetitions encoded in residue. | Compression residue. | `Profile-specific` | Aligned. Carried in the Datagram. | Aligned. | Standard residues only carry field value bits (or LSBs), not control variables like counts. | Part of the custom MO/CDA behavior. |
| **payload keyword** | FID identifier. | Field Identifier (FID). | `Direct` | Aligned. Part of the C/D rule. | Aligned. | None, it acts as a standard FID. | Reuses the FID field in the rule structure. |
| **equal-template MO** | MO that checks equality and extracts variables. | Matching Operator (MO). | `Direct` | Aligned. Part of the C/D rule. | Aligned. | In standard SCHC, MO only performs matching (returns a boolean) and does not extract substrings or generate residue. Here, the MO is coupled with residue extraction. | Custom MO allowed by the architecture. |
| **Template-less payload fields** | Individual structured fields. | Field Identifiers (FIDs). | `Direct` | Aligned. Part of the Context's SoR. | Maligned. A static rule cannot naturally handle variable-length arrays in template-less mode. | FIDs in standard SCHC refer to well-defined protocol headers, whereas here they encode dynamic paths and array indices. | Non-normative semantics. |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| **ownership of Context** | Associated with the SCHC node. | Shared between two or more Instances in a Session, managed by the Domain Manager / Context Repository. | Aligned | The draft's rules can be deployed as part of the Context shared between Instances. |
| **ownership of Set of Rules** | Embedded in the SCHC node's rule set. | Owned by the Instance (part of Context). | Aligned | No issues. |
| **ownership of Set of Variables** | Not explicitly mentioned. | Maintained per Session by the Instance. | Aligned | The draft does not define session state, so standard session variables apply. |
| **Endpoint↔SCHC Instance** | Implicitly 1:1 ("SCHC node"). | 1:N (Endpoint can host multiple Instances). | Aligned | Terminology in the draft must be updated from "SCHC node" to "SCHC Instance". |
| **SCHC Instance↔Session** | Not defined; assumes peer-to-peer. | 1:N (Instance can have multiple Sessions, e.g., shared gateway). | Aligned | No issues. |
| **sharing of Context between Sessions/Instances** | Not mentioned. | Context can be shared across Sessions (with distinct SoVs). | Aligned | No issues. |
| **RuleID scope** | Unique within the rule set. | Unique within the Domain/Context of the Session. | Aligned | No issues. |
| **Discriminator scope** | Not mentioned. | Used by Dispatcher to route to correct Instance. | Aligned | Standard discriminators can be used. |
| **Control Header processing scope** | Not mentioned. | Processed before/after RuleID to select Instance or retain metadata. | Aligned | Control Headers can be used. |
| **Domain membership and boundaries** | Not mentioned. | Group of Instances sharing Contexts. | Aligned | No issues. |

## Challenged mappings

| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| **equal-template MO** | Direct (to MO) | In standard SCHC, the MO only returns a boolean. Here, `equal-template` extracts substrings and passes them to the CDA, violating the separation of concern between MO and CDA. | **Partial** | The coupling of matching and extraction requires the C/D engine to pass state from MO to CDA, which is a conceptual extension of the standard MO role. |
| **Template variable / function** | Profile-specific (to TV) | TV in standard SCHC is a static target value. Storing a template with variables and functions in the TV requires the C/D engine to parse a template grammar, which is a significant extension of TV's conceptual model. | **Partial** | TV is no longer a static value; it represents a grammar that requires parser integration. |
| **Template-less payload fields** | Direct (to FIDs) | If the payload array length is dynamic, static FIDs cannot represent it without dynamic rule generation. | **Partial** | FIDs are static in the architecture. Dynamic array indexing in FIDs violates the static context assumption of SCHC. |

## Architectural risk points
- **Risk:** Tight coupling between Matching Operator (MO) and Compression/Decompression Action (CDA).
  - **Why it matters:** The SCHC framework (RFC 8724) decouples matching (MO) from compression (CDA). The `equal-template` MO breaks this decoupling by extracting substrings that are then encoded in the residue, which is typically the responsibility of the CDA.
  - **Consequence for migration:** Implementations must modify their core C/D engine execution pipeline to pass extracted variables from the MO to the CDA, rather than treating them as independent steps.
- **Risk:** Static Context limitation with dynamic JSON payloads.
  - **Why it matters:** Template-less compression uses FIDs like `payload:application/json:1:id` which encode array indices. If a JSON array has a variable number of elements, a static Set of Rules cannot represent it unless it contains rules for all possible indices.
  - **Consequence for migration:** Template-less compression is highly restricted and cannot naturally handle dynamic payloads. Operators must either use template-based compression or restrict payloads to fixed structures.
- **Risk:** Parser complexity and scope.
  - **Why it matters:** Delineating payload fields requires the Parser to understand application-level serialization formats (e.g., JSON). This increases the complexity of the Parser in the Context compared to simple protocol header parsing.
  - **Consequence for migration:** The Context must explicitly define the JSON parser and schema, and the C/D engine must support application-layer parsing.

## Needed modifications to the draft under study

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

## Needed modifications to SCHC Architecture -06

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

## Final migration assessment
- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly**
- Does the draft expose a SCHC Architecture -06 gap? **Yes**
- Is the gap required for this draft or merely useful generally? **Required for this draft**
- What is the single most important migration issue? **Rewording the core architecture's "header-only" definitions (C/D, Stratum, and C/D engine steps) to include "payloads", and addressing the tight coupling between the equal-template MO and CDA execution.**
