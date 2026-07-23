# SCHC Architecture -06 edits needed for draft-lampin-voici-02

## Purpose
This document proposes minor additive clarifications to `draft-ietf-schc-architecture-06` to naturally express the link-local remapping of Session IDs and multi-mechanism multiplexing (routing to non-SCHC handlers) introduced by the VOICI draft (`draft-lampin-voici-02`).

## Proposed edits
Edit 1 —
- Architecture section: Section 4.2.2.4 (Multiple Instances)
- Architecture concept: Session ID / Discriminator Scope
- Reason: Clarify that wire Session IDs can be link-local representations (acting as Discriminators) that may be remapped by relays at segment boundaries, maintaining Domain-unique Sessions logically.
- Classification: ARCHITECTURE GAP

```diff
     Dispatcher may need an explicit Discriminator.  For example,
     Datagrams can be encapsulated in a light transport protocol whose
     header contains a Session, Context, or Instance identifier, and can
     provide additional services such as integrity checking (CRC).
+
+    While logical Session Identifiers are unique within their Domain, the
+    wire representation of a Session ID (e.g., in a Control Header) may
+    be local to a specific link segment. In such deployments, the wire
+    Session ID acts as a link-local Discriminator component that is
+    mapped by the Dispatcher (possibly in combination with lower-layer
+    context) to the Domain-unique Session or Instance. Intermediaries
+    such as gateways or relays may remap these link-local identifiers
+    at segment boundaries.
```

Edit 2 —
- Architecture section: Section 4.2.2.4 (Multiple Instances)
- Architecture concept: Dispatcher routing scope
- Reason: Clarify that the Dispatcher can route to either SCHC Instances or non-SCHC/raw handlers in mixed-traffic environments.
- Classification: ARCHITECTURE GAP

```diff
     provide additional services such as integrity checking (CRC).
+
+    The Dispatcher may also be responsible for demultiplexing traffic
+    when a link carries a mix of SCHC-compressed datagrams and other
+    traffic (e.g., uncompressed packets or packets compressed via
+    other mechanisms). In such cases, the Dispatcher uses the
+    Discriminator (such as a Content Identifier in a Control Header) to
+    route the datagram either to a SCHC Instance or to the appropriate
+    non-SCHC handling path.
```

## Effect on the draft under study
Applying these edits has the following effects on `draft-lampin-voici-02` mappings:
- The mapping of the **VOICI Session ID** to the SCHC **Discriminator** component becomes fully natural and Direct, as the link-local scoping and relay-based remapping are explicitly recognized by the architecture.
- The mapping of the **VOICI dispatcher** to the SCHC **Dispatcher** becomes Direct, as the architecture now explicitly covers the routing of mixed traffic containing non-SCHC payloads to their respective handlers.
