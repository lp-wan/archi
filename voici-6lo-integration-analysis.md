# VOICI Integration Analysis — Architecture and 6Lo Deployment Mapping

**Date**: 2026-06-30  
**Author**: Quentin Lampin  
**Scope**: Mapping revised-schc-architecture terminology to draft-ietf-6lo-schc-15dot4, assessing VOICI as the transport/Dispatcher mechanism, identifying gaps.

---

## 1. Context

The revised SCHC architecture document reconciles terminology across WG draft -05 and the minimal architecture approach. Key reconciliations:

- **Instance** = local processing component (aligned with RFC 8824/9363/9441)
- **Session** = relationship between Instances sharing a Context
- **Discriminator** = data/criterion, **Dispatcher** = functional entity that uses it
- **Instance Configuration** = device-specific parameters (replaces Profile)

VOICI (draft-lampin-voici) is an individual draft defining a minimal Link Multiplexer that provides Session multiplexing, optional integrity (CRC-16), Content Mechanism dispatch (CI field), and original framing recovery — with a 1-byte minimal header.

This document maps the 6Lo draft's concepts to revised architecture terminology and assesses whether VOICI can satisfy the 6Lo draft's multiplexing and Discriminator requirements.

---

## 2. Terminology Mapping: 6Lo Draft → Revised Architecture

| 6Lo Draft Concept | Revised Architecture Equivalent | Notes |
|---|---|---|
| 6LN / 6LR / 6LBR (physical host) | **Endpoint** | Each network node is an Endpoint |
| SCHC Data end point (a SoR for packet C/D) | **Instance** | Each Data end point = one Instance with its own Context |
| SCHC Control Header end point | **Instance Configuration** (Dispatcher rules) | The revised arch treats the Control Header as optional transport metadata, not as a nested SCHC operation |
| Single-end point network (1 SCHC Data end point per node) | **Single Instance per Endpoint, single Domain, Discriminator = 0 bits** | Discriminator is implicit from L2 context |
| Multiple-end point network (>1 SCHC Data end point per node) | **Multiple Instances per Endpoint, Discriminator > 0 bits** | Discriminator carries Instance ID on-wire |
| SoR per SCHC Data end point | **Context of an Instance** | Each Instance's Context = SoR + metadata |
| (RuleID, End Point ID) pair | **(RuleID, Instance) / (RuleID, Discriminator)** | End Point ID = Discriminator value the Dispatcher uses |
| SCHC Instance ID (uncompressed Control Header field) | **Discriminator (explicit)** | The Instance ID on-wire = explicit Discriminator |
| "Rules stored by node X" | **Instances on Endpoint X have Contexts containing those Rules** | |
| SCHC-Lo network | **Domain** (or set of Endpoints in mesh/star) | Domain = management grouping; network = topology |
| SCHC Dispatch Type (6LoWPAN dispatch byte) | **Discriminator (L2 extrinsic)** | The Dispatch byte is the L2 Discriminator that triggers the Dispatcher |
| Single-hop communication | **Single-link deployment, one Stratum** | Standard Session between two Endpoints |
| SRO (all 6LRs store all Rules) | **Every intermediate Endpoint runs Instances with full Context replication** | Intermediate 6LRs are active Endpoints |
| TRO (6LRs store no Rules, tunnel) | **Intermediate Endpoints are pass-through (no active Instances)** | 6LRs forward encapsulated packets |
| PRO (6LRs use pointers, no Rules) | **Intermediate Endpoints have no active Instances; routing via frame metadata** | 6LRs navigate compressed headers via pointers |
| Mesh-Under (forwarders store no Rules) | **Same as PRO: intermediate Endpoints are transparent** | Mesh Header originator = Discriminator |
| RuleID reuse across node pairs (PRO, Mesh-Under) | **Contexts at different Endpoints may share RuleIDs without conflict** | RuleID space is per-Instance |

---

## 3. The Critical Divergence: Nested SCHC vs. VOICI

### 3.1 Current 6Lo Draft Approach

The 6Lo draft models the SCHC Control Header as a separately compressed field
using a "SCHC Control Header end point" with its own SoR.  The Control Header
carries a RuleID + compression residue that identifies the SCHC Data end
point.  This approach introduces conceptual complexity — a meta-level SCHC
operation that selects the primary Instance — and couples transport routing to
compression.

### 3.2 Revised Architecture + VOICI Approach

The revised architecture treats the Discriminator as **opaque routing data**, not as a nested SCHC operation:

- The **Discriminator** is a value (Session ID, L2 field, etc.)
- The **Dispatcher** is the functional entity that uses the Discriminator to route to the correct Instance
- **VOICI** provides the concrete transport header: Session ID = Discriminator, VOICI dispatcher = Dispatcher

For 7 or fewer Instances, both approaches are ≤1 byte on the wire. Beyond 7, VOICI's LEB128 extension is simpler than a second level of SCHC Rules.

### 3.3 Advantages of VOICI over Nested SCHC Control Header

