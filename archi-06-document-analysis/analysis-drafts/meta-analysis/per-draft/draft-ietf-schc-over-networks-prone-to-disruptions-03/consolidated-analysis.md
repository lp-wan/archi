# Consolidated SCHC Architecture Alignment: draft-ietf-schc-over-networks-prone-to-disruptions-03

## Final Minimal -07 Decision
Not included in final minimal -07: Split F/R relay or proxy Architecture changes are deferred for author discussion.

## Consolidated Verdicts
- Conceptual equivalence: Medium
- Transition difficulty: Medium
- SCHC Architecture adaptation need: Significant
- Claude/Gemini incompatibility: Yes

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Medium | Medium | Significant | No | No |
| Claude | High | Easy | Trivial | Yes | Yes |

## Agreement and Differences
Claude and Gemini are marked **incompatible**: architecture adaptation differs materially (Significant vs Trivial).

## Final Consolidated Assessment
SCHC Architecture -06 can only partially express the concepts and technical model of draft-ietf-schc-over-networks-prone-to-disruptions-03. While the basic cellular Zero Energy (ZE) topologies and LPWA caching/timer behaviors map naturally to -06, the draft introduces two key concepts that cannot be naturally expressed without architectural stretching or modification. SCHC Architecture -06 **can naturally express** the draft under study. The draft describes SCHC deployments over disruption-prone networks (cellular Zero-Energy / Ambient IoT devices and Direct-to-Satellite IoT), and its technical model — a constrained device and a network-side SCHC termination sharing a static context, with delay-adapted F/R parameters, an optional on-path SCHC proxy, object (rather than IP-packet) transport, payload compression, and pre-provisioned parameter sets selected by identifiers — decomposes cleanly onto -06's Endpoint / Instance / Context / Session / Domain / Discriminator / Instance Configuration / SoV model.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: Split F/R relay or proxy Architecture changes are deferred for author discussion. (4) |

Most difficult SCHC Architecture change: Not included in final minimal -07: Split F/R relay or proxy Architecture changes are deferred for author discussion. (4)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4.4.1: Recharacterize the proxy as a split-session F/R relay with segment-local state, and explicitly document the reliability risk (data loss if the satellite fails after acknowledging but before forwarding). |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.1 / 4.2 / 4.4: Rewrite the roles to use -06 terminology: the Device hosts a "SCHC Endpoint" and "SCHC Instance", and the network-side terminator hosts a peer "SCHC Endpoint" and "Instance" participating in a "Session". |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4.2.3.3: Rephrase to describe this as extending the "Stratum" of the SCHC Instance to the application layer, using a custom payload "Parser" in the Context. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4.2.3.1 / 4.2.3.2: Map the configuration IDs to -06 Context Identifiers/Instance Configurations, and define how the Dispatcher uses them as Discriminators to select the active Instance. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.1.2.1: Clarify that the unique identifier serves as the "Discriminator" used by the "Dispatcher" on the Operator Platform. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §4.4.1: Recast structurally: the Proxy is an Endpoint hosting Instance(s); local acknowledgments split the end-to-end exchange into two Sessions sharing the same Context (same Domain): Dev↔Proxy and Proxy↔Gateway |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §4.4.1.1, Phase 2: "…responds to the SCHC Proxy with a SCHC ACK message (see Figure 11)." |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §4.2.3.2: Identify the parameter sets as Contexts (or groups of F/R Rules within a Context) whose identifiers are unique within the Domain; state who assigns them (Domain management) |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §3.1.2.1 and §4.2.1: State that this identifier serves as the Discriminator used by the Dispatcher on the network-side/Proxy Endpoint to route SCHC Datagrams to the appropriate Instance/Session |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §4 (first paragraph): Add the architectural framing: the Instances' Stratum is the application layer and the unit admitted to the Instance is the object itself (keeping the draft's RFC 8724 caveat verbatim) |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.1.2 (last paragraph): "how to configure the SCHC Instances that perform fragmentation and reassembly. The Dev and the network each host a SCHC Endpoint whose Instances share the relevant Context…" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.1.2: "the provisioning of the Contexts (and their Sets of Rules)" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Global (§3.2.2 Fig. 8 caption, §4, §4.4.2 Fig. 12 caption): "Session" where the standing relationship is meant; "F/R exchange within a Session" (or "fragmented SCHC Packet exchange") where a single transfer is meant |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.1: Dev, Proxy, and Application Server each host a SCHC Endpoint; the Proxy maintains the Session state (SoV) across disruptions and participates in Sessions toward both sides sharing the same Context |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.2.1: Name MAX_OBJECT_SIZE, BETI, and TC as parameters of the Dev Instance's Instance Configuration |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.2.2: "the compressing Instance is hosted on an Endpoint in the cellular network" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.2.3.1, §4.2.3.3: "Context … shared between the sending and receiving Instances"; consistent capitalization of Context/Rules |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.2.3.2: Add: configured values are F/R Rule parameters of the Context; running timers/counters are per-Session state in the Set of Variables (SoV) |
| REQUIRED FOR TERMINOLOGY MIGRATION | §4.4.2: Add that the FEC function is a SCHC function of the corresponding Instances (e.g., realized as a SCHClet) indicated in their Instance Configuration |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2: Add a paragraph adopting the terminology of draft-ietf-schc-architecture (Endpoint, Instance, Context, Session, Domain, Discriminator, Dispatcher, Instance Configuration, SoR, SoV) |

Most difficult draft-under-study change: Section 4.4.1: Recharacterize the proxy as a split-session F/R relay with segment-local state, and explicitly document the reliability risk (data loss if the satellite fails after acknowledging but before forwarding). (20)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can only partially express the concepts and technical model of draft-ietf-schc-over-networks-prone-to-disruptions-03. While the basic cellular Zero Energy (ZE) topologies and LPWA caching/timer behaviors map naturally to -06, the draft introduces two key concepts that cannot be naturally expressed without architectural stretching or modification.

### Claude Executive Assessment

SCHC Architecture -06 **can naturally express** the draft under study. The draft describes SCHC deployments over disruption-prone networks (cellular Zero-Energy / Ambient IoT devices and Direct-to-Satellite IoT), and its technical model — a constrained device and a network-side SCHC termination sharing a static context, with delay-adapted F/R parameters, an optional on-path SCHC proxy, object (rather than IP-packet) transport, payload compression, and pre-provisioned parameter sets selected by identifiers — decomposes cleanly onto -06's Endpoint / Instance / Context / Session / Domain / Discriminator / Instance Configuration / SoV model.

