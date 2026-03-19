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

The SCHC Working Group has developed the {{RFC8724}} SCHC protocol for
  Low-Power Wide-Area (LPWA) networks, providing efficient header compression
  and fragmentation mechanisms.

<!-- TODO: 
State very clearly:

- That the architecture is generic and applicable outside of LPWAN.
- Which assumptions remain (constrained devices, intermittency, etc.) and which are no longer necessary in richer environments.

Indicate what this document is not intended to do (e.g., it does not replace RFC 8724, it does not specify new header formats, etc.).
-->
# Requirements Language

{::boilerplate bcp14}

Check the use of normative keywords.
(ex.: "Since {{RFC8724}} requires X, an architecture compliant with this document MUST ...")
Be very clear about what constitutes a "requirement on implementations" versus a "recommendation on deployments."
Ensure that you do not introduce requirements that would contradict RFC 8724 or existing profiles (SCHC over LoRaWAN, NB-IoT, etc.).

# Terminology {#Terminology}

This section defines terminology and abbreviations used in this   document. In 
  the following, terms are assumed to be defined in the context of the SCHC ecosystem, unless specified otherwise, *.e.g* Endpoint refers to a SCHC 
  Endpoint, Instance refers to a SCHC Instance, and so on.

**SCHC**: A Generic Framework, as defined in {{RFC8724}}, that performs 
  compression/decompression and, optionally, fragmentation/reassembly of 
  protocol headers, based on a Static Context shared between two or more 
  Endpoints. The SCHC acronym is pronounced like "sheek" in English (or "chic" 
  in French).

**Endpoint**: A network entity capable of performing SCHC operations, e.g. 
  compressing and decompressing headers, fragmenting and reassembling packets.
  An Endpoint can host one or multiple Instances.

**Instance**: A logical component of an Endpoint that executes the SCHC
  operations. Each Instance operates independently, with its own Context and 
  Profile.

**Rule**: A structured set of header fields and matching conditions used by SCHC
  to process packets in accordance with specified actions.

**Set of Rules (SoR)**: A collection of Rule entries that define how specific
  header fields are processed by an Instance.

**Context**: A SoR together with metadata, shared by two or more Instances.
  Metadata may, for example, refer to a data model or a parser compatible with 
  the rule format.

**Profile**: A set of configurations specific to an Instance that define how 
  SCHC operations are performed, e.g. role of the Instance, matching policy,
  dispatcher configuration,supported SCHC features.

**Session**: A communication session between two Instances or more that share a
  common Context for SCHC operations.

**Set of Variables (SoV)**: Runtime parameters and session variables, such as
  fragmentation-related timers, retransmission counters, state flags, and other
  per-session values that may change during operation.

**Dispatcher**: A logical component of the Endpoint that routes packets to the
  appropriate Instances based on defined admission rules. It can be integrated
  into the network stack or implemented as a separate component.

**Discriminator**: An optional information element included in compressed 
  packets to identify the Instance that should process the packet. It is used by
  the Dispatcher to route packets to the appropriate Instance for decompression
  and reassembly.

**Domain**: A logical grouping of Instances that share a common set of Contexts 
  for compression and fragmentation operations.

**Domain Manager**: A logical component that manages the Domain, including
  context synchronization and profile distribution. #TODO: needed?

**Endpoint Manager**: A logical component that manages the lifecycle and
  configuration of Instances within an Endpoint. It is responsible for
  creating, updating, and deleting Instances as needed, synchronizing
  Contexts and Profiles, and managing the Dispatcher. #TODO: needed?

**Context Repository**: A logical component that stores and manages the
  Contexts used by its Domain. #TODO: needed?


# Architecture 

This section provides an overview (diagrams) and describes the principal 
entities and their relations (architectural semantics). It must reference the 
definitions given in the previous section.

When a paragraph describes the basic operation of SCHC already covered by RFC 
8724, replace it with a brief summary + normative reference rather than re-explaining it.

<!-- TODO: This section should:

- Define the logical components of SCHC (endpoints, profiles, contexts, management entities, etc.).
- Describe their responsibilities and relationships.
- Remain independent of specific technologies (LPWAN vs PPP vs Ethernet, etc.) - these mappings come later.
- Serve as a reference for the other sections (Architecture Overview, Deployment).
--> 

## Overview

<!-- TODO: Overview diagram and text -->

## Core components

### Instance

An Instance is the fundamental component that implements a subset
  of the SCHC protocol as defined in {{RFC8724}}. An Endpoint MAY execute 
  several Instances in its protocol stack. Each Instance operates independently,
  with its own context and profile.

An Instance implements a subset of SCHC functionalities, for example:

* Header Compression and Decompression (C/D)
* Fragmentation and Reassembly (F/R)
* Acknowledgments

The Instance configuration is defined by its Context and Profile.
  The Context is a shared configuration between two or more Instances that 
  defines how functions are performed, while the Profile defines the configuration specific to the Instance.