1. **Simpler model**: No meta-Instance, no second-level compression rules
2. **Aligned with revised architecture**: Discriminator = data, Dispatcher = functional entity
3. **More flexible**: CI field allows mixing SCHC and non-SCHC traffic on the same link
4. **Integrity built-in**: Optional CRC covers Session ID + payload (the 6Lo draft has no integrity)
5. **Framing recovery**: O flag preserves original EtherType/port (useful when SCHC Ethertype replaces it)
6. **Extensible**: CI registry allows future content mechanisms

---

## 4. What's Missing — Integration Gaps

### 4.1 Gap 1: VOICI Profile for 802.15.4 / 6LoWPAN

VOICI is designed to operate over a carrier (Ethertype, IP Protocol Number, or UDP port). Over IEEE 802.15.4, the carrier would be the 6LoWPAN dispatch byte space.

**What's needed**: A VOICI Profile that specifies:
- VOICI carried over the SCHC Dispatch byte (Page 0, `01000100`) or SCHC Pointer Dispatch byte (`01000101`)
- Session ID → Instance mapping rules
- CI=1 for SCHC content
- When VOICI is needed (Multiple-end point) vs. absent (Single-end point)

This profile does not exist yet. The 6Lo draft currently uses its own SCHC Control Header format.

### 4.2 Gap 2: Multihop Interaction

The four 6Lo multihop modes interact differently with a VOICI header:

| Mode | 6LRs process VOICI? | Notes |
|---|---|---|
| **SRO** | Yes — each 6LR is an active Endpoint | VOICI Session ID needs processing or stripping at each hop |
| **TRO** | No — inside tunnel | VOICI header is encapsulated; 6LRs forward without seeing it |
| **PRO** | Possibly — VOICI sits outside compressed data | 6LRs would see VOICI header; needs specification of whether they strip/process or forward |
| **Mesh-Under** | No — Mesh Header handles routing | VOICI inside Mesh frame; Mesh originator = Discriminator for final hop |

**What's needed**: Specification per mode of VOICI header handling at intermediate nodes.

### 4.3 Gap 3: PRO Pointer

The PRO mode requires the SCHC Pointer header (bit-offset to Hop Limit and destination address residue). This is **not** a multiplexing concern — it's PRO-specific navigation metadata. VOICI doesn't and shouldn't address this. PRO's Pointer header would coexist with VOICI if Multiple-end point is also needed.

**No action required** — PRO Pointer and VOICI serve different functions and can be layered.

### 4.4 Gap 4: Protocol Numbers Dependence

VOICI as specified uses the SCHC Ethertype, IP Protocol Number, or UDP port from draft-ietf-schc-protocol-numbers. That draft is **expired** (v06, 2026-06-26) with unresponsive authors and 4 blocking issues.

Over 802.15.4, the 6LoWPAN SCHC Dispatch byte (`01000100`) provides an alternative carrier that doesn't depend on protocol numbers. **The VOICI Profile for 802.15.4 can use the 6LoWPAN dispatch byte as carrier**, avoiding the protocol-numbers dependency.

---

## 5. Recommended Path Forward

### 5.1 For the Architecture Document (Deployment Section)

The 6Lo Deployment section should:

1. Map 6LN/6LR/6LBR to Endpoints, with protocol stack diagram
2. Present TWO integration paths:
   - **Path A (Current)**: 6Lo draft's native approach with SCHC Dispatch + compressed Control Header (nested SCHC). Works now, compatible with existing 6LoWPAN infrastructure.
   - **Path B (VOICI-based)**: VOICI header replaces SCHC Control Header. Simpler, aligns with revised architecture, provides integrity + Content Mechanism dispatch. Requires VOICI Profile for 802.15.4.
3. Show rule distribution diagrams for Single-end point (SRO vs TRO vs PRO) and Multiple-end point
4. Map SRO/TRO/PRO/Mesh-Under to architecture concepts (active vs pass-through Endpoints)

### 5.2 For WG Adoption

1. **Engage 6Lo authors** (Carles Gomez, Ana Minaburo) to discuss VOICI as replacement for nested SCHC Control Header
2. If agreed, define a **VOICI Profile for 802.15.4** (could be an appendix in either the VOICI draft or the 6Lo draft)
3. Propose WG adoption of VOICI for:
   - Multiplexing (Session ID → Instance)
   - Integrity (optional CRC)
   - Content mechanism identification (CI field)
4. Architecture document illustrates both approaches; 6Lo draft may adopt VOICI as the recommended path for Multiple-end point deployments

---

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| 6Lo authors resist VOICI (prefers native 6LoWPAN dispatch) | Medium | Medium | Keep both paths in architecture; 6Lo draft unchanged |
| Protocol numbers delay blocks VOICI carrier | Medium | Low | Use 6LoWPAN dispatch byte as carrier over 802.15.4 |
| VOICI seen as scope creep for architecture | Low | Medium | Present as concrete instantiation of existing "Control Header for Advanced Use Cases" section |
| Nested SCHC model entrenched in 6Lo draft v12 | Medium | Medium | WG chairs can mediate; highlight complexity reduction |
