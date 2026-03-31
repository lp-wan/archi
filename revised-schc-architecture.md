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
  operations, e.g. compressing and decompressing headers, fragmenting and reassembling
  packets. Multiple Instances can coexist on the same Endpoint but each
  Instance operates independently, with its own Context and Configuration.

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

**Session**: A communication session between two Instances or more that share a
  common Context for SCHC operations.

**Set of Variables (SoV)**: Runtime parameters and session variables, such as
  fragmentation-related timers, retransmission counters, state flags, and other
  per-session values that may change during operation.

**Dispatcher**: An logical component of the Endpoint that routes packets to the
  appropriate Instances based on defined admission rules. It can be integrated
  into the network stack or implemented as a separate component.

**Discriminator**: An explicit or implicit information element included in SCHC
  Datagrams to identify the Instance that should process the packet. It is used by
  the Dispatcher to route packets to the appropriate Instance for decompression
  and reassembly.

**Domain**: A logical grouping of Instances that share a common set of Contexts
  for compression and fragmentation operations.

**Stratum**: A background concept that identifies a portion of the network protocol
  stack targeted by SCHC, i.e., the contiguous layers within which SCHC processing
  can be applied. The Stratum defines the scope of the protocol headers that the
  SCHC Rules in the associated Context can address.

**SCHC Datagram**: The unit exchanged between SCHC instances. A SCHC Datagram
  consists of a Rule Identifier (RuleID) and the result of the SCHC operation
  (if non-empty), such as a compression residue or a packet fragment. The SCHC
  Datagram may include an optional SCHC Control Header located at the beginning,
  and end with a Payload taken from the original packet.

**Control Header: A structure used to provide one or more control information
  elements in a SCHC Datagram whenever necessary. For example, it may contain a
  Discriminator to route a SCHC datagram to the correct instance.

**Domain Manager**: A logical component that manages the Domain, including
  context synchronization and profile distribution.

**Endpoint Manager**: A logical component that manages the lifecycle and
  configuration of Instances within an Endpoint. It is responsible for
  creating, updating, and deleting Instances as needed, synchronizing
  Contexts and Profiles, and managing the Dispatcher.

**Context Repository**: A logical component that stores and manages the
  Contexts used by its Domain.

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
At its core, SCHC reduces payload overhead by exploiting the predictable nature of network flows. 
Instead of transmitting full headers, both the sending and receiving Instances store a synchronized, 
static information of the expected headers (the Context). The sender replaces the known header fields 
with a highly compressed RuleID (and a residue of any changing fields). 
The receiver matches this RuleID against its local Context to perfectly reconstruct the original header.

SCHC may operate in multiple environments, from extremely constrained (LPWANs), to highly-capable, with 
simple or complex topologies.

This document provides an architecture in which both the simple and the complex operations of SCHC
can be developed. 


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



<!-- TODO: ORANGE EST LÀ, ORANGINA -->
<!-- TODO: ADD CHICKLET -->
<!-- TODO: REPRODUCE THE NEXT FIGURE WITHOUT multi-instance features. -->

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

To route an incoming SCHC Datagram to the correct Instance, the Dispatcher 
relies on a Discriminator. In most deployments, this Discriminator is external 
to the SCHC Datagram, derived entirely from lower-layer context (e.g., a specific PPP link, an IPv6 address, or a UDP port).

If external context is insufficient or unavailable, the Dispatcher MAY rely 
on the optional SCHC Control Header to convey the internal discriminator. When present, 
the SCHC Control Header is identified and parsed using its specific RuleID.


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


# SCHC Datagram Format {#DatagramFormat}

A SCHC Datagram is the unit exchanged between SCHC Instances.

It provides a unified representation for:
- compressed packets
- fragmented messages (fragments, acknowledgements, acknowledgement requests, ...)

A SCHC Datagram is composed of:

- a RuleID
- a SCHC Control Header
- a SCHC Data Header
- the Payload

```
+--------+----------------------+----------------------+------------------+
| RuleID | SCHC Control Header  | SCHC Data Header     | Payload          |
+--------+----------------------+----------------------+------------------+
```


