# Architectural alignment review: rfc8824

## Verdicts
- Conceptual equivalence: Very High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration

| Criterion | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | Very High | Highest grade | All RFC 8824 concepts (Device, NGW, App, standalone CoAP C/D, boundary C/D, OSCORE 2-stage inner/outer compression, asymmetric rules using DI, repeatable options using FP, parameter functions like `tkl`) map cleanly and naturally into SCHC Architecture -06 without any substantive reinterpretation of technical behavior. |
| Transition difficulty | Easy | Updating Section 2 (Figures 1–3) and Section 7.2 (OSCORE two-stage compression) requires light architectural rewording to explicitly frame entities as Endpoints, Instances, Sessions, and Strata, rather than relying strictly on simple string replacement. | The migration requires no technical redesign, protocol alteration, or rule structure changes. Mapping decisions are clear, repeatable, and completely preserve RFC 8824's normative requirements. |
| SCHC Architecture adaptation need | None | Highest grade | All required architectural concepts (Endpoint, Instance, Session, Domain, Stratum, Context, Rule, Dispatcher, Discriminator, Control Header) are already present and fully defined in SCHC Architecture -06. Zero ARCHITECTURE GAP items exist. |

## Executive assessment

SCHC Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally, completely, and elegantly express all technical concepts, protocol behaviors, and deployment topologies specified in RFC 8824 ("Static Context Header Compression (SCHC) for the Constrained Application Protocol (CoAP)"). 

The principal conceptual mapping maps RFC 8824's communication actors (**Device**, **Network Gateway (NGW)**, **Application Server**) to **Endpoints**, its SCHC C/D execution functions to **Instances**, its communication associations to **Sessions**, and its administrative provisioning sources to **Domains**. Furthermore, RFC 8824's advanced OSCORE two-stage compression model naturally maps to two SCHC **Instances** operating at distinct **Strata** (Inner CoAP Stratum and Outer CoAP Stratum) on the participating Endpoints.

The migration difficulty is **Easy**. The technical behavior and rule mechanisms remain 100% unchanged. Updating RFC 8824 to -06 terminology requires replacing older RFC 8724-centric phrasing with -06 terminology (Endpoints, Instances, Sessions, Domains, Strata) across introductory, applicability, and OSCORE sections.

No modification to SCHC Architecture -06 is required (Adaptation Need: **None**). -06 was designed as a generalized architecture that encompasses RFC 8724 and its application profiles including RFC 8824.

## Native conceptual model

| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| Device (Dev) | Constrained physical or logical node originating or terminating CoAP messages | Physical constrained device / LPWAN node | Link-local / End-to-end | DevEUI / IPv6 Address / L2 ID | 1 Device : N SCHC Instances / Contexts | Acts as CoAP Client, Server, or both |
| Network Gateway (NGW) | Boundary gateway node performing SCHC C/D between LPWAN and IP network | LPWAN Network Gateway / Boundary router | LPWAN boundary | Gateway ID / IP Address | 1 NGW : N Devices / N Sessions | Decompresses uplink packets for IP forwarding; compresses downlink |
| Application (App) | Remote host or server communicating with Device via CoAP over IP | Remote Server / Cloud Host | End-to-end (IP network) | IPv6/IP Address + UDP Port | 1 App : N Devices / N Sessions | Executes SCHC C/D end-to-end (standalone CoAP or OSCORE) |
| SCHC Instance / C/D Engine | Functional entity executing SCHC compression and decompression algorithms | Device, NGW, or App | Processing-local | Context / Rule set binding | 1 Endpoint : N SCHC Instances | Can process full stack, standalone CoAP, or OSCORE inner/outer headers |
| Static Context | Shared static information containing Rules for header compression | Shared between Device and NGW/App | Shared peer-pair / session | Context ID / Implicit | 1 Context : N Rules; Shared between 2+ communicating nodes | Provisioned out-of-band prior to packet exchange |
| Rule | Ordered collection of Field Descriptors defining matching and C/D actions | Resides inside Static Context | Context-local | RuleID | 1 Rule : N Field Descriptors | Identified on the wire by RuleID |
| Field Descriptor | Structure defining FID, FL, FP, DI, TV, MO, and CDA for a target field | Resides inside a Rule | Rule-local | Field ID (FID) + FP + DI | 1 Field Descriptor : 1 target header field | Specifies match operator and compression action |
| Direction Indicator (DI) | Tag indicating packet direction (Upstream, Downstream, Bidirectional) | Attribute of Field Descriptor | Field Descriptor-local | DI value (Up, Dw, Bi) | 1 Field Descriptor : 1 DI | Enables request and response matching in a single Rule |
| Field Position (FP) | Ordinal index distinguishing multiple occurrences of repeatable fields | Attribute of Field Descriptor | Rule / Header-local | FP index (1, 2, 3...) | 1 FID + FP : 1 specific field occurrence | Resolves ambiguity in repeatable options (Uri-Path, Uri-Query) |
| `tkl` Function | Special length function returning Token Length value for Token residue parsing | SCHC C/D Engine / Field Descriptor | Field Descriptor-local | Function name `tkl` | 1 `tkl` : 1 Token Value Field Descriptor | Eliminates residue parsing ambiguity for variable-length Token |
| OSCORE Inner SCHC C/D | Compression of inner CoAP header/options before AEAD encryption | Device and App (OSCORE endpoints) | End-to-end (Inner Plaintext) | Inner RuleID | 1 Inner C/D : 1 Inner Plaintext | Yields Inner RuleID + Residue, encrypted into OSCORE Ciphertext |
| OSCORE Outer SCHC C/D | Compression of outer CoAP header and OSCORE options after encryption | Device and App (or NGW) | End-to-end / Boundary (Outer Message) | Outer RuleID | 1 Outer C/D : 1 Outer Message | Compresses outer header including synthetic OSCORE option fields |
| OSCORE Synthetic Fields | Deconstruction of OSCORE option into flags, piv, kidctx, and kid fields | Outer SCHC C/D Field Descriptors | OSCORE Option-local | FIDs: OSCORE_flags, OSCORE_piv, OSCORE_kidctx, OSCORE_kid | 1 OSCORE Option : 4 Synthetic FIDs | Enables bit-level MSB/LSB compression of OSCORE option elements |
| Provisioning Domain | Administrative origin/source providing SCHC rules to an instance | Management / Administrative entity | Administrative Domain | Domain ID / Authority | 1 Provisioning Domain : N Contexts / Rules | Multiple SCHC instances on a node may use different provisioning domains |

