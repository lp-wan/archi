# Consolidated SCHC Architecture Alignment: draft-ietf-schc-icmpv6-compression-02

## Final Minimal -07 Decision
No special final minimal -07 decision beyond the consolidated verdict.

## Consolidated Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None
- Claude/Gemini incompatibility: No - calibration difference

## Source Analyses
| Source | Conceptual equivalence | Transition difficulty | Architecture adaptation | Terminology diff | Architecture edits |
| --- | --- | --- | --- | --- | --- |
| Gemini | Very High | Easy | None | Yes | Yes |
| Claude | High | Easy | None | Yes | Yes |

## Agreement and Differences
Claude and Gemini have a calibration difference: conceptual: Very High vs High.

## Final Consolidated Assessment
The Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express `draft-ietf-schc-icmpv6-compression-02` in its entirety. The principal conceptual mapping is direct: the "SCHC Core" maps to the network-side Endpoint/Instance, the "SCHC Device" maps to the device-side Endpoint/Instance, and the "SCHC instance" channel maps to a SCHC Session. The draft's payload compression mechanism (using `mo-rev-rule-match` and `cda-rev-compress-sent` to compress the inner IPv6 packet payload in the reverse direction) is a natural use of the extensibility of Matching Operators and Compression Decompression Actions defined in [RFC8724] and supported by -06. The principal migration difficulty is purely editorial terminology alignment (converting "End-Po... SCHC Architecture -06 can naturally express draft-ietf-schc-icmpv6-compression-02. The draft is,
architecturally, a **profile/data-model extension**: it (a) augments the RFC 9363 YANG Data Model
with ICMPv6 Field IDs, (b) defines two new Matching Operators and two new
Compression/Decompression Actions (RFC 8724 extension points that -06 references as-is), and (c)
describes deployment behaviors (ping compression, surrogate ICMPv6 error generation, and
reverse-direction compression of the invoking packet embedded in an ICMPv6 error). None of these
requires a new architectural concept.

The consolidated assessment uses the stricter supported verdict when source analyses disagree on a required architecture change. Final Architecture -07 inclusion is governed by the final minimal policy, not by every candidate gap found by the agents.

## Required Changes to SCHC Architecture
| Status | Change |
| --- | --- |
| Deferred / Not included | None (0) |

Most difficult SCHC Architecture change: None (0)

## Required Changes to the Draft Under Study
| Category | Change |
| --- | --- |
| REQUIRED FOR CONCEPTUAL ALIGNMENT | Section 5.1 & Section 3: "...implies that only one single ping can be active at any given time per SCHC Session." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 1, 2, 6, 7, 7.1, 7.2, 8: "SCHC Endpoint", "Endpoint", "Endpoints" |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 2: "* SCHC Device: The other Endpoint in the SCHC Session established with the SCHC Core." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 7, 7.1, 7.2: "...direction of transmission within the Session", "...direction of the Session..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 7.1: "...current Set of Rules..." |
| REQUIRED FOR TERMINOLOGY MIGRATION | Section 8: "...included in the SCHC Datagram as a variable length residue." |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2 Terminology, "SCHC Device": Re-anchor on -06: the Device is the SCHC Endpoint at the other end of the Session formed with the Core; it hosts the Device-role Instance. |
| REQUIRED FOR TERMINOLOGY MIGRATION | §2 Terminology, "SCHC Core": Define as a SCHC Endpoint (per [I-D.ietf-schc-architecture]) at that boundary, hosting the core-role Instance of the Session; note the optional co-located IP-router/surrogate function. |
| REQUIRED FOR TERMINOLOGY MIGRATION | §1, §3, §7.1, §7.2: Use "Endpoint" consistently (the -06 spelling), and where the sentence means the association, use "Session". |
| REQUIRED FOR TERMINOLOGY MIGRATION | §1, third bullet & prose: "produced by the SCHC Instance"; "The SCHC Core forwards…". |
| REQUIRED FOR TERMINOLOGY MIGRATION | §7.1: "current Set of Rules"; "in the same Direction as the Endpoint"; "in the reverse Direction relative to the Endpoint". |

Most difficult draft-under-study change: Section 5.1 & Section 3: "...implies that only one single ping can be active at any given time per SCHC Session." (11)

## Author-Facing Diff Summary
See `author-diff.diff` in this folder. The diff is copied from the most complete available source when one exists; otherwise it is generated from the consolidated required-change table as section-oriented author guidance.

## Evidence Notes
### Gemini Executive Assessment

The Static Context Header Compression (SCHC) Architecture -06 (`draft-ietf-schc-architecture-06`) can naturally express `draft-ietf-schc-icmpv6-compression-02` in its entirety. The principal conceptual mapping is direct: the "SCHC Core" maps to the network-side Endpoint/Instance, the "SCHC Device" maps to the device-side Endpoint/Instance, and the "SCHC instance" channel maps to a SCHC Session. The draft's payload compression mechanism (using `mo-rev-rule-match` and `cda-rev-compress-sent` to compress the inner IPv6 packet payload in the reverse direction) is a natural use of the extensibility of Matching Operators and Compression Decompression Actions defined in [RFC8724] and supported by -06. The principal migration difficulty is purely editorial terminology alignment (converting "End-Po...

### Claude Executive Assessment

SCHC Architecture -06 can naturally express draft-ietf-schc-icmpv6-compression-02. The draft is,
architecturally, a **profile/data-model extension**: it (a) augments the RFC 9363 YANG Data Model
with ICMPv6 Field IDs, (b) defines two new Matching Operators and two new
Compression/Decompression Actions (RFC 8724 extension points that -06 references as-is), and (c)
describes deployment behaviors (ping compression, surrogate ICMPv6 error generation, and
reverse-direction compression of the invoking packet embedded in an ICMPv6 error). None of these
requires a new architectural concept.

