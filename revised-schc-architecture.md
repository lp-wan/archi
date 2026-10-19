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
informative:
  RFC8376: LPWANs
  RFC7950: YANG
  RFC9011: SCHCoLoRaWAN
  RFC8824: SCHC-CoAP
  RFC9363: Model
  RFC9442: SCHCoSigFox
  RFC9441: CompoundACK
  I-D.ietf-schc-over-ppp: SCHCoPPP
  I-D.ietf-core-comi: COMI
  I-D.ietf-6lo-schc-15dot4: SCHCLo15dot4
  I-D.ietf-intarea-schc-protocol-numbers: PN_and_Ethertype
  I-D.ietf-schc-access-control: SCHCAC
  DRAFT-SCHCLET:
    =: I-D.ietf-schc-schclet


--- abstract

The Static Context Header Compression and fragmentation (SCHC) framework
provides both a header compression mechanism and an optional fragmentation
mechanism. This document defines an architecture for SCHC deployments,
providing guidance for implementers and operators on the essential components
and their interactions required for effective SCHC operation.

--- middle

# Introduction {#Introduction}

The IETF LPWAN Working Group defined the necessary operations to enable
  IPv6 over selected Low-Power Wide-Area Networking (LPWAN) radio
  technologies; {{RFC8376}} presents an overview of those technologies.
  The Static Context Header Compression (SCHC) framework {{RFC8724}} is the
  core product of that effort and was the basis to form the SCHC Working
  Group. {{RFC8724}} defines a generic framework for header compression and
  fragmentation, based on a static context that is pre-installed on the
  SCHC endpoints.

While SCHC was designed to address the severe constraints of LPWAN
  technologies, the framework itself is generic: the architecture defined
  in this document is applicable to LPWAN and non-LPWAN environments alike,
  from highly constrained devices and links to more capable ones.

This document details the constitutive elements of a SCHC-based solution
  and how the solution can be deployed. It provides a general architecture
  for SCHC deployments, describing the essential components and their
  interactions, the possible deployment types, and the models whereby
  Contexts can be distributed and installed to enable reliable and scalable
  operations.

This document does not update {{RFC8724}} and does not define new Rule
  formats, Data Unit formats, or protocols. It names the components of a SCHC
  deployment and describes how they relate, so that documents that specify a
  particular deployment, profile, or extension can refer to a common
  architecture and vocabulary. Assumptions that stem from the LPWAN
  environment, such as extreme bandwidth scarcity, very small frames, or
  intermittent connectivity, apply where that environment does and are not
  required by this architecture.

# Requirements Language

{::boilerplate bcp14}

This document is Informational. It places no requirements on
  implementations of {{RFC8724}}, and nothing in it contradicts {{RFC8724}} or
  the profiles built on it. In some cases, terminology was clarified for
  contexts or uses which were not initially in scope of SCHC.
  Where this document uses BCP 14 keywords, they apply to documents that
  specify an element this architecture leaves open, such as a Control Header ({{ControlHeader}}), and they state what such a document has to provide for
  the architecture to hold.

# Terminology {#Terminology}

This section defines terminology and abbreviations used in this document. In
  the following, terms are assumed to be defined in the context of the SCHC
  ecosystem, unless specified otherwise, *.e.g* Endpoint refers to a SCHC
  Endpoint, Instance refers to a SCHC Instance, and so on.

**SCHC**: A Generic Framework, as defined in {{RFC8724}}, that performs
  compression/decompression and, optionally, fragmentation/reassembly of
  protocol headers, based on a Static Context shared between two or more
  Endpoints. The SCHC acronym is pronounced like "sheek" in English (or "chic"
  in French).

**Endpoint**: A logical entity that provides SCHC functionality by hosting
  the SCHC processing code, rather than a physical device. Multiple SCHC
  Endpoints can operate on the same physical equipment, for example to serve
  different Domains, tenants, strata.

**Instance**: A logical component of an Endpoint that executes the actual SCHC
  operations, e.g. compressing and decompressing headers, fragmenting and
  reassembling packets. Multiple Instances can coexist on the same Endpoint
  but each Instance operates independently, with its own Context and Configuration.

