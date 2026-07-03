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
  DRAFT-SCHCLET:
    =: I-D.ietf-schc-schclet


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
- Which assumptions remain (constrained devices, intermittency, etc.)
  and which are no longer necessary in richer environments.

Indicate what this document is not intended to do (e.g., it does not replace
  RFC 8724, it does not specify new header formats, etc.).
-->
# Requirements Language

{::boilerplate bcp14}

Check the use of normative keywords.
(ex.: "Since {{RFC8724}} requires X, an architecture compliant with this
document MUST ...")
Be very clear about what constitutes a "requirement on implementations" versus
a "recommendation on deployments."
Ensure that you do not introduce requirements that would contradict RFC 8724
or existing profiles (SCHC over LoRaWAN, NB-IoT, etc.).

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

**Dispatcher**: Entity that uses the Discriminator to route a Datagram to the 
   appropriate Instance.  The Dispatcher can be integrated into the network 
   stack or be a separate component (for example, the VOICI handler {{I-D.lampin-voici}}). 

**Discriminator**: Information element derived from the Carrier Layer that 
   enables the selection of the correct Instance. The Discriminator can be an 
   **explicit** field in the Datagram or frame (for example, a 6LoWPAN Dispatch
   byte, a VOICI Session ID).

**Carrier Layer**: The layer adjacent to and below the Stratum's lower boundary,
   from which the Discriminator is derived. The Carrier Layer is outside the 
   Stratum and not addressable by the Instance's Rules. Examples include IEEE 
   802.15.4, LPWAN links, PPP frames.

**Parser**: A software tool or component that dissects and analyzes network
   packets, to extract header fields such as source and destination
   addresses, port numbers, and payload data.

**Domain**: A logical grouping of Instances that share a common set of Contexts
   for SCHC operations.

**Stratum**: A background concept that defines the scope of headers an Instance
  addresses.  It is expressed as a contiguous range **[lower boundary, upper
  boundary]** of protocol layers, where both boundaries are inclusive.  If
  lower boundary equals upper boundary, the Stratum spans a single layer.
  Headers originating from above the upper boundary are unaffected by the
  Instance.  The term "Stratum" originates from the idea of layers in a
  network stack but is applicable beyond the network stack, for instance to
  application-layer protocol headers.

**Datagram**: The unit exchanged between SCHC instances. A Datagram
  consists of a Rule Identifier (RuleID) and the result of the SCHC operation
  (if non-empty), such as a compression residue or a packet fragment. It ends
  with a Payload taken from the original packet (if any).

<!--
**Control Header**: A structure used to provide one or more control information
  elements in a SCHC Datagram whenever necessary. For example, it may contain a
  Discriminator to route a SCHC Datagram to the correct instance.
-->

**Domain Manager**: A logical component that manages the Domain, including
  context synchronization and configuration distribution.

**Instance Manager**: A logical component that manages the lifecycle and
  configuration of Instances within an Endpoint. It is responsible for
  creating, updating, and deleting Instances as needed, synchronizing
  Contexts, and managing Instance Configurations.

**Endpoint Manager**: 

**Context Repository**: A logical component that stores and manages the
  Contexts used by its Domain.

**C/D**: SCHC function that performs the Compression and Decompression of headers.

**F/R**: SCHC function that performs the Fragmentation and Reassembly of headers.

**MO**: Matching Operator

**CDA**: Compression/Decompression Action

# SCHC: Primer

<!-- TODO: This section should explain the basic operation and components of
SCHC defined in RFC 8724, such as Rules. -->

SCHC is primarily a compression mechanism for structured datagrams comprising
  headers. It reduces the size of these datagrams by exploiting predictable
  patterns found in application data and network header structures (e.g., static
  field values, network prefixes in addresses, known port numbers).

Instead of transmitting headers in full, the sender replaces known header
  fields with a compressed residue and an identifier -- a **RuleID** that 
  instructs the receiver how to reconstruct the original headers. 
  Both the sender and receiver share the **set of Rules** (SoR) needed for this
  process through a shared **Context**.

This shared Context may be static, for example pre-provisioned with the device
  firmware or installed dynamically. In the latter case, the logical grouping 
  that share the same context, and therefore require timely and coordinated 
  updates, is called a **Domain**.

Compression and decompression occur in SCHC **Instances** — logical entities
  that:
   - Match datagram headers against Rules and compress them
   - Identify the Rule used by the compressor (via RuleID) and reconstruct the
     headers on decompression

Each Instance addresses a set of adjacent headers — for example, the IPv6, 
  UDP and CoAP headers in a network stack. This "slice" of the stack is called
  a **Stratum** and is defined by a lower boundary (the layer closest to the
  physical interface) and an upper boundary (the highest layer in the stack).

## SCHC Invocation: Network Service vs. Application Service {#sec-schc-invocation}

SCHC can be used in two fundamentally different ways.

**Case A: SCHC as a Network Service.**  The SCHC Instance acts on headers the 
  stack itself needs to inspect and route. By itself, an Instance cannot 
  intercept packets in the network stack, and SCHC is not a protocol residing in
  the stack. Because SCHC is not a protocol in the stack, an entity of the network
  stack, the **Dispatcher**, routes Datagrams to and from Instances. 
  
  On the compressor side, the Dispatcher intercepts **Native** Datagrams 
  targeted by an Instance after the network protocols of the Stratum have 
  finished processing the Datagram. The Dispatcher then dispatch the Native 
  Datagram to the Instance which compresses the Datagram to form the SCHC 
  Datagram. The SCHC Datagram is then reinjected into the network stack at the
  adjactent layer below the Stratum -- the **Carrier** Layer. Eventually, the 
  Dispatcher fills the Carrier **Discriminator**, a value of the Carrier header
  that indicates the Datagram is compressed with SCHC. The SCHC Datagram is then
  processed further by the network stack and sent to its recipient.
  
  On the decompressor side, the SCHC Datagram is delivered by the network stack
  to the Dispatcher, eventually identified by the Carrier Discriminator.
  The Dispatcher delivers the SCHC Datagram to the appropriate Instance, which 
  processes the SCHC Datagram to reconstruct the headers of the Stratum. Once 
  reconstructed, the Dispatcher restore the Carrier Layer with the Native
  Datagram field values, for instance when a Carrier Discriminator is used.

  The Datagram is further processed by the Network stack, as would the Native
  Datagram be processed.

The same core architectural concepts (Instance, Context, Rule, Stratum, Domain) 
  apply in both cases.  What differs is the routing and configuration mechanism:
  Carrier Layer, Discriminator and Dispatcher apply only to Case A.

For example, in the 6Lo scenario detailed below, the Instance addresses an 
  IPv6/UDP/CoAP Stratum above the 802.15.4 L2 header. The Dispatcher is the 
  stack routine that redirects frames bearing the SCHC Dispatch byte (`0100 0100`)
  to the correct Instance. The Dispatch byte is the **Discriminator** — the 
  information element the Dispatcher uses to route SCHC Datagrams.

The Discriminator usually sits in the adjacent layer below the Stratum lower
  boundary, outside the scope of addressable (compressible) headers for the SCHC
  instance.

**Case B: SCHC as an Application Service.**  The Instance is invoked by the
  application's processing pipeline, compressing data that does not affect the
  network stack processing. The application calls the Instance as a library 
  function, in an order the application dictates. No Dispatch, or Discriminator 
  is needed. The Instance's Invocation Context is the application's processing 
  stage.


# Architecture

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

## Overview of a Basic Architecture

### Basic SCHC Architecture

{{Fig-Simple-Overview}} illustrates how messages are exchanged between
  applications running on two remote hosts using SCHC Compression/Decompression
  and optionally Fragmentation/Reassembly.

Each host features an **Endpoint** that implements SCHC functions. The effective
  Compression/Decompression or Fragmentation/Reassembly of datagrams is carried
  out by the **Instance**, a runtime entity.

How Compression/Decompression and Fragmentation/Reassembly is performed by 
  each Instance is specified in two configuration elements: the **Context**
  which contains the configuration shared and identical between the two 
  Instances and the **Instance Configuration** which is specific to each 
  Instance.

Most notably, the Context contains the **Set of Rules** (SoR), which defines how
  datagrams are compressed and/or fragmented, and the Instance Configuration 
  specifies which role each Instance assumes (Uplink/Downlink).

The two Instances that share the same Context form a **Session**, eventually 
identified by a **Session ID** which is then specified in the Context.

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
              SCHC Datagrams exchanged inside a Session         

~~~~~~~~
{: #Fig-Simple-Overview title='Overview of two simple Endpoints exchanging
SCHC Datagrams'}


**Important notice**: having the same Context is not sufficient to guarantee
  the interoperability of SCHC operations between two Instances. The format of
  the data obtained from the Parser when processing the headers must be
  consistent on each Endpoint to allow the successful decompression. To ensure
  interoperability, the Context may specify which Parser to use to delineate
  the header fields, and/or which Data Model, such as the one defined in
  {{RFC9363}}.

### Provisioning of SCHC configurations

Quentin is HERE. In the above scenario, the Context 

Instances sharing a common Context form a **Domain**. The Domain Manager is
  responsible to manage the Contexts of all Instances that belong to it.
  A communication between two Instances or more that share a common Context is
  called a Session. Each Instance, Context, and Session must be uniquely
  identifiable to allow the Domain Manager to update the Context of a specific
  Instance.

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
{: #Fig-Domain-Manager title='Overview of the functions of the Domain Manager'}

## Focus on core components

### Instance

An Instance is the fundamental component that runs a set of SCHC functionalities
  as defined in {{RFC8724}} hosted on an Endpoint. Its operation is defined by
  an Instance Configuration and a Context. An Endpoint MAY execute several
  Instances. Each Instance operates independently, with its own Context and
  Instance Configuration. Instance mays execute dynamic Context update
  mechanisms and performance monitoring and reporting in complex scenarios.
  
#### Instance Configuration
  
The Instance Configuration specifies the local parameters of the Instance.

The Instance Configuration may indicate in a Manifest the set of required
SCHC functionalities, such as:

- Header Compression and Decompression (C/D)
- Fragmentation and Reassembly (F/R)
- SCHClets (nodular subfunctions)

The Instance Configuration may also include the following parameters:

- Role of the Instance (e.g., Upside or Downside for asymetric Rules).
- Matching policy (e.g., first-match, best-match, etc.) to apply when multiple
  rules match a packet.
- Packet interception criteria (e.g., Stratum - the protocol headers that the
  SCHC Rules in the associated Context can address, Filters based on specific
  values or characteristics of packets, etc.)
- Dispatch information (e.g., how to identify the Instance for incoming
  packets, how to route packets to the appropriate Instance, etc.).

#### Context

The Context contains operational information shared between two or more
Instances.

For example, for Header Compression and Decompression (C/D) or Fragmentation
  and Reassembly (F/R), the Context defines the set of C/D and F/R Rules - or
  Set of Rules - describing the specific actions to be performed on the packets
  using the corresponding SCHC functionalities, and, optionally, the Parser and
  the Data Model to delineate and dissect the header fields.

### Endpoint

A network entity providing SCHC functionalities, and hosting the Instances
that consist of a specific execution of one or more of these aforementionned
functionalities.

#### Header Compression and Decompression (C/D)

This component is responsible for compressing and decompressing headers
  using the SCHC framework, as described in {{RFC8724}}. It applies the rules
  defined in the Context.

  The C/D engine MUST expose the following interface:

- `compress(buffer, context, config)`: Compresses the provided buffer using the
   Context and the Instance Configuration.
- `decompress(buffer, context, config)`: Decompresses the provided buffer using
   the Context and the Instance Configuration.

Internally, on compression, the C/D engine:

- delineates the fields using the Parser and/or Data Model provided in the Context;
- chooses the appropriate compression Rule among candidate Rules from the Context
  based on the matching policy defined in the Instance Configuration;
- applies the compression Rule to the fields of the header(s);
- generates the compressed SCHC Datagram.
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
  fragments and reassembling them at the receiving end. It is optional feature
  but recommended for scenarios where packet sizes may exceed the maximum
  transmission unit (MTU) of the underlying network. In {{RFC8724}}, the
  pieces of a SCHC Packet that has been fragmented are called SCHC Fragments.

#### SCHClets

A SCHClet is a self-contained unit within the SCHC framework that implements
  a specific SCHC function or a subset of SCHC operations. A SCHClet may
  implement aspects defined in {{RFC8724}} or functions from other related
  SCHC RFCs, and MAY be combined with other SCHClets within an Instance, as
  speficied in the Manifest in the Instance Configuration.

#### Multiple Instances

An Endpoint can host multiple Instances, each with its own Context and Instance
Configuration.

When an Endpoint is supporting multiple Instances, the Instance Manager is
  responsible for managing the lifecycle and configuration of these Instances.
  Datagrams are routed to the appropriate Instance by the Dispatcher using
  the Discriminator and admission rules based on information provided in the
  Instance Configuration. The Dispatcher is a single point of decision for
  packet forwarding within the Endpoint.

In some deployments, the Discriminator is derived entirely from lower-layer
context (e.g., a specific PPP link, an IPv6 address, or a UDP port).
If external context is insufficient or unavailable, the Dispatcher may need an
explicit Discriminator. For example, Datagrams can be encapsulated in a light
transport protocol whose header contains a Session, Context, or Instance
identifier, and can provide additional services such as integrity checking (CRC).

The following figure illustrates the main components of an Endpoint supporting
  multiple Instances and their interactions:

~~~~~~~~
    +-------------------+         +----------------+         
    | Instance Manager  |         | SCHC Functions |         
    +-------------------+         +----------------+         
 manages lifecyle  | |                      ^                
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
{: #Fig-Multiple-Instances title='Overview of an Endpoints hosting multiple
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
  may be used as a Discriminator to route the Datagrams to the correct
  Instance (e.g., to distinguish between the two Instances of Endpoint B), 
  and/or for management purpose. 

~~~~~~~~
  +------------------------------+      +------------------------------+  
  |      Domain Manager 1        |      |       Domain Manager 2       |
  +------------------------------+      +------------------------------+  
          ^                   ^            ^               ^            
          |                   |            |               |           
          v                   v            v               v           
  +----------------+      +-------------------+      +-----------------+  
  |   Endpoint A   |      |    Endpoint B     |      |   Endpoint C    |  
+-----------------------------------------------+    |                 |  
| | +-----------+  |      |   +-----------+   | |    |                 |  
| | | Instance  |<----------->| Instance  |   | |    |                 |  
| | +-----------+  |      |   +-----------+   | |    |                 |  
+--------------------|--------------------------+    |                 |  
  |                | |  +------------------------------------------------+
  |                | |  | |   +-----------+   |      |   +-----------+ | |
  |                | |  | |   | Instance  |<------------>| Instance  | | |
  |                | |  | |   +-----------+   |      |   +-----------+ | |
  |                | |  +-------------------------|----------------------+
  |                | |    |                   |   |  |                 |
  +----------------+ |    +-------------------+   |  +-----------------+  
                     |                            |                       
                     |                            |                       
                     +---> Domain 1               +-> Domain 2            
~~~~~~~~
{: #Fig-Domains title='Overview of multiple Domains'}

### Datagram Format {#DatagramFormat}

A Datagram is the unit exchanged between SCHC Instances.

It provides a unified representation for:

- compressed packets
- fragmented messages (fragments, acknowledgements, acknowledgement requests,
...)

A Datagram is composed of:

- a RuleID
- the result of the SCHC operation (residue, fragment)
- the Payload

The result of the SCHC operation and the Payload may be empty.
As stated in {{RFC8724}}, a Datagram resulting from a compression operation is
called a SCHC Packet, and a Datagram resulting from a fragmentation operation
is called a Fragment.

~~~~~~~~
+--------+------------------------+----------+
| RuleID | Residue, Fragment, ... | Payload  |
+--------+------------------------+----------+
~~~~~~~~
{: #Fig-Datagram title='Datagram Format'}

#### Control Header for Advanced Use Cases

In some deployments, it may be necessary to add information to the Datagram so
that it can be properly routed to the correct Instance.  
This information may be contained in a specific control structure, external to
the Datagram, such as the header of an underlying transport protocol.

This structure may be used to carry various types of information in order to
provide functionalities such as:

- Multiplexing (Session, Instance, Context Identifier)
- Protection (Integrity)
- Metadata (Retain information that is lost when performing the SCHC operation,
e.g., save the initial value of the EtherType field when it is changed to
EtherType=SCHC)

Example representation:

~~~~~~~~
+-------------+-----+---------------+
| Instance ID | CRC | SCHC Datagram |
+-------------+-----+---------------+
~~~~~~~~
{: #Fig-Transport title='SCHC Datagram encapsulated into a transport protocol'}

**Important notice**: The structure or transport protocol used to carry these
control informations must be a standard format and/or protocol in order to
ensure interoperability. Therefore, it might be desirable to design a new
protocol tailored to the needs of SCHC, such as a lightweight version of UDP.
Various header formats would then be defined to support the aforementioned
functions.

# Deployment models

Give deployment examples (point to point, point to multipoint,
multi-instances, SCHC with cryptographic boundaries, etc.) and link them to
specific technologies (LPWAN, PPP, Ethernet, 6Lo, etc.)
## LPWAN deployment

This section considers a typical LPWAN deployment where an IoT device communicates 
with a gateway or server using SCHC for header compression and decompression. 
The Instance's Stratum spans [IPv6, UDP, CoAP] — meaning the Rules in its 
Context can address headers across all three protocol layers. The Carrier Layer
(LPWAN link) adjacent below the Stratum's lower boundary carries the Discriminator
in a frame field such as the LoRaWAN frame port (fPort).

In this setup, each device features a single SCHC Instance in a single Endpoint.
Each Instance is pre-configured with a static Context. The Discriminator is an
explicit field in the LPWAN frame (e.g., fPort) and the Dispatcher is hardcoded
in the network stack.

~~~~~~~~

LPWAN deployment — Stratum annotated as range

    Host A, IoT Device              Host B, Gateway/Server
   +------------------+             +------------------+
   |   Application A  |             |   Application B  |
   +------------------+             +------------------+ -+ Upper boundary: CoAP
   |       CoAP       |             |       CoAP       |  | 
   +------------------+             +------------------+  |
   |       UDP        |             |       UDP        |  |   Stratum
   +------------------+             +------------------+  |
   |       IPv6       |             |       IPv6       |  |
   +------------------+             +------------------+ -+ Lower boundary: IPv6
   | LPWAN Link Layer |             | LPWAN Link Layer | - Carrier Layer,
   +------------------+             +------------------+   discriminator: fPort
   |  Physical Layer  |             |  Physical Layer  |
   +------------------+             +------------------+
           |                           |
           +---------------------------+
                   LPWAN link
                 
~~~~~~~~

| Core Element     | Notes                        |
|------------------|------------------------------|
| Domain           | single                       |
| Endpoint         | single                       |
| Instance         | single                       |
| Context          | pre-configured               |
| Stratum          | [IPv6, UDP, CoAP]            |
| Carrier          | Link Layer                   |
| Discriminator    | fPort                        |
| Dispatcher       | hardcoded in network stack   |


  


## 6Lo deployment

Placeholder description text 

~~~~~~~~


                                                   Host E
                    (RuleID 2, E2)                /
                    (RuleID 1, E1)      +--------+
                    (RuleID 2, E1)  --- |Internet|
                    (RuleID 3, E1) /    +--------+
                   6LBR -----------
                 /      \
                /        \
              6LR         6LR -------------+            Nodes | End point
(RuleID 1, E1) |         | (RuleID 1, E1)  |   RuleID 1: A, B      E1
(RuleID 2, E1) |         | (RuleID 2, E1)  |   RuleID 2: A, C      E1
(RuleID 3, E1) |         | (RuleID 3, E1)  |   RuleID 3: A, E      E1
(RuleID 2, E2) |         | (RuleID 2, E2)  |   RuleID 2: A, B      E2
               |         |                 |
              Host A      Host B         Host C
        (RuleID 1, E1)    (RuleID 1, E1)   (RuleID 2, E1)
        (RuleID 2, E1)    (RuleID 2, E2)
        (RuleID 3, E1)
        (RuleID 2, E2)
~~~~~~~~

| Core Element     | Notes          |
|------------------|----------------|
| Domains          | 2              |
| Endpoint         | 1 per device   |
| Instance         | 2, I1 & I2     |
| Contexts         | pre-configured |
| Discriminator    | session ID     |
| Dispatcher       | VOICI ?        |



## Deployment Example: OSCORE-Protected CoAP

A detailed walkthrough of the OSCORE-protected CoAP scenario demonstrates how
all architectural concepts (Stratum, Carrier Layer, Discriminator, Dispatcher,
Invocation Context) apply across Network Service and Application Service
invocation modes within a single packet.

**Scenario**  An IoT sensor (6LN) sends a CoAP POST to a server via a 6LBR,
secured with OSCORE, and compressed by SCHC at three Strata.  All three
Instances reside on both the 6LN and the 6LBR.

**Setup.**

- IP: sensor `fd00:1::1` → server `fd00:1::2`
- UDP: original port 5683 → 5683
- VOICI Original port: 5683
- OSCORE: sender ID `0x01`, recipient ID `0x02`, partial IV context known
- CoAP inner: `POST /temp` {reading: 42}
- CoAP outer: Uri-Path `"sensors/temp"`, Token containing partial IV

**Three Instances on each 6LN and 6LBR:**

| Instance   | Stratum [lower, upper] |  Carrier | Discriminator |        Invocation       |
|------------|------------------------|----------|---------------|-------------------------|
| I1 (L2.5)  |      [IPv6, UDP]       | 802.15.4 | Dispatch byte | Network Service (A)     |
| I2 (outer) |      [CoAP outer]      |   VOICI  |  Session ID   | Network Service (A)     |
| I3 (inner) |      [CoAP inner]      |   N/A    |     N/A       | Application Service (B) |

**Sender-side (high to low):**

```
Step 1: Application produces CoAP inner header
     CoAP inner: Code=POST, Uri-Path="temp", payload: {reading: 42}

Step 2: I3 compresses CoAP inner header → residue
Step 3: OSCORE encrypts compressed inner + payload → ciphertext
Step 4: CoAP outer header assembled, Token carries partial IV
Step 5: I2 compresses CoAP outer header → residue, Token field preserved
Step 6: VOICI encapsulation: V=0, O=1, I=0, CI=1, Session ID for I2
     VOICI O flag: original UDP port = 5683
Step 7: IPv6 src=fd00:1::1, dst=fd00:1::2 + UDP port_schc:port_schc
Step 8: I1 compresses IPv6 + UDP + VOICI → residue
Step 9: On wire: [SCHC Dispatch 01000100] [I1 residue] [ciphertext]
```

**Receiver-side (low to high):**

```
Step 1: Frame received, Discriminator: Dispatch byte = 01000100
     Dispatcher routes → I1 (Network Service, Case A)
     I1 decompresses → IPv6 + UDP + VOICI headers

Step 2: Stack demux: IPv6 → NH=UDP → UDP dst=port_schc → VOICI handler

Step 3: VOICI dispatches: Session ID → I2 (Network Service, Case A)
     I2 decompresses → CoAP outer header

Step 4: VOICI reconstructs: original UDP port = 5683, feeds back to stack

Step 5: CoAP handler receives outer message, OSCORE decrypts ciphertext
     → [I3 residue] {reading: 42}

Step 6: CoAP pipeline invokes I3 (Application Service, Case B)
     I3 decompresses → CoAP inner: Code=POST, Uri-Path="temp"

Step 7: Application receives CoAP POST to /temp, payload {reading: 42}
```

**Key observations:**

1. **Two invocation modes in one packet.**  I1 and I2 are Network Services
   (Case A), invoked through Dispatchers using explicit Discriminators (L2
   Dispatch byte and VOICI Session ID respectively).  I3 is an Application
   Service (Case B), invoked by the CoAP/OSCORE processing pipeline.  All
   three use the same architectural concepts (Instance, Context, Rule,
   Stratum).

2. **Carrier Layer and Discriminator apply to I1 and I2, not I3.**  I1 has a
   Carrier Layer (802.15.4) and an explicit Discriminator (Dispatch byte).
   I2 has a Carrier Layer (VOICI header) and an explicit Discriminator
   (Session ID).  I3 has neither — the CoAP/OSCORE processing pipeline selects
   it intrinsically.

3. **Network transparency of Application Service.**  I1 and I2 are invoked
   from the network stack; the stack routes frames to I1 using the L2 Dispatch
   byte, and I1's output (including VOICI) reaches I2 through standard
   demuxing.  I3 operates entirely within the CoAP/OSCORE processing pipeline
   and is transparent to the network layer.

4. **Rule design carries cross-Instance constraints.**  I2's Rules must preserve
   the Token field (partial IV) because OSCORE needs it downstream.  I1's Rules
   must preserve IPv6 Next Header and UDP header for stack demux.  I3 does not
   impose such constraints — it operates on the innermost plaintext headers.

This example demonstrates that SCHC scales uniformly from network-layer to
application-layer compression within a single packet.  The architecture's core
concepts (Instance, Context, Rule, Stratum) apply across both invocation modes,
while network-specific concepts (Carrier Layer, Discriminator, Dispatcher,
Domain) are restricted to Case A.

# Operational considerations

Management, Data Models, SCHC Endpoint lifecycle (provisioning,
context synchronization), Interoperability, Error handling, etc.

# Security Considerations

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

# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments {numbered="false"}

The authors would like to thank (in alphabetic order): Laurent Toutain.
