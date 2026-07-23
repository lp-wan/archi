# Evidence Notes: draft-ietf-schc-over-ppp-00

## analysis-gemini
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

The Static Context Header Compression (SCHC) Architecture -06 can naturally express the draft under study (`draft-ietf-schc-over-ppp-00`) without any conceptual stretching. The principal mapping relates the PPP session to a SCHC Session between two SCHC Instances hosted on SCHC Endpoints, where the PPP connection itself serves as the Discriminator used by the Dispatcher. The principal transition difficulty is editorial: introducing the concepts of "Instance", "Dispatcher", and "Discriminator" (which are absent in the draft) and clearly distinguishing between physical/link-layer endpoints and logical SCHC Endpoints. No architectural gaps exist in `draft-ietf-schc-architecture-06` with respect to this draft.

### Architectural risk points

- **Risk:** Conflation of physical/link-layer nodes with logical SCHC Endpoints and Instances.
  **Why it matters:** The draft attributes C/D and F/R functions directly to the "endpoints" (which it defines as the IP Host or serial DTE/DCE). In the architecture, these functions are executed by SCHC Instances hosted on logical Endpoints, and a physical node can host multiple such Endpoints or Instances. Failing to distinguish this could limit implementations that want to run multiple independent SCHC sessions (e.g., over multiple virtual PPP tunnels or different protocol layers) on the same host.
  **Consequence for migration:** The draft's terminology needs to be updated to introduce the concepts of "Instance", "Dispatcher", and "Discriminator" and explain how they map to the PPP link and PPP session.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 3, Page 3 | "a PPP session defines a vitual link where a SCHC context is established..." | Rephrase to specify that a PPP session maps to a SCHC Session between two SCHC Instances, sharing a common Context. | REQUIRED FOR TERMINOLOGY MIGRATION | To align the description of the PPP connection with the Session and Instance concepts in -06. |
| 2 | Section 4.1, Page 4 | "This specification leverages SCHC between an end point that is an IP Host ... and another that is an IP Node ... Both endpoints MUST support the function of SCHC Compressor/ Decompressor (C/D) as shown in Figure 2." | Update to state that each peer hosts a SCHC Endpoint with a SCHC Instance running the C/D (and optionally F/R) functions. Rephrase "endpoints" in the physical sense to "peer nodes" or "hosts," and reserve "Endpoint" for the logical SCHC Endpoint. | REQUIRED FOR TERMINOLOGY MIGRATION | To align with the logical Endpoint and Instance definitions in -06, preventing conflation of physical nodes with logical SCHC entities. |
| 3 | Section 4.1, Page 4 | "Both endpoints MUST support the function of SCHC Compressor/ Decompressor (C/D) as shown in Figure 2." | Replace Figure 2 with an updated diagram showing SCHC Instances hosted on SCHC Endpoints within the IP Host and IP Router, with the PPP link serving as the discriminator. | REQUIRED FOR TERMINOLOGY MIGRATION | To reflect the -06 component architecture visually. |
| 4 | Section 3, Page 4 | "If the encoding is asymetrical, the initiator of the session is considered downstream, playing the role of the device in an LPWAN network." | Rephrase to state that the initiator's Instance plays the Downside (Device) role and the responder's Instance plays the Upside (Network) role. | REQUIRED FOR TERMINOLOGY MIGRATION | To align role names with the -06 terminology (Downside/Upside). |
| 5 | Section 4.1, Page 4 | "A context may be generated for a particular upper layer application... The context can be asymetric, e.g., when connecting a primary and a secondary endpoints..." | Rephrase "endpoints" to "Instances" or "peer nodes" where appropriate. | REQUIRED FOR TERMINOLOGY MIGRATION | Consistent use of -06 terminology. |
| 6 | Section 4.1, Page 4 (New Subsection) | N/A | Add a new subsection 4.1.1 "Architectural Mapping" describing the Dispatcher and Discriminator. Specify that the PPP connection itself serves as the Discriminator, and the Dispatcher routes incoming PPP packets with Protocol 0x0057 to the corresponding SCHC Instance. | REQUIRED FOR TERMINOLOGY MIGRATION | To describe the multiplexing and routing in terms of the -06 architecture components (Dispatcher/Discriminator). |