**Rule**: A structured set of header fields and matching conditions used by SCHC
  to process packets in accordance with specified actions.

**Set of Rules (SoR)**: A collection of Rule entries that define how specific
  header fields are processed by an Instance.

**Context**: A SoR together with metadata, shared by two or more Instances.
  Metadata may, for example, refer to a data model or a parser compatible with
  the rule format.

**Instance Configuration**: A set of configurations specific to an Instance that
  define how SCHC operations are performed, e.g. role of the Instance, matching
  policy, dispatcher configuration, supported SCHC features.

**Session**: A communication session between two or more Instances that share a
  common Context for SCHC operations.

**Set of Variables (SoV)**: Runtime parameters and session variables, such as
  fragmentation-related timers, retransmission counters, state flags, and other
  per-session values that may change during operation.

**Dispatcher**: A logical component that routes Data Units to the
   appropriate Instance based on defined admission criteria. The Dispatcher
   can be integrated into the network stack or as a separate component.

**Discriminator**: An optional information element used by the Dispatcher to
   enable the selection of the correct Instance. The Discriminator can be a
   combination of several criteria.

**Parser**: A software tool or component that dissects and analyzes network
   packets, to extract header fields such as source and destination
   addresses, port numbers, and payload data.

**Data Model**: A formal description of the Rules and of the header fields
   they refer to, that allows an Instance to interpret those fields and to
   exchange Contexts in an interoperable way.

**Stratum**: A background concept that identifies a portion of the network
  protocol stack targeted by SCHC, i.e., the contiguous layers within which
  SCHC processing can be applied. The Stratum defines the scope of the
  protocol headers that the SCHC Rules in the associated Context can address.

**Data Unit**: The unit exchanged between SCHC instances. A Data Unit
  consists of a Rule Identifier (RuleID) and the result of the SCHC operation
  (if non-empty), such as a compression residue or a packet fragment. It ends
  with a Payload taken from the original packet (if any).

**Control Header**: A structure used to provide one or more control information
  elements in a SCHC Datagram whenever necessary. For example, it may contain a
  Discriminator to route a Data Unit to the correct instance.

**Domain**: A logical grouping of Instances that share a common set of Contexts
   for SCHC operations.

**Domain Manager**: A logical component that manages the Domain, including
  context synchronization and configuration distribution.

**Instance Manager**: A logical component that manages the lifecycle and
  configuration of Instances within an Endpoint. It is responsible for
  creating, updating, and deleting Instances as needed, synchronizing
  Contexts, and managing Instance Configurations.

**SCHClet**: A self-contained unit that implements a specific SCHC function
   or a subset of SCHC operations. A SCHClet can be combined with other
   SCHClets within an Instance.

<!--
**Endpoint Manager**: 
  TBD - definition to be completed (see Future Work annex).
-->

**Context Repository**: A logical component that stores and manages the
  Contexts used by its Domain.

**C/D**: SCHC function that performs the Compression and Decompression of headers.

**F/R**: SCHC function that performs the Fragmentation and Reassembly of headers.

**MO**: Matching Operator

**CDA**: Compression/Decompression Action

# SCHC: Primer

<!-- TODO: This section should explain the basic operation and components of
SCHC defined in RFC 8724, such as Rules. -->


# Architecture {#Architecture}

<!-- TODO: This section should:

- Define the logical components of SCHC (endpoints, profiles, contexts, 
  management entities, etc.).
- Describe their responsibilities and relationships.
- Remain independent of specific technologies (LPWAN vs PPP vs Ethernet, etc.),
  these mappings come later.
- Serve as a reference for the other sections (Architecture Overview, Deployment).

SCHC may operate in multiple environments, from extremely constrained (LPWANs),
to highly-capable, with simple or complex topologies.

This document provides an architecture in which both the simple and the complex
operations of SCHC can be developed. 
-->

<!-- TODO: This section should explain the basic operation and components of
SCHC defined in RFC 8724, such as Rules. -->

