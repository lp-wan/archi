---

stand_alone: true
ipr: trust200902
docname: draft-ietf-schc-architecture
cat: info
submissionType: IETF

coding: us-ascii
pi:
  symrefs: 'yes'
  sortrefs: 'yes'
  strict: 'yes'
  compact: 'yes'
  toc: 'yes'

title: "Static Context Header Compression (SCHC) Architecture"
abbrev: SCHC Architecture
wg: SCHC Working Group
area: Internet

author:
- ins: A. Pelov
  name: Alexander Pelov
  org: IMT Atlantique
  street: rue de la Chataigneraie
  city: 35576 Cesson-Sevigne Cedex
  country: France
  email: alexander.pelov@imt-atlantique.fr

- ins: P. Thubert
  name: Pascal Thubert
  city:  06330 Roquefort les Pins
  country: France
  email: pascal.thubert@gmail.com

- ins: A. Minaburo
  name: Ana Minaburo
  org: Consultant
  city: 35510 Cesson-Sevigne Cedex
  country: France
  email: anaminaburo@gmail.com

- ins: Q. Lampin
  name: Quentin Lampin
  org: Orange 
  street: Orange 3 Massifs - 22 Chemin du Vieux Chene
  city: Meylan
  code: 38240
  country: France
  email: quentin.lampin@orange.com
  
- ins: M. Dumay
  name: Marion Dumay
  org: Orange 
  street: Orange 3 Massifs - 22 Chemin du Vieux Chene
  city: Meylan
  code: 38240
  country: France
  email: marion.dumay@orange.com

normative:
  RFC8724: SCHC
  RFC8824: SCHC-CoAP
informative:
  RFC8376: LPWANs
  RFC7950: YANG
  RFC9011: SCHCoLoRaWAN
  RFC9363: Model
  RFC9442: SCHCoSigFox
  I-D.ietf-schc-over-ppp: SCHCoPPP
  I-D.ietf-core-comi: COMI
  I-D.ietf-6lo-schc-15dot4: SCHCo15dot4
  I-D.ietf-intarea-schc-protocol-numbers: PN_and_Ethertype
  I-D.ietf-schc-access-control: SCHCAC


--- abstract

TODO Abstract

--- middle

# Introduction {#Introduction}

TODO Introduction and Scope

State very clearly:

- That the architecture is generic and applicable outside of LPWAN.
- Which assumptions remain (constrained devices, intermittency, etc.) and which are no longer necessary in richer environments.

Indicate what this document is not intended to do (e.g., it does not replace RFC 8724, it does not specify new header formats, etc.).

# Requirements Language

{::boilerplate bcp14}

Check the use of normative keywords.
(ex.: "Since {{RFC8724}} requires X, an architecture compliant with this document MUST ...")
Be very clear about what constitutes a "requirement on implementations" versus a "recommendation on deployments."
Ensure that you do not introduce requirements that would contradict RFC 8724 or existing profiles (SCHC over LoRaWAN, NB-IoT, etc.).

# Terminology {#Terminology}

This section defines terminology and abbreviations used in this document. In the following, terms are assumed to be defined in the context of the SCHC ecosystem, unless specified otherwise, *.e.g* Endpoint refers to a SCHC Endpoint, Instance refers to a SCHC Instance, and so on.

**SCHC**: A Generic Framework, as defined in {{RFC8724}}, that performs compression/decompression and, optionally, fragmentation/reassembly of protocol headers, based on a Static Context shared between two or more Endpoints.
The SCHC acronym is pronounced like "sheek" in English (or "chic" in French).  Therefore, this document writes "a SCHC Datagram" instead of "an SCHC Datagram".

**Instance**: A logical component that implements SCHC functionalities, *.e.g* header compression/decompression,  fragmentation/reassembly.

**Endpoint**: A network entity hosting one or multiple Instances.

**Rule**: A structured set of header fields and matching conditions used by SCHC to process packets in accordance with specified actions.

**Set of Rules (SoR)**: A collection of Rule entries that define how specific header fields are processed by an Instance.

**Context**: A SoR together with metadata, shared by two or more Instances. Metadata may, for example, refer to a data model or a parser compatible with the SoR rule format.

**Operating Profile**: A set of local options and parameters. The content of the Operating Profile may include SCHC Capabilies (compression/decompression, fragmentation/reassembly) and specify how SCHC should behave within a specific Instance. For example, in the case of a SoR where the Rules are not bidirectional, the Instance must know whether it has the App or Dev role in order to properly apply the Uplink and Downlink direction when processing the Rules.

**Session**: A communication session between two Instances or more that share a common Context for SCHC operations.

**Set of Variables (SoV)**: A collection of run-time parameters and session variables, such as fragmentation-related timers, retransmission counters, state flags, and other per-session values that may change during operation.

**Domain**: A logical grouping of Instances that share a common set of Contexts for compression and fragmentation operations.

# Architecture Overview

This section provides an overall view (diagrams) and describes the principal entities and their relations (architectural semantics).
It must reference the definitions given in the previous section.

When a paragraph describes the basic operation of SCHC already covered by RFC 8724, replace it with a brief summary + normative reference rather than re-explaining it.

# Detailed Components / Building Blocks

This section should:

- Define the logical components of SCHC (endpoints, profiles, contexts, management entities, etc.).
- Describe their responsibilities and relationships.
- Remain independent of specific technologies (LPWAN vs PPP vs Ethernet, etc.) - these mappings come later.
- Serve as a reference for the other sections (Architecture Overview, Deployment).

# Deployment Models

How SCHC architecture maps onto different technologies.

# Operational Condiderations

Management, SCHC Endpoint lifecycle, Interoperability, etc.

# Security Considerations

For an architecture document, the security section must analyze:

- Risks specific to SCHC architecture:
  - Compromise or corruption of rules (SoR) and impact on the integrity/confidentiality of flows.
  - Synchronization drift between SoR/SoV and risk of denial of service (dropped or misrouted packets).
  - Attacks on the Instance Manager (e.g., injection of malicious rules).
  - Interactions with the security mechanisms of the underlying layers (PPP, Ethernet, IPsec, OSCORE, etc.).
- High-level mitigation measures expected in this architecture:
  - Authentication and authorization of entities that manage rules.
  - Logging/auditing of SoR changes.
  - Restoration and rollback of incorrect SCHC profiles.

# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments {numbered="false"}

The authors would like to thank (in alphabetic order): Laurent Toutain.