For example, for Header Compression and Decompression (C/D) or Fragmentation and
  Reassembly (F/R), the Context defines the set of C/D and F/R rules - or Set of Rules - and optionally the data model and the parser to delineate the header field.

The Profile defines the configuration of the Instance, which may include the 
following parameters:

* Role of the Instance (e.g., Upside or Downside for directional rules).
* Matching policy (e.g., first-match, best-match, etc.) to apply when multiple 
  rules match a packet.
* Dispatcher configuration (e.g., how to identify the Instance for incoming 
  packets, how to route packets to the appropriate Instance, etc.).
* Manifest of the supported SCHC features (e.g., whether fragmentation 
  is supported, whether acknowledgments are used, etc.). #TODO: here or else?

A SCHC Instance may execute:

* Dynamic context update mechanisms. #TODO: here or else? 
* Performance monitoring and reporting. #TODO: here or else? 




### Endpoint

A network entity capable of performing SCHC operations, e.g. 
  compressing and decompressing headers, fragmenting and reassembling packets.
  
#### Header Compression and Decompression (C/D)

This component is responsible for compressing and decompressing headers
  using the SCHC protocol, as described in {{RFC8724}}. It applies the rules
  defined in the SCHC Context.

  The C/D engine MUST expose the following interface:

- `compress(buffer, context, profile)`: Compresses the provided buffer using the
   SCHC Context and the profile.
- `decompress(buffer, context, profile)`: Decompresses the provided buffer using
   the SCHC Context and the profile.

Internally, on compression, the C/D engine:

- delineates the fields using the parser identified in the SCHC Context.
- chooses the appropriate compression rule based on the SCHC Context and the
  matching policy defined in the profile.
- applies the compression rule to the fields of the header.
- generates the compressed SCHC packet.

On decompression, the C/D engine:

- identifies the C/D rule based on the SCHC compressed packet.
- applies the decompression rules to reconstruct the original header.
- reconstructs the original packet from the decompressed header and payload.


#### Fragmentation and Reassembly (F/R)

This component is responsible for fragmenting larger packets into smaller
  fragments and reassembling them at the receiving end. It is optional in
  the minimal architecture but recommended for scenarios where packet sizes
  exceed the maximum transmission unit (MTU) of the underlying network.



#TODO: ORANGE EST LÀ, ORANGINA
#TODO: ADD CHICKLET
#TODO: REPRODUCE THE NEXT FIGURE WITHOUT multi-instance features.

An Endpoint can host multiple Instances, each with its own Context and Profile.

When an Endpoint is supporting multiple Instances, the Endpoint Manager is 
  responsible for managing the lifecycle and configuration of these Instances. 
  Packets are routed to the appropriate Instance based on defined admission 
  rules by the Dispatcher. The Dispatcher is a single point of decision for 
  packet forwarding within the Endpoint.

The following figure illustrates the main components of an Endpoint supporting
  multiple Instances and their interactions:

~~~~~~~~
        retrieves,
      synchronizes +------------+
        contexts   |  Endpoint  |     retrieves, synchronizes
         +---------|  Manager   |-------------+---------------+
         |         +------------+             |               |
         |            | manages               v               v
         |            | lifecycle       +------------+  +------------+
         |            | of Instances +--| Profile P1 |  | Context Pk |
         |            |              |  +------------+  +------------+
         |            | +------------+  configures |       |configures
         |            | |                          |       |
         |            | | compresses, decompresses +-----+ |
         |            | |   +------------------------+   | |
         v            v v   | fragments, reassembles |   | |
+------------+  +-------------+                      |   | |
| Context C1 |--| Instance I1 |<--+                  v   v v
+------------+  +-------------+   |           +---------------+
    ...                 ...       +<--------->|  Dispatcher   |----+
    ...                 ...       |     |     +---------------+    |
+------------+  +-------------+   |  dispatch   ^  |               |
| Context Ck |--| Instance Ik |<--+  packets  - | reinject  configures
+------------+  +-------------+                 |  |               |
                                                |  v               v
                                    +-------------------------------+
                                    |            OS/firmware        |
                                    |           network stack       |
                                    +-------------------------------+
~~~~~~~~

In its simplest form, an Endpoint MAY implement a single Instance with a
  hardwired configuration, as described in {{DRAFT-SCHCLET}}. In this case, the
  Endpoint Manager and Dispatcher components are not required.


### Session

As illustrated in the figure below, the Session is a communication session
  between two or more Instances that share a common Context, i.e. they are
  part of the same Domain. It is established whenever the Context is updated
  or modified.

~~~~~~~~

   Endpoint A                                  Endpoint B
+------------------+                      +------------------+
|  SCHC Instance   | <---           ----> |  SCHC Instance   |
+------------------+     \         /      +------------------+
                          \       /
                           Session
                          /       \
+------------------+     /         \      +------------------+
|  SCHC Instance   | <---           --->  |  SCHC Instance   |
+------------------+                      +------------------+
   Endpoint C                                  Endpoint D

~~~~~~~~

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