## SCHC Control Header (Optional - Rule-Based)

The SCHC Control Header is a Rule-driven structure used by a specific Control Instance, which may provide one or more of the following services, whenever they are necessary:

- identify the SCHC Instance (Multiplexing)
- upon compression, render explicit Discriminator implicit (e.g. compressed IPv6 traffic over Ethernet will be transported with EtherType=SCHC, but the decompressor needs to know that the initial Discriminator was EtherType=0x8DD)
- validate the datagram (Protection)
- OAM, etc.

Example representations:

Non-compressed:
```
+------------------+-------------+------+
| SCHC Instance ID | Protocol ID | CRC  |
+------------------+-------------+------+
```

Compressed (rule-based):
```
+----------+----------------------+
| RuleID   | Compressed Residue   |
+----------+----------------------+
```

The SCHC Control Header MAY be:
- explicit
- partially elided
- fully implicit


### Advanced SCHC Control Header Use-Cases

In highly constrained, star-topology networks, the SCHC Control Header may be fully elided, with the Dispatcher 
acting purely as a multiplexer driven by an extrinsic Discriminator. However, in more complex, heterogeneous, 
or multi-hop deployments, a rule-based SCHC Control Header provides functionalities beyond simple Instance identification.

Implementing the Unified Rule Model for the SCHC Control Header enables the following advanced capabilities:
- Payload and Header Integrity: When Upper Layer Protocol (ULP) checksums (e.g., UDP or TCP) are elided during compression, the SCHC Control Header can carry an overarching Cyclic Redundancy Check (CRC). This protects the entire SCHC Datagram against corruption, ensuring invalid packets are dropped before expending processing power on decompression.
- Context Versioning and Synchronization: In environments where the Set of Rules (SoR) is dynamically updated (e.g. via CORECONF), the Control Header can carry a compressed Context Version ID or a rule hash. This may prevent race conditions by allowing the receiver to immediately detect a SoR mismatch and trigger a management update rather than outputting corrupted data.
- In-Band OAM (Operations, Administration, and Maintenance): Specific RuleIDs within the Control Header can be reserved for stratum-level OAM. This permits Endpoints to exchange telemetry, keepalives, or link-quality reports without consuming application payload space or invoking upper-layer protocols.
- Replay Protection and Sequence Numbering: For underlays lacking native security or sequencing, the Control Header can introduce a localized sequence number or cryptographic nonce. This allows the SCHC Control End-Point to discard duplicates and mitigate replay attacks at the ingress boundary.
- Mesh Routing and Multi-Hop Metadata: In non-star topologies, intermediate nodes may need to forward SCHC Datagrams without decompressing the Data Header. The Control Header can carry compressed routing metadata, such as hop limits or mesh-dispatch identifiers.

Architecturally, these functions are executed by the SCHC Control Instance during the initial ingress and dispatching phases. By validating, synchronizing, and securing the datagram early in the pipeline.



## SCHC Data Header (Rule-Based)


As defined in section 5.1 of [rfc8724], a **SCHC** datagram (or packet) is composed of the compressed header called the **SCHC** Data Header followed by the uncompressed remainder payload from the original datagram (or packet). The **SCHC** Data Header, contains the data generated by the **SCHC** operation. It is composed of a RuleID followed by the content described in the Rule. The content may be a C/D datagram, a F/R datagram, a CORECONF_Management or a Non Compressed datagram.

```
 <------ Compressed Header ------> <- Uncompressed Data ->

+------------------------------------------------------+
|                   SCHC Datagram                      |
+------------------------------------------------------+

+---------------------------------+--------------------+
|      SCHC Data Header           |      Payload       |
+---------------------------------+--------------------+

+----------+----------------------+--------------------+
|  RuleID  |    Rule Content      |      Payload       |
+----------+----------------------+--------------------+
```

Figure 3: **SCHC** Datagram

Figure 4 shows the compressed header format that is composed of the RuledID and a Compressed Residue, which is the output of compressing a datagram header with a Rule.

C/D Compressed **SCHC** Data Header:

```
+------------+----------------------+
|   RuleID   | Compressed Residue   |
+------------+----------------------+
```