SCHC is a framework designed to efficiently compress headers of network packets.
  It reduces payload overhead by exploiting the predictable nature of network
  flows. Instead of transmitting full headers, both the sending and receiving
  Instances store synchronized, static information about expected headers:
  the Context, which contains Rules. Using a Rule that matches the headers of
  a packet to be transmitted, the sender replaces the known header fields with
  a short RuleID which identifies the rule that applies, and a compression
  residue if any, forming a SCHC Datagram. The receiver of this SCHC Datagram
  matches the RuleID against its own Context and applies decompression actions
  to reconstruct the original header.

## Overview of a Basic Architecture

### Basic SCHC Architecture

{{Fig-Simple-Overview}} illustrates how messages are exchanged between
  applications running on two remote hosts using SCHC Compression/Decompression
  and optionally Fragmentation/Reassembly.

Each host runs an Endpoint that implements SCHC functions that are executed by
  an Instance. The Instance stores a Context that may have been obtained from
  an entity called the Context Repository. The same Context is shared between
  the two Endpoints. The Instance Configuration specifies the required SCHC
  functions and parameters necessary for the Instance to operate properly:
  which packets to intercept, the rule-matching policy (e.g., first-match,
  best-match), the Instance's role (in the case of asymmetric processing), etc.

Important notice: having the same Context is not sufficient to guarantee
  the interoperability of SCHC operations between two Instances. The format of
  the data obtained from the Parser when processing the headers must be
  consistent on each Endpoint to allow the successful decompression. To ensure
  interoperability, the Context may specify which Parser to use to delineate
  the header fields, and/or which Data Model, such as the one defined in
  {{RFC9363}}.

Instances sharing a common set of Contexts form a Domain. The Domain Manager
  is responsible for managing the Contexts of all Instances that belong to it.
  A communication between two Instances or more that share a common Context is
  called a Session. Each Instance, Context, and Session must be uniquely
  identifiable to allow the Domain Manager to update the Context of a specific
  Instance.

~~~~~~~~
+-----------------------+                   +-----------------------+
| Endpoint              |                   | Endpoint              |
|                       |                   |                       |
| +-------------------+ |                   | +-------------------+ |
| | Instance          | |                   | | Instance          | |
| |                   | |                   | |                   | |
| | +---------------+ | |                   | | +---------------+ | |
| | | Instance      | | |                   | | | Instance      | | |
| | | Configuration | | |                   | | | Configuration | | |
| | +---------------+ | |                   | | +---------------+ | |
| | +---------+       | |                   | | +---------+       | |
| | | Context |< - - - - - - - - - - - - - - - >| Context |       | |
| | +---------+       | |     Shared        | | +---------+       | |
| +-------------------+ |     Context       | +-------------------+ |
| +-------------------+ |                   | +-------------------+ |
| |SCHC Functions     | |                   | SCHC Functions      | |
| |                   | |                   |                     | |
| | +-----+   +-----+ | |                   | | +-----+   +-----+ | |
| | | C/D |   | F/R | | |                   | | | C/D |  | F/R  | | |
| | +-----+   +-----+ | |                   | | +-----+   +-----+ | |
| +-------------------+ |                   | +-------------------+ |
+-----------------------+                   +-----------------------+ 
            ^                                           ^
            |                                           |
            ---------------------------------------------
              SCHC Data Units exchanged inside a Session         