### Needed modifications to SCHC Architecture -06

No modification to SCHC Architecture -06 is required.

### Final migration assessment

- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A
- What is the single most important migration issue? The need to introduce the concepts of "Instance", "Dispatcher", and "Discriminator" into the draft and clearly distinguish between logical SCHC Endpoints/Instances and physical/L2 PPP nodes.

## analysis-claude
Verdicts: {'conceptual': 'Very High', 'transition': 'Easy', 'adaptation': 'None'}

### Executive assessment

SCHC Architecture -06 can **naturally and completely express** draft-ietf-schc-over-ppp-00. The
draft describes a two-peer, point-to-point (peer-to-peer) SCHC deployment in which a PPP session
establishes a virtual link, a SCHC context with a particular set of Rules is provisioned on both
ends (its URI signaled through an IPV6CP option extended from RFC 5172), both peers run SCHC
Compression/Decompression, optional No-ACK fragmentation is available, and — when Rules are
asymmetric — the session initiator takes the Device role.

The principal conceptual mapping is: **PPP session → SCHC Session; each peer node → Endpoint with
one Instance bound to the PPP connection; per-session SCHC context + set of Rules → Context/SoR;
PPP protocol demultiplexing → Dispatcher using the PPP connection as Discriminator; initiator =
Device → the -06 role convention.** This mapping is not merely plausible — SCHC Architecture -06
already documents it as its own PPP deployment example (Appendix A.2.2, Table 3), citing this
draft directly.

The principal migration difficulty is purely presentational: the draft (written against the older
`draft-pelov-lpwan-architecture-02`) treats "a SCHC context per PPP session" as a single notion,
whereas -06 factors it into Session (the communication), Instance (the processing) and
Context/SoR (the shared state). Making that factoring explicit requires local rewording in a
handful of sentences, plus updating the architecture citation. No technical behavior changes.

**No Architecture gap exists.** The adaptation verdict is None; File 2 therefore states that no
change to -06 is required, and because conceptual equivalence is Very High and transition is Easy,
a complete terminology-migration diff is provided in File 3.

### Architectural risk points

Not present.

### Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | §3, first sentence (lines 145–147) | "a PPP session defines a vitual link where a SCHC context is established with a particular set of Rules" | State that each PPP session carries a SCHC **Session** over a virtual link; each peer's **Endpoint** binds one **Instance** to the PPP session; the Instances share a common **Context** whose **Set of Rules** is indicated at setup | REQUIRED FOR TERMINOLOGY MIGRATION | Makes the -06 Session/Instance/Context factoring explicit; no behavioral change |
| 2 | §3, last sentence (lines 179–181) | "If the encoding is asymetrical, the initiator of the session is considered downstream, playing the role of the device in an LPWAN network." | "If the Rules are asymmetric, the SCHC Instance that initiates the PPP session plays the role of the Device defined in [SCHC], following the role convention of the SCHC Architecture." (drop "in an LPWAN network") | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with -06 §4.2.1.1 role convention; generalizes Device role beyond LPWAN; same outcome |
| 3 | §4.1, first paragraph (lines 191–196) | "leverages SCHC between an end point that is an IP Host … and another that is an IP Node …" | Recast each side as a SCHC **Endpoint** (hosted on the IP Host/DTE and on the IP Node/DCE/Ethernet device respectively) that associates one **Instance** with the PPP connection | REQUIRED FOR TERMINOLOGY MIGRATION | Distinguishes logical Endpoint/Instance from the physical node; matches A.2.2 |
| 4 | §4.1, "Both endpoints MUST support the function of SCHC Compressor/Decompressor (C/D)" (lines 198–199) | endpoints support C/D | "The Instance on each Endpoint MUST support the SCHC Compression/Decompression (C/D) function." Add: the PPP connection is the **Discriminator** and PPP demultiplexing is the **Dispatcher** | REQUIRED FOR TERMINOLOGY MIGRATION | Names the -06 Dispatcher/Discriminator already implied by PPP demux (§4.2.2.4, A.2.2) |
| 5 | §4.1, "A context may be generated … The context can be asymetric" (lines 218–231) | asymmetric "context" | "A **Context** may be generated … the Context may contain **asymmetric Rules**, in which case the two Instances play distinct roles." Capitalize "Context" | REQUIRED FOR TERMINOLOGY MIGRATION | Uses -06 Context term; asymmetry is a property of Rules/roles, not of a separate object |
| 6 | §4.2, RuleID numbering scheme heading text (lines 239–252) and Figure 3 caption | "A SCHC compressed packet is always in the form" / "SCHC Compressed Packet" | Refer to the wire unit as a **SCHC Datagram** (RuleID + Compression Residue + Payload), per -06 §4.2.5 | REQUIRED FOR TERMINOLOGY MIGRATION | -06 defines "Datagram" as exactly this structure; keeps the compressed-header content unchanged |
| 7 | Introduction (lines 106–108) and Informative References (lines 509–514) | Cites "[I-D.pelov-lpwan-architecture]" (draft-pelov-lpwan-architecture-02) | Cite `[I-D.ietf-schc-architecture]` (draft-ietf-schc-architecture-06) with updated author list/date | REQUIRED FOR TERMINOLOGY MIGRATION | The architecture has been adopted and renamed; terminology in this migration derives from -06 |
| 8 | §3 (lines 176–178) and Informative References | "Data Model for SCHC" [SCHC_DATA_MODEL], draft-ietf-lpwan-schc-yang-data-model-21 | Update to the published **RFC 9363** ("A YANG Data Model for SCHC"), consistent with -06 | OPTIONAL CLARIFICATION | The YANG model is now an RFC; -06 references RFC 9363. Improves currency, not required for the mapping |
| 9 | §4.1 (lines 212–216) | "The SCHC Fragmenter/Reassembler (F/R) is generally not needed …" | Optionally note F/R is the -06 F/R function, "typically fixed by the deployment or profile" (No-ACK here) | OPTIONAL CLARIFICATION | Ties the profile choice to -06 §4.2.2.2 wording; the technical content is already correct |
| 10 | Throughout | "vitual", "echange", "asymetrical", "protocol-independant", "provisionned" | Fix spelling | EDITORIAL | Typos; no semantic effect |

### Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| — | — | — | — | *None* | — | -06 already contains a worked PPP deployment (Appendix A.2.2, Table 3) that expresses every concept this draft needs. No architectural concept, relationship, or scope must be added, removed, or re-scoped to accommodate draft-ietf-schc-over-ppp-00. |

*(No OPTIONAL CLARIFICATION to -06 is necessary either: Appendix A.2.2 and §4.2.1.1 already cover
the peer-to-peer role convention, the one-Instance-per-PPP-connection cardinality, Context fetched
on demand, and the Discriminator-from-lower-layer case.)*

### Final migration assessment

- Can the draft be migrated without changing technical behavior? **Yes** — every proposed change is
  terminology/framing; the RuleID numbering, No-ACK fragmentation, padding, MAX_PACKET_SIZE, and
  the IPV6CP/URI signaling are unchanged.
- Can the migration be performed mechanically? **Mostly** — most of the document (the profile
  parameters) is untouched; the Session/Instance/Context re-framing in ~5 sentences requires clear
  but non-mechanical local rewriting, guided directly by -06 §4.2.1.1 and Appendix A.2.2.
- Does the draft expose a SCHC Architecture -06 gap? **No.**
- Is the gap required for this draft or merely useful generally? **Not applicable** — there is no
  gap. -06 already documents this exact deployment.
- What is the single most important migration issue? Explicitly factoring the draft's single
  "SCHC context per PPP session" into the -06 triplet Session (communication) / Instance
  (processing) / Context+SoR (shared state), so the migrated text does not re-conflate them.

No modification to SCHC Architecture -06 is required.