F/R Compressed **SCHC** Data Header:

```
+------------+----------------------+--------+--...--+--------+
|   RuleID   | Fragmentation Header | Tile_1 |       | Tile_n |
+------------+----------------------+--------+--...--+--------+
```

CORECONF_Management **SCHC** Data Header:

```
+------------+----------------------+
|   RuleID   | Compressed Residue   |
+------------+----------------------+
```

Figure 4: **SCHC** Data Header


-
## Architectural Implications

- The Dispatcher routes SCHC Datagrams
- Instances process SCHC Datagrams
- Compression and fragmentation share a single abstraction
- Control and Data headers are unified under the same Rule model



# Deployment Models

This section describes how the SCHC architecture maps onto different
underlying technologies and protocols.

SCHC can be applied in a variety of environments and over multiple
protocol layers. Its initial design targeted constrained networks,
operating directly over MAC frames in LPWAN technologies such as
LoRaWAN {{RFC9011}}, IEEE Std 802.15.4 {{-SCHCo15dot4}}, and Sigfox
{{RFC9442}}.

SCHC can also operate over more general-purpose transports such as
Ethernet, IPv6, or UDP. In such cases, protocol identifiers are required
to signal the presence of a SCHC Datagram within the underlying layer.
For example, this may involve the allocation of an Ethertype, an IP
Protocol Number, or a UDP Port Number, as discussed in
{{-PN_and_Ethertype}}.

In all deployments, a SCHC Datagram MUST carry sufficient information to:

- identify the SCHC Instances involved,
- determine their respective roles (e.g., device or application), and
- associate the datagram with a SCHC Session.

Whenever needed, this information is conveyed by the optional SCHC Control Header, which is
interpreted using the Rule associated with its RuleID. 

Whenever present, The SCHC Control Header is transmitted
in a compressed form. This implies that the Rules required to interpret
the SCHC Control Header are known a priori by the participating
Endpoints, and are distinct from the Rules used to process the SCHC Data
Header.

The format and interpretation of the SCHC Control Header are therefore
deployment-specific and MUST be defined in a way that enables the
identification of the SCHC Session. Different deployments MAY define
different Rule sets and formats for this purpose.


## SCHC over PPP

The LPWAN architecture ({{Fig-LPWANnetarch}}) generalizes to deployments
involving peers of similar or heterogeneous capabilities.

In more capable environments, a SCHC Device MAY maintain multiple
SCHC Endpoints with:
- the same peer, or
- different peers.

Since SCHC Datagrams do not explicitly signal the Endpoint, this
information MUST be derived from lower-layer context, such as a
point-to-point connection.

In such cases, a SCHC Endpoint can be associated one-to-one with:
- a tunnel,
- a TLS session,
- a TCP connection, or
- a PPP connection.

{{-SCHCoPPP}} describes a deployment where SCHC compression (C/D)
and/or fragmentation (F/R) are performed between peers of comparable
capabilities over a PPP {{?rfc2516}} connection.

SCHC over PPP demonstrates that:
- the protocols to be compressed MAY be discovered dynamically, and  
- the Rules MAY be retrieved on demand (e.g., via CORECONF),  

ensuring that both peers operate with a consistent Set of Rules.

~~~~
    +----------+  Wi-Fi /   +----------+                ....
    |    IP    |  Ethernet  |    IP    |            ..          )
    |   Host   +-----/------+  Router  +----------(   Internet   )
    | SCHC C/D |  Serial    | SCHC C/D |            (         )
    +----------+            +----------+               ...
                <-- SCHC -->
                  over PPP