~~~~~~~~
{: #Fig-Simple-Overview title='Overview of two simple Endpoints exchanging
SCHC Data Units'}

~~~~~~~~
         +-----------------------------------------------------+
         | Domain Manager                                      |
         |                                                     |
         |  +-------------+ +--------------+ +--------------+  |
         |  |Endpoint     | |Context       | |Instance      |  |
         |  |Manager      | |Manager       | |Configuration |  |
         |  |             | |+------------+| |Manager       |  |
         |  |             | || Context    || |              |  |
         |  |             | || Repository || |              |  |
         |  |             | |+------------+| |              |  |
         |  +-------------+ +--------------+ +--------------+  |
         |      ^                       ^       ^              |
         +------|-----------------------|-------|--------------+
                |                       |       |
    Registration|   Context Provisioning|       |Configuration
              +-|    and Synchronization|       |Distribution
              | |                       |       |
              v |                       |       |
+---------------|-------------------+   |       |
| Endpoint      |                   |   |       |
|               v                   |   |       |
|  +------------------------+       |   |       |
|  | Instance Manager       |       |   |       |
|  +------------------------+       |   |       |
|    ^  ^                           |   |       |
|    |  |    +--------------------+ |   |       |
|    |  +--->| Instance 1         | |   |       |
|    |       |                    | |   |       |
|    |       | +--------------+   | |   |       |
|    |       | |Context       |<--------+       |
|    |       | +--------------+   | |           |
|    |       | +--------------+   | |           |
|    |       | |Instance      |<----------------+
|    |       | |Configuration |   | |
|    |       | +--------------+   | |
|    |       +--------------------+ |
|    |       +--------------------+ |
|    +------>| Instance 2         | |
|            +--------------------+ |
+-----------------------------------+
~~~~~~~~
{: #Fig-Domain-Manager title='Overview of Endpoint, Instance, and Domain
configuration and management'}

## Focus on core components

### Instance

An Instance is the fundamental component that runs a set of SCHC functionalities
  as defined in {{RFC8724}} hosted on an Endpoint. Its operation is defined by
  an Instance Configuration and a Context. An Endpoint MAY execute several
  Instances. Each Instance operates independently, with its own Context and
  Instance Configuration. Instances may execute dynamic Context update
  mechanisms and performance monitoring and reporting in complex scenarios.
  
#### Instance Configuration
  
The Instance Configuration specifies the local parameters of the Instance.

The Instance Configuration may indicate in a Manifest the set of required
SCHC functionalities, such as:

- Header Compression and Decompression (C/D)
- Fragmentation and Reassembly (F/R)
- SCHClets (modular subfunctions)

The Instance Configuration may also include the following parameters:

- Role of the Instance (e.g., App or Dev for asymmetric Rules) to determine
  which direction the rule applies to (Up, Dw, Bi).
- Matching policy (e.g., first-match, best-match, etc.) to apply when multiple
  rules match a packet.
- Packet interception criteria (e.g., Stratum - the protocol headers that the
  SCHC Rules in the associated Context can address, Filters based on specific
  values or characteristics of packets, etc.)
- Dispatch information (e.g., how to identify the Instance for incoming
  packets, how to route packets to the appropriate Instance, etc.).

The Role of an Instance is typically derived from extrinsic properties.
  In star-oriented deployments, the hub and the spokes derive their
  respective roles from the network configuration, and SCHC does not need
  to signal which end plays which role. When Instances of equivalent
  capabilities communicate in a peer-to-peer fashion, the role cannot be
  inferred from the topology; in that case, by convention, the Instance
  that initiates the connection plays the role of the Device in
  {{RFC8724}}. This convention can be reversed, e.g., by configuration,
  but proper SCHC operation requires that the method used ensures that all
  Instances of a Session are aware of their role.

#### Context

The Context contains operational information shared between two or more
Instances.

For example, for Header Compression and Decompression (C/D) or Fragmentation
  and Reassembly (F/R), the Context defines the set of C/D and F/R Rules - or
  Set of Rules - describing the specific actions to be performed on the packets
  using the corresponding SCHC functionalities, and, optionally, the Parser and
  the Data Model to delineate and dissect the header fields.

### Endpoint

A logical entity providing SCHC functionalities, and hosting the Instances
that consist of a specific execution of one or more of these aforementioned
functionalities.

#### Header Compression and Decompression (C/D)

This component is responsible for compressing and decompressing headers
  using the SCHC framework, as described in {{RFC8724}}. It applies the rules
  defined in the Context.

Internally, on compression, the C/D engine:

- delineates the fields using the Parser and/or Data Model provided in the Context;
- chooses the appropriate compression Rule among candidate Rules from the Context
  based on the matching policy defined in the Instance Configuration;
- applies the compression Rule to the fields of the header(s);
- generates the compressed SCHC Data Unit.
In {{RFC8724}}, a packet whose header has been compressed is called a SCHC
  Packet.

On decompression, the C/D engine:

- identifies the appropriate decompression Rule based on the RuleID stored in
  the SCHC Packet;
- applies the decompression Rule to reconstruct the original header;
- reconstructs and returns the original packet from the decompressed header
  and payload.

#### Fragmentation and Reassembly (F/R)

This component is responsible for fragmenting larger packets into smaller
  fragments and reassembling them at the receiving end. It is an optional
  feature but recommended for scenarios where packet sizes may exceed the
  maximum transmission unit (MTU) of the underlying network. In {{RFC8724}},
  the pieces of a SCHC Packet that has been fragmented are called SCHC
  Fragments.

{{RFC8724}} defines three reliability modes for fragmentation: No-ACK,
  ACK-Always, and ACK-on-Error. The choice of mode and of its parameters
  depends on the characteristics of the underlying technology and is
  typically fixed by the deployment or by a technology-specific profile.
  {{RFC9441}} defines a Compound ACK format and procedure that can be used
  with applicable fragmentation modes, including ACK-on-Error.  

#### SCHClets

A SCHClet is a self-contained unit within the SCHC framework that implements
  a specific SCHC function or a subset of SCHC operations. A SCHClet may
  implement aspects defined in {{RFC8724}} or functions from other related
  SCHC RFCs, and MAY be combined with other SCHClets within an Instance, as
  specified in the Manifest in the Instance Configuration.

#### Multiple Instances {#MultipleInstances}

An Endpoint can host multiple Instances, each with its own Context and Instance
Configuration.

When an Endpoint is supporting multiple Instances, the Instance Manager is
  responsible for managing the lifecycle and configuration of these Instances.
  Data Units are routed to the appropriate Instance by the Dispatcher using
  the Discriminator and admission criteria based on information provided in the
  Instance Configuration. The Dispatcher is a single point of decision for
  packet forwarding within the Endpoint.

The Dispatcher runs ahead of the selection of an Instance. At the moment it
  makes its decision, no Context has been selected, no Session has been
  identified, and no SCHC state is available for the packet at hand: those are
  consequences of the decision, not inputs to it. The Dispatcher therefore
  does not require SCHC Rules, a Context, or per-Session SCHC state to operate.
  It uses the Discriminator to route the Data Units to the correct Instance
  which has to be locatable and interpretable without them. A design in which
  the Dispatcher would have to consult SCHC Rules or state to
  find the Instance that owns those very Rules and that state cannot be
  resolved, and is outside this architecture.

In some deployments, the Discriminator is derived entirely from lower-layer
  context (e.g., a specific PPP link, an IPv6 address, or a UDP port).
  If external context is insufficient or unavailable, the Dispatcher may need
  an explicit Discriminator. For example, Data Units can be encapsulated in a
  light transport protocol whose header contains the disambiguation
  information elements, such as a Session Identifier.
  These information elements may also be provided in a custom Control Header
  placed before the RuleID.
  The transport protocol or control header can provide additional services
  such as integrity checking (CRC).

The following figure illustrates the main components of an Endpoint supporting
  multiple Instances and the interaction between the Network Stack, the
  Dispacther, and the Instances.

~~~~~~~~
    +-------------------+         +----------------+         
    | Instance Manager  |         | SCHC Functions |         
    +-------------------+         +----------------+         
 manages lifecycle | |                      ^                
 of Instances,     | |                      | compresses,    
 retrieve Contexts | +--------------------+ | decompresses,  
 and Configs       |                      | | etc.           
                   v                      v v                
        +-------------+             +-------------+          
     +->| Instance I1 |       ...   | Instance Ik |<--------+ 
     |  +-------------+             +-------------+         | 
     |   | |                         | |                    | 
     |   | |  +------------+         | |  +------------+    | 
     |   | +--| Context C1 |  ...    | +--| Context Ck |    | 
     |   |    +------------+         |    +------------+    | 
     |   |    +------------+         |    +------------+    | 
     |   +----| Config G1  |  ...    +----| Config Gk  |    | 
     |        +------------+              +------------+    | 
     |              |                         |             | 
     |   is applied |                         | is applied  | 
     |   to         |     +-------------+     | to          | 
     |              +---->|             |<----+             | 
     +------------------->| Dispatcher  |<------------------+ 
        dispatch packets  |             |  dispatch packets  
                          +-------------+                    
                                ^ |                          
                          admit | | reinject                 
                                | v                          
                          +---------------+                  
                          | Network stack |                  
                          +---------------+                  
~~~~~~~~
{: #Fig-Multiple-Instances title='Overview of an Endpoint hosting multiple
Instances'}

### Session

As illustrated in the figure below, the Session is a communication session
  between two or more Instances that share a common Context, i.e. they are
  part of the same Domain.

~~~~~~~~

   Endpoint A                            Endpoint B
+--------------+                       +--------------+
|   Instance   | <----           ----> |   Instance   |
+--------------+      \         /      +--------------+
                       \       /
                        Session
                       /       \
+--------------+      /         \      +--------------+
|   Instance   | <----           ----> |   Instance   |
+--------------+                       +--------------+
   Endpoint C                            Endpoint D

~~~~~~~~
{: #Fig-Session title='Session between multiple Instances'}

### Domain

In the figure below, two Domains are represented, where Endpoint A and
  Endpoint B host Instances belonging to Domain 1, and Endpoint B and
  Endpoint C host Instances belonging to Domain 2. Instances from the same
  Domain communicate through a Session. A Session Identifier, or Session ID,
  may be used as a Discriminator to route the Data Units to the correct
  Instance (e.g., to distinguish between the two Instances of Endpoint B),
  and/or for management purpose.

~~~~~~~~
  +------------------------------+      +------------------------------+  
  |      Domain Manager 1        |      |       Domain Manager 2       |
  +------------------------------+      +------------------------------+  
          ^                   ^            ^               ^            
          |                   |            |               |           
          v                   v            v               v           
  +----------------+      +-------------------+      +---------------+
  |   Endpoint A   |      |    Endpoint B     |      |  Endpoint C   |
+-----------------------------------------------+    |               |
| | +-----------+  |      |   +-----------+   | |    |               |
| | | Instance  |<----------->| Instance  |   | |    |               |
| | +-----------+  |      |   +-----------+   | |    |               |
+--------------------|--------------------------+    |               |
  |                | |  +----------------------------------------------+
  |                | |  | |   +-----------+   |      | +-----------+ | |
  |                | |  | |   | Instance  |<---------->| Instance  | | |
  |                | |  | |   +-----------+   |      | +-----------+ | |
  |                | |  +-------------------------|--------------------+
  |                | |    |                   |   |  |               |
  +----------------+ |    +-------------------+   |  +---------------+
                     |                            |                       
                     |                            |                       
                     +---> Domain 1               +-> Domain 2            
~~~~~~~~
{: #Fig-Domains title='Overview of multiple Domains'}

### Data Unit Format {#DataUnitFormat}

A Data Unit is the unit exchanged between SCHC Instances.

It provides a unified representation for:

- compressed packets;
- SCHC F/R messages of Section 8.2.1 of {{RFC8724}}: SCHC Fragment, SCHC
  ACK, SCHC ACK REQ, SCHC Sender-Abort, and SCHC Receiver-Abort.

A Data Unit begins with a RuleID, and the result of the SCHC operation
  follows the RuleID immediately. The interpretation of that result depends on
  the Rule that the RuleID identifies, so nothing that a receiver has to parse
  independently of the Context can be placed between the two.

A Data Unit is composed of a RuleID followed by the result of the SCHC
  operation (if non-empty), such as a compression residue or a packet fragment.
  The RuleID and the SCHC operation result form the SCHC Header.
  It may be followed by a Payload (e.g., the paylaod of the original packet,
  fragment payload) called SCHC Payload.

As stated in {{RFC8724}}, a Data Unit resulting from a compression operation is
called a SCHC Packet, and a Data Unit resulting from a fragmentation operation
is called a SCHC Fragment.

The following figure illustrates the general SCHC Data Unit format and the
SCHC Header format of SCHC Packets and SCHC Fragments.

~~~~~~~~
                     |<------------ SCHC Data Unit ------------>|
                     |                     |                    |
                     |<--- SCHC Header --->|                    |
                     |                     |                    |
    +----------------+--------+------------+--------------------+
    | Control Header | RuleID | SCHC       |   SCHC Payload     |
    |   (optional)   |        | operation  |    (may be empty)  |
    |                |        | result     |                    |
    +----------------+--------+------------+--------------------+

      SCHC Header, compression case (Compressed Header, RFC 8724 5.1):
      +--------+---------------------+
      | RuleID | Compression Residue |    SCHC Payload = payload of the
      +--------+---------------------+    original packet

      SCHC Header, fragmentation case (Fragment Header, RFC 8724 8.3.1):
      +--------+-----------------------+
      | RuleID | DTag | W | FCN | RCS |    SCHC Payload = Fragment
      +--------+-----------------------+    Payload (tiles)
~~~~~~~~
{: #Fig-DataUnit title='SCHC Data Unit, SCHC Header, and SCHC Payload'}


#### Control Header {#ControlHeader}

In some deployments, it may be necessary to add information to the Data Unit,
  for example so that it can be properly routed to the correct Instance. This
  information may be carried in a Control Header. An Instance that is handed a
  Data Unit is unaffected by a Control Header which was removed before the
  Data Unit reached it, typically by the Dispatcher.

This document describes the Control Header as an architectural slot: where it
  sits with respect to the Data Unit, and what a specification that fills the
  slot has to provide. It does not define a Control Header format, and it does
  not mandate or endorse any particular one. The architecture admits more than
  one: different specifications may define different Control Headers for
  different environments or deployments. Deployments that need no Control Header carry none, and that remains the common case. A Control Header, when present, precedes the RuleID, as represented in {{Fig-DataUnit}}.

This position follows from the purpose of the Control Header rather than from
  convention. A Control Header exists so that a node can act on a Data Unit
  before the Instance, and hence the Context, has been selected; that is the
  reason for carrying the information outside the SCHC operaton at all. A
  Control Header placed after the RuleID could be delineated only by a node
  that already holds the Context, which is precisely the node that does not
  need the Control Header. A specification that defines a Control Header for
  use with SCHC therefore MUST place it before the RuleID, and MUST NOT insert
  any element between the RuleID and the result of the SCHC operation.  

For obvious reasons of interoperability, the format of the Control Header must
  be clearly defined in a standard track document (in a profile such as
  {{I-D.ietf-6lo-schc-15dot4}} or in a dedicated specification).
  
A Control Header is a structure that may also be itself compressed with SCHC
  using its own Context and Instance.

# Deployment models

<!--
Give deployment examples (point to point, point to multipoint,
multi-instances, SCHC with cryptographic boundaries, etc.) and link them to
specific technologies (LPWAN, PPP, Ethernet, 6Lo, etc.)
-->

TBD

# Operational considerations

<!--
Management, Data Models, SCHC Endpoint lifecycle (provisioning,
context synchronization), Interoperability, Error handling,
Same context vs. compatible contexts, etc.
-->

## Role of an Instance in a SCHC communication

SCHC Rules include a Direction Indicator (DI) that allows for asymmetric
  processing using the same Rule (e.g., to compress in one rule a request
  and the corresponding acknowlegment). Three values are possible:

      - Up:  for packets traveling Uplink;
      - Dw:  for packets traveling Downlink;
      - Bi:  for both Uplink or Downlink packets.

The direction can be determined based on the Role of the Instance. The role is
  specified in the Instance Configuration. If the Role of the Instance has not
  been specified, then asymmetric rules cannot be used; only bidirectional
  rules apply.

  In {{RFC8724}}, two roles were defined: App and Dev, which refer to the
  LPWAN server and the devices, respectively. By convention, packet from App
  to Dev are Downlink, and packets from Dev to App are Uplink.

  When necessary, e.g. in cases where “App” and “Dev” do not apply, other
  roles can be defined, along with an associated strategy for determining the direction between those Roles.

## Context consistency

In {{Architecture}}, we have established that a Session is a communication
  session between two or more Instances that share a common Context.
  For a packet to be properly decompressed, the receiver must know the rule
  that the sender used to compress the packet headers.

To facilitate the provisioning and synchronization of Contexts within a Domain
  for a given Session, it is recommended to deploy the same Context (with
  identical SoR) on all Instances participating in a given Session. However,
  it is possible for one or more Instances to have only a subset of the SoR,
  as long as the Contexts of the Instances participating in a given session
  remain compatible.

In the following example of a deployment using a star topology where leaf
  nodes only communicate with the root, rather than creating a separate
  Instance for each link, or storing the entire SoR on each node, leaf nodes
  only store the rules necessary for their communication with the root.
  It should be noted that there may be a risk that the root uses a rule
  that is unknown to the recipient, leading to an error.

~~~~~~~~
                  +--------------+                  
                  | Root         |                  
                  | +----------+ |                  
                  | | Rule 1   | |                  
                  | | Rule 2   | |                  
                  | | Rule 3   | |                  
                  | +----------+ |                  
                  +------|-------+                  
                         |                          
        +----------------|-----------------+        
        |                |                 |        
+-------|------+  +------|-------+  +------|-------+
| Node A       |  | Node B       |  | Node C       |
| +----------+ |  | +----------+ |  | +----------+ |
| | Rule 1   | |  | | Rule 2   | |  | | Rule 3   | |
| +----------+ |  | +----------+ |  | +----------+ |
+--------------+  +--------------+  +--------------+
~~~~~~~~
{: #Fig-Consistency title='Example of compatible partial Contexts'}

## Data Models and Parsing

Having the same Context is not sufficient to guarantee
  the interoperability of SCHC operations between two Instances. The format of
  the data obtained from the Parser when processing the headers must be
  consistent on each Endpoint to allow the successful decompression. To ensure
  interoperability, the Context may specify which Parser to use to delineate
  the header fields, and/or which Data Model, such as the one defined in
  {{RFC9363}}.

## Error handling

When an Instance receives a Datagram that references a RuleID unknown in
  its Context, or when decompression or reassembly fails, the resulting
  behavior is deployment-specific: the Datagram may be silently discarded,
  logged, or reported to the Instance Manager. This document does not
  define an architectural mechanism to signal such errors between
  Instances or to trigger the resynchronization of Contexts through the
  Domain Manager; this is identified as future work.

A deployment may define a separate error-signaling protocol or carry error
  information in a Control Header. If a Control Header is used for this
  purpose, its presence and format must remain determinable when the Rule
  referenced by the failed Datagram is unknown or cannot be applied. For
  example, a profile can define a fixed RuleID size and reserve a RuleID range
  for Datagrams followed by a known Control Header format. This document does
  not define the error messages or procedures.

<!--
## Lifecycle

## Management
-->

# Security Considerations

SCHC operation is sensitive to the integrity of the Contexts. Corrupted
  or tampered Rules could be abused to form arbitrarily long messages or
  as a form of attack against the C/D and/or F/R functions, e.g., to
  generate a buffer overflow and either modify the behavior of an Endpoint
  or crash it. It is thus critical that Contexts be distributed in a
  fashion that is protected against tampering, e.g., encrypted and signed.
  The entities that manage Contexts and Instance Configurations, such as
  the Domain Manager and the Instance Manager, must be authenticated and
  authorized; {{I-D.ietf-schc-access-control}} defines an access control
  model for SCHC Rules.

A more complete analysis of the risks specific to the SCHC architecture
  is to be provided in a future revision.

<!--
For an architecture document, the security section must analyze:

- Risks specific to SCHC architecture:
  - Compromise or corruption of rules (SoR) and impact on the integrity/
    confidentiality of flows.
  - Synchronization drift between SoR/SoV and risk of denial of service 
    (dropped or misrouted packets).
  - Attacks on the Instance Manager (e.g., injection of malicious rules).
  - Interactions with the security mechanisms of the underlying layers
    (PPP, Ethernet, IPsec, OSCORE, etc.).
- High-level mitigation measures expected in this architecture:
  - Authentication and authorization of entities that manage rules.
  - Logging/auditing of SoR changes.
  - Restoration and rollback of incorrect SCHC profiles.
-->

# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments {numbered="false"}

The authors would like to thank (in alphabetic order): Carles Gomez,
Carsten Bormann, Edgar Ramos, Eric Vyncke, Javier Alejandro Fernandez,
Laurent Toutain, Marco Tiloca, Rodrigo Munoz, and Sandra Cespedes, as well
as all participants of the SCHC Working Group.
