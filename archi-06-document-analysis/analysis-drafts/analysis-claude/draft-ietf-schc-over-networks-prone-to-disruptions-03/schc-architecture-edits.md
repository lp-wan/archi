# SCHC Architecture -06 edits needed for draft-ietf-schc-over-networks-prone-to-disruptions-03

## Purpose

Two notions central to draft-ietf-schc-over-networks-prone-to-disruptions-03 are permitted by
draft-ietf-schc-architecture-06 but only implicitly: (1) that the unit admitted to a SCHC
Instance may be an application-layer data unit (an "object"), i.e., that the Stratum may extend
to the application layer — required to express the draft's use of SCHC F/R as a delay-tolerant
object transport; and (2) that an Endpoint may be deployed on an intermediate node and
participate in distinct Sessions toward each side (proxy/relay deployment) — required to express
the draft's SCHC Proxy (general architecture in its Section 4.1, and the LEO satellite proxy in
its Section 4.4.1). Both gaps close with small additive clarifications; no existing definition
changes meaning and no architectural concept is added, removed, or re-scoped.

## Proposed edits

Edit 1 — Application-layer Stratum / object as admitted unit
- Architecture section: Section 3 (Terminology), definition of "Stratum"
- Architecture concept: Stratum; unit admitted to an Instance
- Reason: draft-ietf-schc-over-networks-prone-to-disruptions-03 uses SCHC F/R as "a simple
  transport protocol for the whole object instead of only fragmenting IP packets" (its
  Section 4). The -06 text is packet-oriented (Dispatcher "routes packets", Parser "dissects
  network packets"), leaving the naturalness of an object as input in doubt. One sentence makes
  the already-implied accommodation explicit.
- Classification: ARCHITECTURE GAP

```
  Stratum:  A background concept that identifies a portion of the
     network protocol stack targeted by SCHC, i.e., the contiguous
     layers within which SCHC processing can be applied.  The Stratum
     defines the scope of the protocol headers that the SCHC Rules in
     the associated Context can address.
+    The Stratum may extend up to and include the application layer;
+    in that case, the unit admitted to an Instance is an
+    application-layer data unit (e.g., an object), and the SCHC F/R
+    functionality can provide segmented, delay-tolerant transport of
+    that unit.  The protocol mechanisms remain those of [RFC8724] and
+    its extensions; this document does not define new mechanisms for
+    this purpose.
```

Edit 2 — Intermediary Endpoints (proxy/relay deployments)
- Architecture section: Section 4.2.3 (Session), appended paragraph
- Architecture concept: Session; Endpoint placement on intermediate nodes
- Reason: the draft's SCHC Proxy maintains SCHC state on the path between the Device and the
  network-side SCHC Gateway and issues local acknowledgments that, in the draft's own words,
  "split the SCHC connection".  -06 permits this shape (multiple Instances per Endpoint,
  multiple Sessions per Domain, arbitrary topologies) but never states it; every -06 figure is
  end-to-end.  A short paragraph states the already-implied relationship.
- Classification: ARCHITECTURE GAP

```
  (append at the end of Section 4.2.3)

+ An Endpoint may also be deployed on an intermediate node located
+ between two other Endpoints.  In that case, its Instance or
+ Instances participate in distinct Sessions toward each side, and
+ these Sessions may share the same Context, i.e., belong to the same
+ Domain.  A profile may define proxy behavior on this basis, for
+ example an intermediate Instance that acknowledges Datagrams locally
+ on one Session and assumes responsibility for their delivery on the
+ other Session.  This document does not define such proxy procedures.
```

## Effect on the draft under study

- With Edit 1, the draft's **object transport** concept (Section 4: SCHC as a transport protocol
  for whole objects; tiles fitted to the radio transport block) becomes a natural
  **Profile-specific** use of -06: an Instance whose Stratum is the application layer, F/R
  providing the segmented delay-tolerant transport. Without the edit it is only **Partial**
  (implicitly accommodated by a packet-oriented text).
- With Edit 2, the draft's **SCHC Proxy** (Section 4.1 general architecture; Section 4.4.1 LEO
  satellite as SCHC Proxy, with local acknowledgments and local retransmissions) becomes a
  natural **Composite** mapping: an intermediate Endpoint hosting Instance(s) that participate in
  two Sessions sharing one Context, with the local-acknowledgment behavior defined at profile
  level (e.g., draft-munoz-schc-over-dts-iot). The draft's **local acknowledgment /
  responsibility transfer** concept likewise becomes a plainly-placed Composite (an ordinary SCHC
  ACK within the Device↔Proxy Session, plus profile-defined behavior).
