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

**Dispatcher**: An logical component of the Endpoint that routes packets to the
  appropriate Instances based on defined admission rules. It can be integrated
  into the network stack or implemented as a separate component.

**Discriminator**: An optional information element used by the Dispatcher to
  route SCHC Datagrams to the appropriate Instance. The discriminator can be a
  combination of several criteria.

**Parser**: A software tool or component that dissects and analyzes network
  packets, to extract meaningful information such as source and destination
  addresses, port numbers, and payload data.

**Domain**: A logical grouping of Instances that share a common set of Contexts
  for SCHC operations.

**Stratum**: A background concept that identifies a portion of the network
protocol stack targeted by SCHC, i.e., the contiguous layers within which SCHC
processing can be applied. The Stratum defines the scope of the protocol
headers that the SCHC Rules in the associated Context can address.

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

# Architecture {#Architecture}

This section provides an overview (diagrams) and describes the principal
entities and their relations (architectural semantics). It must reference the
definitions given in the previous section.

When a paragraph describes the basic operation of SCHC already covered by RFC 8724,
replace it with a brief summary + normative reference rather than re-explaining it.

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

### SCHC: Quick Reminders

<!-- TODO: This section should explain the basic operation and components of
SCHC defined in RFC 8724, such as Rules. -->

SCHC is a framework designed to efficiently compress headers of network packets.
  It reduces payload overhead by exploiting the predictable nature of network
  flows. Instead of transmitting full headers, both the sending and receiving
  Instances store a synchronized, static information about expected headers:
  the Context, which contains Rules. Using a Rule that matches the headers of
  a packet to be transmitted, the sender replaces the known header fields with
  a short RuleID which identifies the rule that applies, and a compression
  residue if any, forming a SCHC Datagram. The receiver of this SCHC Datagram
  matches the RuleID against its own Context and applies decompression actions
  to reconstruct the original header.

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
  best-match), the Instance’s role (in the case of asymmetric processing), etc.

**Important notice**: having the same Context is not sufficient to guarantee
  the interoperability of SCHC operations between two Instances. The format of
  the data obtained from the Parser when processing the headers must be
  consistent on each Endpoint to allow the successful decompression. To ensure
  interoperability, the Context may specify which Parser to use to delineate
  the header fields, and/or which Data Model, such as the one defined in
  {{RFC9363}}.

Instances sharing a common Context form a Domain. The Domain Manager is
  responsible to manage the Contexts of all Instances that belong to it.
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
              SCHC Datagrams exchanged inside a Session         

~~~~~~~~
{: #Fig-Simple-Overview title='Overview of two simple Endpoints exchanging
SCHC Datagrams'}

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

This section considers a typical LPWAN deployment where an IoT device
  communicates with a gateway or server using SCHC for header compression and
  decompression. In this scenario, SCHC is used to compress the CoAP,
  UDP, and IPv6 headers before sending the datagrams over the LPWAN link layer.
  SCHC is used as an adaptation layer between the IPv6 layer and the LPWAN link
  layer to compress the headers of the datagrams such that they fit within the
  constraints of the LPWAN link layer.

  In this setup, each device features a single SCHC Instance in a single SCHC 
  Endpoint. Each Instance is pre-configured with a static Context.

  The Discriminator is a field value within the LPWAN link layer, e.g. LoRAWAN
  frame port (fPort) and the Dispatcher is hardcoded 
  in the network stack: all traffic with pre-defined fPort or device ID are 
  dispatched to the SCHC Instance.


~~~~~~~~
             Host A, IoT Device       Host B, Gateway/Server
            +------------------+       +------------------+
            |  Application A   |       |  Application B   |
            +------------------+       +------------------+
            |       CoAP       |       |       CoAP       |
            +------------------+       +------------------+
            |       UDP        |       |       UDP        |
            +------------------+       +------------------+
            |       IPv6       |       |       IPv6       |
            +------------------+       +------------------+
            |       SCHC       |       |       SCHC       |
            +------------------+       +------------------+
fPort = xxx | LPWAN Link Layer |       | LPWAN Link Layer | fPort = xxx
            +------------------+       +------------------+
            |  Physical Layer  |       |  Physical Layer  |
            +------------------+       +------------------+
                    |                           |
                    +---------------------------+
~~~~~~~~


| Core Element     | Notes          |
|------------------|----------------|
| Domain           | single         |
| Endpoint         | single         |
| Instance         | single         |
| Context          | pre-configured |
| Discriminator    |  fPort         |
| Dispatcher       | hardcoded      |


  


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



# Operational considerations

Management, Data Models, SCHC Endpoint lifecycle (provisioning,
context synchronization), Interoperability, Error handling,
Same context vs. compatible contexts, etc.

## Data Models

## Lifecycle

## Management

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
  Instance for each link, or storing the entire SoR on each node, leafs nodes
  only store the rules necessary for their communication with the root.
  It should be noted that there may be a risk that the root user uses a rule
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
