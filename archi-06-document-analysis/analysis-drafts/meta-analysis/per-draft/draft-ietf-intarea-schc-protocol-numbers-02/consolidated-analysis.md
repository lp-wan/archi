# Consolidated SCHC Architecture Alignment: draft-ietf-intarea-schc-protocol-numbers-02

## Final Minimal -07 Decision
Not included in final minimal -07: RuleID scope and RuleID-size determinability changes are deferred.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: Trivial
- Claude/Gemini incompatibility: Not applicable

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | High | Easy | Trivial | Yes | Yes |
| Claude | Unavailable | Unavailable | Unavailable | No | No |

## Agreement and Differences
Only one source analysis is available.

## Final Consolidated Assessment
SCHC Architecture -06 can naturally express draft-ietf-intarea-schc-protocol-numbers-02. This is not a coincidence of vocabulary: -06's Appendix A.2.3 is written about this draft by name, and it supplies the architectural reading of all three requested codepoints in a single sentence — the EtherType, IP Protocol Number, and UDP Port Number each "serves as the Discriminator: it indicates that the frame or packet carries a SCHC Datagram, and the Dispatcher uses it, together with lower-layer context (e.g., addresses or ports), to route the Datagram to the appropriate Instance."

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | Not included in final minimal -07: RuleID scope and RuleID-size determinability changes are deferred. (3) |

Most difficult SCHC Architecture change: Not included in final minimal -07: RuleID scope and RuleID-size determinability changes are deferred. (3)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 6.3, IANA SCHC Ethertype Registry: State that a RuleID identifies a Rule within a Context and is not made globally unique by such a registry; recast the registry as reserving RuleID ranges whose interpretation is agreed across the Domains that use the SCHC Ethertype, so that a receiving Endpoint can determine the RuleID size before interpreting any Context-dependent portion of the Datagram. Keep "domains of use" in lower case and distinguish it from an -06 Domain. |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 1.2, first paragraph: Separate Instance from Session. State that on a classical LPWAN link a single Instance and a single Session exist because the MAC-layer peers are preconfigured, that on Ethernet an Endpoint may host several Instances and take part in several Sessions, and that the Ethertype supplies the Discriminator indicating SCHC while Instance/Session selection remains the SCHC WG's chartered work. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, final paragraph: Add that the IKEv2 exchange provisions the Context binding out of band, before SCHC operation begins, and does not constitute negotiation between the compressing and decompressing Instances. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1.2: Rewrite as "The MAC-layer peers are preconfigured". Do not translate to -06's Endpoint. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1.2: "When extended to Ethernet and to more capable Endpoints" — here the -06 Endpoint *is* meant. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, "The SCHC compressed header with payload is shown below" and Figure 1 caption "SCHC Packet": Use "SCHC Datagram" for RuleID + Compression Residue, followed by the Payload. Retitle Figure 1 accordingly and bracket the Datagram in the figure. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, "An implementation should have a table of source IP address and RuleID size.": Frame as dispatch information: the IP Protocol Number is the Discriminator; the Dispatcher of the receiving Endpoint uses it together with the source IP address to select the Instance, and hence the Context and the RuleID size that apply. Keep the prefix-format recommendation. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 4, "The use of SCHC as an Ethertype is similar to that as in Section 3": State that the Ethertype is the Discriminator and that the Dispatcher uses it with lower-layer context, typically the source MAC address, to select the Instance. |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 3, "The size of the SCHC RuleID is variable as described in [RFC8724].": Add that the size must be known to the receiving Instance before the Datagram is parsed. |

Most difficult draft-under-study change: Section 1.2, first paragraph: Separate Instance from Session. State that on a classical LPWAN link a single Instance and a single Session exist because the MAC-layer peers are preconfigured, that on Ethernet an Endpoint may host several Instances and take part in several Sessions, and that the Ethertype supplies the Discriminator indicating SCHC while Instance/Session selection remains the SCHC WG's chartered work. (9)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

SCHC Architecture -06 can naturally express draft-ietf-intarea-schc-protocol-numbers-02. This is not a coincidence of vocabulary: -06's Appendix A.2.3 is written about this draft by name, and it supplies the architectural reading of all three requested codepoints in a single sentence — the EtherType, IP Protocol Number, and UDP Port Number each "serves as the Discriminator: it indicates that the frame or packet carries a SCHC Datagram, and the Dispatcher uses it, together with lower-layer context (e.g., addresses or ports), to route the Datagram to the appropriate Instance."