### Native architectural model

RFC 8824 defines the application of Static Context Header Compression (SCHC), as established in RFC 8724, to the Constrained Application Protocol (CoAP, RFC 7252) and its key extensions (Block-wise transfers RFC 7959, Observe RFC 7641, No-Response RFC 7967, and OSCORE RFC 8613). CoAP operates at the application layer and features flexible, variable-length, and optional header fields (such as Type-Length-Value options and variable Token lengths), as well as asymmetric request/response message formats.

The native model of RFC 8824 revolves around three main network actors: the **Device (Dev)**, the **Network Gateway (NGW)**, and the **Application (App)**. SCHC compression and decompression functions (SCHC C/D) are performed at different points in the topology depending on the deployment scenario:

1. **LPWAN Boundary Compression:** The Device and NGW perform SCHC C/D across the LPWAN link for the full protocol stack (IPv6, UDP, and CoAP). The NGW decompresses packets and forwards native IPv6/UDP/CoAP packets over the Internet to the App, which remains unaware of SCHC.
2. **Standalone CoAP End-to-End Compression:** SCHC C/D for CoAP is performed directly between the Device and the App at the application layer. The compressed CoAP payload and residue may be protected by transport security (e.g. DTLS), while lower layers (IPv6/UDP) may independently use SCHC over the LPWAN link.
3. **OSCORE End-to-End Compression:** When OSCORE is used, CoAP messages are split into an Inner Plaintext (containing sensitive options and payload) and an Outer Header (containing routing options and the OSCORE option). RFC 8824 defines a two-stage sequential SCHC compression process: Inner SCHC C/D compresses the Inner Plaintext before AEAD encryption, and Outer SCHC C/D compresses the Outer Header (including synthetic OSCORE option fields) after encryption.

To handle CoAP's header structure, RFC 8824 leverages and extends RFC 8724 mechanisms. Direction Indicators (DI) allow a single Rule to express asymmetric request and response formats. Field Positions (FP) disambiguate repeatable options such as Uri-Path and Uri-Query. Variable-length fields use specific length functions like `tkl` to bind the Compression Residue size of the Token Value to the Token Length field, preventing parsing ambiguity. Finally, the OSCORE option is conceptually decomposed into four synthetic fields (OSCORE_flags, OSCORE_piv, OSCORE_kidctx, OSCORE_kid) to allow fine-grained bitmask and MSB/LSB compression.

Static Contexts containing these Rules are assumed to be provisioned out-of-band prior to communication, potentially originating from different provisioning domains when multiple SCHC instances coexist on a device.

## Concept mapping

| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| Device (Dev) | Constrained node originating/terminating CoAP traffic | Endpoint | Direct | Full (Node level) | 1 Node : 1 Endpoint (or N Instances) | None | Direct architectural equivalence |
| Network Gateway (NGW) | LPWAN boundary gateway node executing SCHC C/D | Endpoint | Direct | Full (Boundary node) | 1 Gateway : 1 Endpoint | None | Acts as SCHC Endpoint hosting Gateway Instances |
| Application (App) | Remote host communicating with Device via CoAP | Endpoint | Direct | Full (Host level) | 1 Host : 1 Endpoint | None | Acts as SCHC Endpoint hosting App Instances |
| SCHC Instance / C/D Engine | Component executing SCHC C/D operations | Instance | Direct | Full (Execution unit) | 1 Endpoint : N Instances | None | Direct functional equivalence |
| Static Context | Collection of Rules shared between communicating entities | Context | Direct | Full (Shared state) | 1 Context : N Rules | None | Direct architectural equivalence |
| Rule | Ordered Field Descriptors specifying header C/D | Rule | Direct | Full (Rule level) | 1 Context : N Rules | None | Direct structural equivalence |
| Field Descriptor | Entry defining FID, FL, FP, DI, TV, MO, CDA | C/D Field Descriptor | Direct | Full (Field level) | 1 Rule : N Field Descriptors | None | Direct structural equivalence |
| Direction Indicator (DI) | Packet direction tag (Up, Dw, Bi) for asymmetric matching | Field Descriptor Property / Instance Role | Direct | Full (Field/Rule level) | 1 Field Descriptor : 1 DI | None | Standard RFC 8724 / -06 rule element |
| Field Position (FP) | Index for repeatable option instance | Field Descriptor Property | Direct | Full (Field level) | 1 FID + FP : 1 field instance | None | Standard RFC 8724 / -06 rule element |
| `tkl` Function | Function returning Token Length value for Token Residue size | Context metadata / Parser function | Profile-specific | Full (Instance/Context level) | 1 `tkl` : 1 Token field | None | Natural use of -06 Context Parser / Data Model |
| OSCORE Inner SCHC C/D | Compression of inner CoAP header before AEAD encryption | Instance at Inner CoAP Stratum | Composite | Full (Inner Stratum) | 1 Endpoint : N Instances | None | Expressed as Instance operating on Inner CoAP Stratum |
| OSCORE Outer SCHC C/D | Compression of outer CoAP header + OSCORE options after encryption | Instance at Outer CoAP Stratum | Composite | Full (Outer Stratum) | 1 Endpoint : N Instances | None | Expressed as Instance operating on Outer CoAP Stratum |
| OSCORE Synthetic Fields | OSCORE option split into 4 fields for compression | C/D Field Descriptors / Parser Delineation | Profile-specific | Full (Context level) | 1 OSCORE Option : 4 FIDs | None | Natural use of Context Data Model / Field dissection |
| Provisioning Domain | Administrative source of SCHC rules | Domain / Domain Manager | Direct | Full (Admin grouping) | 1 Domain : N Contexts/Instances | None | Direct architectural equivalence |
| Device <-> NGW / App Link | Communication pair sharing Context for SCHC exchange | Session | Direct | Full (Communication level) | 1 Session : 2+ Instances | None | Direct architectural equivalence |
| RuleID | Identifier for selected Rule on wire | RuleID | Direct | Full (Wire ID) | 1 Rule : 1 RuleID | None | Direct structural equivalence |

## Scope and cardinality comparison

| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| Ownership of Context | Context shared between Device and NGW/App; configured out-of-band | Context shared by Instances in a Domain, managed by Domain Manager | Full | Identical concept; -06 clarifies management by Domain Manager |
| Ownership of Set of Rules (SoR) | SoR defines matching rules inside the static context | SoR is contained within Context, executed by Instance | Full | Completely aligned |
| Ownership of Set of Variables (SoV) | Implicit per-communication state (timers, sequence numbers) | SoV maintained per Session by Instance | Full | -06 explicitly formalizes per-Session runtime state |
| Endpoint ↔ SCHC Instance | Device/NGW/App host SCHC C/D process; multiple processes allowed | Endpoint hosts 1 or N independent Instances | Full | -06 provides precise multi-instance execution model |
| SCHC Instance ↔ Session | Communication pair uses SCHC instance(s) | Session is active communication between Instances sharing Context | Full | Completely aligned |
| Sharing of Context between Sessions/Instances | Same static context can be shared across multiple peer devices or instances | Multiple Instances/Sessions in a Domain can share same Context | Full | -06 explicitly supports shared Context across Instances |
| RuleID scope | Unique within shared static context between two communicating entities | Unique within the Context available to an Instance | Full | Completely aligned |
| Discriminator scope | Derived from lower-layer context (IPv6 prefix, DevEUI, FPort, UDP port) | Discriminator used by Dispatcher to route Datagrams to correct Instance | Full | Completely aligned |
| Control Header processing scope | Not explicitly framed as Control Header in RFC 8824; OSCORE outer options act as framing | Control Header carries out-of-band or routing info processed before/after C/D | Full | OSCORE outer options naturally map to Control Header or Outer Stratum |
| Domain membership and boundaries | Rules may come from different "provisioning domains" | Instances belong to Domains managed by Domain Managers | Full | Direct alignment; -06 formalizes Domain boundaries |

