# Consolidated SCHC Architecture Alignment: draft-ietf-schc-protocol-numbers-06

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: Yes

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | High | Easy | None | Yes | Yes |

## Agreement and Differences
Claude and Gemini are marked **incompatible**: one source identifies an actual Architecture gap and the other does not.

## Final Consolidated Assessment
SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is representing the requested IANA protocol and port numbers as **Discriminators** that are processed by the **Dispatcher** to route incoming **SCHC Datagrams** to the appropriate **Instance** and **Context**. The principal migration difficulty is correcting minor terminology conflations in the draft, specifically renaming "SCHC Stratum Header" to outer **Discriminators** (and/or **Control Headers**) and resolving the conflated terms "session" and "instance". No SCHC Architecture -06 gaps exist, and no modifications to the architecture are required. SCHC Architecture -06 can **naturally express** the entire technical model of
draft-ietf-schc-protocol-numbers-06.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: candidate Architecture change deferred. |

Most difficult SCHC Architecture change: Not included in final minimal -07: candidate Architecture change deferred.

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 3.6: Rewrite to remove the concept of "SCHC Stratum Header" and replace it with outer Discriminators (the IP protocol or port numbers) processed by the Dispatcher to route to the correct Instance (which has an associated Context and SoR), and mention that any internal signaling can be carried in a Control Header. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 4, Paragraph 2: Rewrite to: "An Instance Configuration or Context should associate the peer's IP address (or prefix) with the expected RuleID size to enable proper parsing of the SCHC Datagram." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.2, Paragraph 1: Rewrite to: "...the use of SCHC to compress the transported protocol, as well as the SCHC Instance and Session to use, are implicit. The MAC-Layer Endpoints are preconfigured..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.3, Paragraph 1: Rewrite to: "...identifies that the payload of the UDP packet is a SCHC Datagram, which belongs to a Session operating on a specific Stratum (defined in [schc-architecture]) atop UDP..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3.4, Paragraph 1: Rewrite to: "...both Endpoints must identify SCHC using the layer-4 port number (acting as a Discriminator) and exchange and agree on the Context containing the Set of Rules (SoR)." |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | §3.4: "both Instances identify SCHC with the layer-4 port number (used as a Discriminator) and provision and synchronize the Context (its Set of Rules, SoR)" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.6 (title + body), §3.2: Split roles: the recognition/selection value is the Discriminator; any in-band signalling attached to the Datagram is the Control Header. Reword: "the Control Header adds signalling ... together with the Discriminator it helps to identify the use of SCHC and to select the correct Instance (and thereby its Context and SoR)." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.2: "the SCHC Instance to use ... implicit"; "signal both the use of SCHC and the SCHC Instance (selected by the Discriminator) to be used" |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.3, §3.4, §4.2 wording; §3.6: Use "Instances" (hosted on Endpoints) for the SCHC-processing peers; keep "hosts/nodes" for physical devices |
| REQUIRED FOR TERMINOLOGY MIGRATION | §3.3, Abstract, Fig. 1: Capitalize -06 terms: "SCHC Datagram(s)", "SCHC Instance establishment" |

Most difficult draft-under-study change: Section 3.6: Rewrite to remove the concept of "SCHC Stratum Header" and replace it with outer Discriminators (the IP protocol or port numbers) processed by the Dispatcher to route to the correct Instance (which has an associated Context and SoR), and mention that any internal signaling can be carried in a Control Header. (10)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can naturally express the draft under study. The principal conceptual mapping is representing the requested IANA protocol and port numbers as **Discriminators** that are processed by the **Dispatcher** to route incoming **SCHC Datagrams** to the appropriate **Instance** and **Context**. The principal migration difficulty is correcting minor terminology conflations in the draft, specifically renaming "SCHC Stratum Header" to outer **Discriminators** (and/or **Control Headers**) and resolving the conflated terms "session" and "instance". No SCHC Architecture -06 gaps exist, and no modifications to the architecture are required.

### Claude Executive Assessment

SCHC Architecture -06 can **naturally express** the entire technical model of
draft-ietf-schc-protocol-numbers-06.