~~~~
{: #Fig-PPPnetarch title="PPP-based SCHC Deployment"}

In this configuration, the SCHC Endpoint is derived from the PPP
connection. As a result:

- There is exactly one SCHC Endpoint per PPP connection.
- All traffic within that connection belongs to that Endpoint.

As discussed in {{EndPoints}}, the Uplink direction corresponds to
traffic sent from the node that initiates the PPP connection toward
the peer that accepts it.


## SCHC over Ethernet

When operating over Ethernet, a SCHC Datagram is encapsulated within
an Ethernet frame using a dedicated Ethertype.

Conceptually, the Rule used to process the SCHC Datagram is associated
with the protocol being compressed (e.g., IPv6). The RuleID and Rule
Content together encode the transformation applied to that protocol.

~~~~
                    |<----------------- SCHC Datagram ----------------->|
 +------------------+--------+----------------+-------------+-----------+
 | IEEE 802 Header  | SCHC   | SCHC           | SCHC        | Compressed|
 | Ethertype=SCHC   | RuleID | Control Header | Data Header | Residue   |
 |                  |        | (Next Proto == |             |           |
 |                  |        |  IPv6, ARP,...)|             |           |
 +------------------+--------+----------------+-------------+-----------+
~~~~
{: #Fig-SCHC_hdr title="SCHC over Ethernet"}

The SCHC Control Header contains the information required
to identify the correct Instance to process the SCHC Data Header.

In practice, this information MAY be:
- explicit,
- compressed, or
- fully implicit based on the Context.


## SCHC over IPv6

When SCHC operates over IPv6, the SCHC Datagram is identified using a
dedicated IP Protocol Number.

In this configuration:

- The IPv6 Next Header field identifies SCHC.
- The SCHC Control information MAY be inferred from the IPv6 header
  (e.g., source/destination addresses) when the Context allows it.

~~~~
                    |<----------------- SCHC Datagram ----------------->|
 +------------------+--------+----------------+-------------+-----------+
 | IPv6 Header      | SCHC   | SCHC           | SCHC        | Compressed|
 | NH = SCHC        | RuleID | Control Header | Data Header | Residue   |
 |                  |        | (Next Proto == |             |           |
 |                  |        |  UDP, QUIC,...)|             |           |
 +------------------+--------+----------------+-------------+-----------+
~~~~
{: #Fig-SCHC_hdr1 title="SCHC over IPv6"}

In this case:

- The SCHC Datagram MAY protect the payload using a checksum carried
  in the Rule Content.
- Upper Layer Protocol (ULP) checksums MAY be elided if equivalent
  protection is provided.

The SCHC Session is typically derived from:
- IPv6 source and destination addresses.


## SCHC over UDP

When SCHC operates over the Internet, some middleboxes may block packets
that use an unknown IP Protocol Number.

To improve traversal, SCHC Datagrams MAY be encapsulated over UDP.

~~~~
                    |<----------------- SCHC Datagram ----------------->|
 +------------------+--------+----------------+-------------+-----------+
 | UDP Header       | SCHC   | SCHC           | SCHC        | Compressed|
 | Port=SCHC        | RuleID | Control Header | Data Header | Residue   |
 |                  |        | (Next Protocol)|             |           |
 +------------------+--------+----------------+-------------+-----------+
~~~~
{: #Fig-SCHC_hdr2 title="SCHC over UDP"}

In this configuration:

- The UDP destination port identifies SCHC.
- The IP source/destination + UDP source port MAY identify the SCHC Session.


## SCHC Endpoints for LPWAN Networks {#EndPoints}

Section 3 of {{RFC8724}} describes a typical LPWAN network architecture,
derived from {{RFC8376}} and illustrated in {{Fig-LPWANnetarch}}.

~~~~
 ()   ()   ()       |
  ()  () () ()     / \       +---------+
() () () () () () /   \======|    ^    |             +-----------+
 ()  ()   ()     |           | <--|--> |             |Application|
()  ()  ()  ()  / \==========|    v    |=============|   Server  |
  ()  ()  ()   /   \         +---------+             +-----------+
 Dev            RGWs             NGW                      App
~~~~
{: #Fig-LPWANnetarch title="Typical LPWAN Network Architecture"}

LPWAN networks typically follow a star topology, where:

- Devices (Dev) communicate with Application Servers (App)
- through a Network Gateway (NGW).

In this model:

- Devices are highly constrained.
- Gateways and servers are less constrained.

Because:
- applications are often embedded in Devices, and  
- traffic patterns are known in advance,  

The SCHC Context (including Rules for C/D and F/R) can be
**pre-provisioned**. 







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