## Challenged mappings

No mapping classification changed during the adversarial pass.

## Architectural risk points

- **Risk:** In OSCORE deployments, inner and outer SCHC compression stages execute sequentially on the same physical host, using distinct rule sets that may originate from different provisioning domains.
  - **Why it matters:** If an implementation fails to isolate the Inner and Outer SCHC processing engines into distinct SCHC Instances (or distinct Strata), RuleID collisions or improper field matching could occur.
  - **Consequence for migration:** The migration text in Section 7.2 must explicitly frame Inner SCHC C/D and Outer SCHC C/D as two separate SCHC Instances operating at the Inner CoAP Stratum and Outer CoAP Stratum, respectively.

- **Risk:** Dynamic residue length evaluation for the Token field depends on the `tkl` parameter function linking Token Length and Token Value.
  - **Why it matters:** The decompressor must preserve parsed state from the Token Length field descriptor to correctly bound the Token Value residue.
  - **Consequence for migration:** No change to draft behavior; document as a standard Context Parser requirement under -06.

## Needed modifications to the draft under study

| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | Section 1, Para 2 & 3 | Mentions "both endpoints know the static context" and "two SCHC instances". | Reframing text to explicitly state that SCHC Endpoints host SCHC Instances that communicate within a SCHC Session using a shared Context. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns introductory text with SCHC Architecture -06 core terminology. |
| 2 | Section 2, Paras 1–6 & Figures 1–3 | Describes Device, NGW, and App exchanging SCHC packets across LPWAN boundary or end-to-end, and mentions "provisioning domains". | Update narrative for Figures 1, 2, and 3 to clarify that Device, NGW, and App act as SCHC Endpoints hosting SCHC Instances. Clarify that "provisioning domains" correspond to SCHC Domains under a Domain Manager. | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns architectural applicability models with -06 Endpoint, Instance, Session, and Domain concepts. |
| 3 | Section 7.2 & Figure 7 | Describes OSCORE compression as two SCHC stages (Inner SCHC Compression and Outer SCHC Compression). | Rephrase narrative to explain that OSCORE compression uses two SCHC Instances operating at distinct Strata (Inner CoAP Stratum and Outer CoAP Stratum) on the participating Endpoints. | REQUIRED FOR TERMINOLOGY MIGRATION | Clarifies multi-instance and multi-stratum architectural execution for OSCORE. |
| 4 | Section 3.1 & Section 4 | References "Device", "compressor", and "decompressor". | Replace generic "Device" / "compressor" references with "SCHC Instance" / "Endpoint" where referring to execution roles. | REQUIRED FOR TERMINOLOGY MIGRATION | Ensures consistent use of -06 terminology throughout specification. |
| 5 | Section 1.1 | Terminology section referencing RFC 2119 / RFC 8174. | Add reference to `draft-ietf-schc-architecture-06` for SCHC architectural terminology (Endpoint, Instance, Session, Context, Domain, Stratum). | OPTIONAL CLARIFICATION | Improves document clarity and normative terminology grounding. |

## Needed modifications to SCHC Architecture -06

| # | Architecture section | Architecture concept | Current text or definition | Proposed change | Category (ARCHITECTURE GAP / OPTIONAL CLARIFICATION) | Rationale |
|---|---|---|---|---|---|---|
| 1 | N/A | N/A | N/A | None | N/A | SCHC Architecture -06 already fully expresses all concepts, relationships, and mechanisms of RFC 8824. Zero ARCHITECTURE GAP items exist. |

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? N/A (no gap)
- What is the single most important migration issue? Updating introductory architectural applicability text (Section 2, Figures 1–3) and the OSCORE two-stage compression narrative (Section 7.2) to explicitly use SCHC Architecture -06 terms (Endpoint, Instance, Session, Domain, Stratum).

No modification to SCHC Architecture -06 is required.
