# Evidence Notes: draft-pelov-schclet-architecture-02

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

- **Can SCHC Architecture -06 naturally express the draft?** Yes. SCHC Architecture -06 already explicitly defines and incorporates the concept of a `SCHClet` (both in Terminology and focus sections) and defines the `Instance` and `Context` concepts in a way that fully accommodates modular subfunctions.
- **Principal conceptual mapping:** The draft's native concept of a `SCHClet` maps directly to -06's `SCHClet` component, which executes a subset of SCHC functions within an `Instance`.
- **Principal migration difficulty:** The draft references a non-existent "SCHC Stratum Header" and "SCHC Stratum Instance", which must be rephrased to use -06's "Control Header" and "Instance" concepts.
- **Does an Architecture gap exist?** No.

### Architectural risk points

- **Risk: References to "SCHC Stratum Header"**
  - **Why it matters:** The draft repeatedly refers to the "SCHC Stratum Header" as if it were a core part of the SCHC Architecture that must be elided, which could confuse implementers looking for this header in the Architecture specification.
  - **Consequence for migration:** These references must be removed or renamed to "Control Header" to avoid referencing non-existent concepts.
- **Risk: Overloading of "SCHClet" as both a specification tool and an implementation unit**
  - **Why it matters:** Implementers might assume a SCHClet is a distinct physical process, whereas architecturally it is just a modular subset of SCHC functions within a single Instance.
  - **Consequence for migration:** The draft should clarify that a SCHClet is a logical component of an Instance, and its boundary is defined by its configuration.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 4.1, page 6 | "...a SCHC Stratum Instance MAY be defined as a SCHClet..." | Replace "SCHC Stratum Instance" with "SCHC Instance operating on a specific Stratum". | **REQUIRED FOR CONCEPTUAL ALIGNMENT** | -06 does not define a "Stratum Instance", only "Instance" and "Stratum" as separate concepts. |
| 2 | Section 1, page 3 | "...the SCHC Architecture introduces the notions of SCHC Stratum Header, SCHC Instance and Discriminator..." | Replace "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | -06 does not define a "Stratum Header"; it uses "Control Header" for optional metadata or multiplexing. |
| 3 | Section 3.1, page 5 | "The notions of SCHC Stratum Header, SCHC Instance, and Discriminator MAY be omitted." | Replace "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Consistent terminology migration to match -06. |
| 4 | Section 4.1, page 6 (Title and Text) | "4.1. SCHC Stratum Header, SCHC Instance, Discriminator" and references to "SCHC Stratum Header" | Rename section to "4.1. Control Header, SCHC Instance, Discriminator" and replace occurrences of "SCHC Stratum Header" with "Control Header". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Corrects references to non-existent architecture headers. |
| 5 | Section 5.1, page 6 | "...focusing solely on compression without engaging in rule management or SCHC Stratum functions." | Replace "SCHC Stratum functions" with "multi-stratum operations". | **REQUIRED FOR TERMINOLOGY MIGRATION** | Aligns with the -06 concept that a SCHClet operates on a single Stratum. |
| 6 | Section 2, page 4 | Definition of "SCHClet" | Align the definition verbatim with -06 Terminology: "A self-contained modular unit within the SCHC framework that implements a specific SCHC function or a subset of SCHC operations." | **OPTIONAL CLARIFICATION** | Ensures absolute terminology alignment between the two specifications. |
| 7 | Section 8, page 12 | No reference to draft-ietf-schc-architecture | Add normative reference to `draft-ietf-schc-architecture-06`. | **EDITORIAL** | The draft relies heavily on concepts defined in the architecture document. |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes**
- Can the migration be performed mechanically? **Mostly** (requires minor rephrasing of "Stratum Header" references)
- Does the draft expose a SCHC Architecture -06 gap? **No**
- Is the gap required for this draft or merely useful generally? **N/A** (no gap exists)
- What is the single most important migration issue? **The draft's references to the non-existent "SCHC Stratum Header" must be migrated to refer to -06's "Control Header" concept.**
