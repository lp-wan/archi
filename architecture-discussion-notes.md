# Architecture Discussion Notes

**Date initiated**: 2026-06-30  
**Branch**: schc-revised-architecture-with-voici

---

## Discriminator Location Relative to Stratum Boundary

### Question

Can the Discriminator be located **below** the Stratum's lower boundary, rather than exactly at it?

### Current State

The Stratum definition says it is bounded below by the carrier layer (where the Discriminator is anchored). This implies the Discriminator and the lower boundary are coincident.

### Proposal

Decouple Discriminator location from Stratum boundaries:

- **Stratum** defines which headers the associated Context's Rules can address
- **Discriminator** is the routing value the Dispatcher uses to select the Instance
- These are independent: the Discriminator may be derived from below, at, or above the Stratum's lower boundary

### Categories of Discriminator Location

| Location relative to Stratum | Discriminator source | Example |
|---|---|---|
| **Below** lower boundary (carrier layer) | L2 MAC address (source DevEUI) | LPWAN gateway maps DevEUI → Instance before seeing Stratum |
| **Below** lower boundary (carrier, adjacent) | Physical radio/channel ID | Multi-radio device: antenna port selects Instance before link layer |
| **Below** lower boundary (carrier, adjacent) | Carrier type (Ethertype, dispatch byte) | 6LoWPAN SCHC Dispatch `01000100` triggers Dispatcher |
| **Below** lower boundary (carrier, adjacent) | Multiplexing header (VOICI Session ID) | Explicit Session ID selects Instance above carrier, below Stratum |
| **Within** Stratum | IP Next Header or UDP port (preserved by Rule) | Discriminator extracted from a field the Rules don't elide |

### Implications

- **Below**: The Dispatcher operates before the Stratum is entered. The Instance is already selected when the packet enters the Stratum. Simplifies Stratum processing — no Discriminator to decompress or parse. Risk: tight coupling between physical/MAC addressing and Instance topology.
- **At**: Current model. The Discriminator arrives with the packet at the carrier layer. Flexible but adds per-packet processing.
- **Above**: Discriminator is extracted from within the Stratum's addressable headers. Requires the Dispatcher to inspect headers that SCHC may have compressed. May be infeasible if the Discriminator field is elided by compression.

### Open Questions

1. Should the architecture constrain Discriminator location, or leave it to the deployment/profile?
2. If Discriminator is "below", does the Stratum still need a lower boundary, or is the lower boundary defined strictly by what the Rules can address?
3. For LPWAN, the DevEUI-as-Discriminator case is real and common. Is it currently represented?
4. If Discriminator is "above" (from upper-layer headers), how does the Dispatcher inspect compressed fields? Does this require special Rule design (preserving Discriminator fields)?
5. Does the Stratum definition benefit from an explicit note that the Discriminator location is determined by the Instance Configuration, not by the Stratum itself?

### References

- Minimal architecture draft, Section 3 (Dispatcher/Discriminator) — describes Discriminator as "optional information element" without location constraint
- Revised architecture, Terminology section — current Stratum definition anchors Discriminator at lower boundary
- 6Lo draft, Section 3.2.1 — "the Discriminator is a 6LoWPAN Dispatch Type" (location-locked to L2)

**Status**: Open — no consensus yet. Deferred until deployment section review.

---

## Stratum Refinement: Inclusive Lower and Upper Boundaries

### Proposal (revised)

A Stratum is a **contiguous range `[lower, upper]` of addressable layers**, where **both boundaries are inclusive**.

- **Lower boundary** — the first layer whose headers the Rules can address
- **Upper boundary** — the last layer whose headers the Rules can address
- If `lower == upper`, the Stratum spans a single layer
- Traffic **above** the upper boundary is unaffected
- The layer **adjacent to and below** the lower boundary is the carrier layer, which bears the Discriminator. It is outside the Stratum and not addressable by Rules.

### Consequence: Discriminator Outside Stratum

The Discriminator and the Dispatcher operate **outside** the Stratum. The Discriminator selects the Instance; once selected, the Instance's Context has a Stratum that defines what its Rules can address. These concerns are separate:

```
  +-------------------------------------+
  | Upper boundary: CoAP / UDP          |  <- last addressable layer (highest)
  |         ...                          |
  | Lower boundary: IPv6                |  <- first addressable layer (lowest)
  +-------------------------------------+
      |
      | Stratum [lower, upper] — inclusive bounds
      v
  Carrier layer (802.15.4, LPWAN, PPP, ...) — outside the Stratum
  (carries the Discriminator, not addressable by Rules)
```

### Discriminator Location Remains Independent

With this model, the "carrier layer" is defined as the layer/context **immediately adjacent and below the Stratum's lower boundary**. The Discriminator is derived from this carrier layer. The carrier is not necessarily L2 — it is whatever delivers the packet to this particular Stratum's processing stage.

| Stratum | Lower boundary | Carrier (adjacent below) | Discriminator source |
|---|---|---|---|
| L2.5 (IPv6/UDP) | IPv6 | 802.15.4 | L2 dispatch byte / DevEUI / etc. |
| CoAP outer (OSCORE case) | CoAP outer | OSCORE (pre-outer decrypt) | OSCORE outer session ID |
| CoAP inner (OSCORE case) | CoAP inner | OSCORE (post-inner decrypt) | OSCORE inner session ID |
| CoAP (no OSCORE) | CoAP | UDP | UDP port number |

The two CoAP Strata in the OSCORE case share the same carrier type (OSCORE) but operate at different processing stages: the outer Instance's Discriminator is derived from the OSCORE outer context, the inner Instance's Discriminator from the OSCORE inner context. "Below" in the stack means "predecessor" in processing time.

### Can the Discriminator Be Within the Stratum?

In principle, a field preserved by the Rules (e.g., UDP port) could carry the Discriminator. However:
- The field must survive compression (explicitly preserved by Rule design)
- The Dispatcher must inspect the compressed header before full C/D
- This is feasible but uncommon — the carrier-layer Discriminator model is simpler

The key constraint: the Discriminator must be inspectable by the Dispatcher **before** the Stratum's full C/D begins. Otherwise the Dispatcher cannot select the Instance, and without the Instance there is no Context, and without the Context decompression is impossible.

The key insight: Stratum scope and Discriminator location are decoupled. The Stratum answers "which headers can these Rules address"; the Discriminator answers "which Instance handles this Datagram".

### OSCORE Does Not Break the Model

The OSCORE case confirms the model: both CoAP Strata have Discriminators in the carrier layer adjacent to the lower boundary. The two Strata share a carrier type but are distinguished by the OSCORE processing stage. No revision to the "Discriminator adjacent below Stratum" model is needed.

### Open Questions

1. Should the Stratum definition in the terminology section adopt this inclusive-bounds framing?
2. Is it sufficient to say "carrier layer" or should we explicitly note that carrier can be a protocol processing stage (as with OSCORE, not just an L2 technology)?
3. For PRO Pointer in 6Lo: the Pointer navigates compressed fields *within* the Stratum to find Hop Limit and destination address. This confirms the Discriminator (routing decision) and the Stratum (what Rules address) are separate concerns.

**Status**: Discussed, concept agreed between authors. OSCORE confirmed as compatible. Pending terminology document update.

---

## OSCORE + SCHC: Concrete Processing Walkthrough

### Scenario

Sensor (6LN) sends a CoAP POST to a Server (via 6LBR), secured with OSCORE,
compressed by SCHC at three Strata. All three Instances reside on both the 6LN
and the 6LBR.

**Setup**:
- IP: sensor `fd00:1::1` → server `fd00:1::2`
- UDP: port 5683 → 5683 (original)
- **Carried over SCHC UDP port** (the carrier port from protocol-numbers)
- OSCORE: sender ID `0x01`, recipient ID `0x02`, partial IV context known
- CoAP inner: `POST /temp` {reading: 42}
- CoAP outer: Uri-Path `"sensors/temp"`, Token containing partial IV

**Instances on the 6LN/6LBR**:

| Instance | Stratum [lower, upper] | Carrier below | Discriminator source |
|---|---|---|---|
| I1 (L2.5) | [IPv6, UDP] | 802.15.4 | 6LoWPAN Dispatch byte (`01000100`) — **explicit** |
| I2 (CoAP outer) | [CoAP outer] | SCHC UDP port (carrier) | VOICI CI=1 + Session ID — **explicit** |
| I3 (CoAP inner) | [CoAP inner] | CoAP/OSCORE pipeline | CoAP processing stage post-inner-decrypt — **intrinsic** |

### Sender-side Processing (high → low)

```
Step 1: Application produces CoAP inner
     CoAP inner header: Code=POST, Uri-Path="temp"
     Payload: {reading: 42}

Step 2: Instance I3 (inner) compresses CoAP inner
     Stratum: [CoAP inner] — single layer
     I3's Rules compress CoAP inner header → residue [0xAB 0xCD]
     Result: [0xAB 0xCD] {reading: 42}

Step 3: OSCORE encrypts the compressed inner + payload
     Protected payload = {0xAB 0xCD | {reading: 42}}
     OSCORE encrypts → ciphertext [0x..CTEXT..]
     Partial IV extracted, embedded in Token

Step 4: CoAP outer header assembled
     CoAP outer: Code=POST, Token=<..partial IV..>, Uri-Path="sensors/temp"
     Payload: [0x..CTEXT..]

Step 5: Instance I2 (outer) compresses CoAP outer header
     Stratum: [CoAP outer] — single layer
     I2's Rules compress CoAP outer header → residue [0xEF]
     Note: Token field must be preserved (Rule design) so partial IV is extractable on receiver
     Result: [0xEF] [0x..CTEXT..]

Step 6: Voiced CoAP payload encapsulated with VOICI
     VOICI header: V=0, O=1, I=0, CI=1 (SCHC), SSS=Session ID for I2
     VOICI O flag restores original UDP port = 5683 after full decompression
     Result: [VOICI byte] [0xEF] [0x..CTEXT..]

Step 7: IPv6 + UDP headers constructed
     IPv6: src=fd00:1::1, dst=fd00:1::2, NH=UDP(17)
     UDP: src=port_schc, dst=port_schc, length=..
     (UDP dst port is the SCHC carrier port, NOT 5683)
     Payload: [VOICI byte] [0xEF] [0x..CTEXT..]
     Payload is untouched by I1 — outside its Stratum.

Step 7: Instance I1 (L2.5) compresses IPv6 + UDP
     Stratum: [IPv6, UDP]
     I1's Rules compress IPv6 + UDP headers → residue [0x12 0x34]
     Result: [0x12 0x34] [0xEF] [0x..CTEXT..]
     Payload untouched.

Step 8: On wire
     802.15.4 frame: [SCHC Dispatch 01000100] [0x12 0x34 EF ..CTEXT..]
     (padding, etc.)
```

### Receiver-side Processing (low → high)

```
Step 1: 802.15.4 frame received
     Carrier: 802.15.4
     Frame: [dispatch byte 01000100] [0x12 0x34 EF ..CTEXT..]

Step 2: Discriminator extraction — L2 carrier
     Discriminator value: 6LoWPAN Dispatch byte = 01000100
     Source: carrier layer (802.15.4), adjacent below Stratum lower boundary
     Dispatcher routes → Instance I1 (L2.5)

Step 3: Instance I1 decompresses
     I1's Context has Stratum [IPv6, UDP]
     I1 decompresses [0x12 0x34] → IPv6 header + UDP header
     IPv6: src=fd00:1::1, dst=fd00:1::2, NH=UDP(17)
     UDP: src=5683, dst=5683
     Payload passed through untouched: [0xEF] [0x..CTEXT..]

Step 4: UDP demultiplexing
     UDP dest port = SCHC carrier port → routes to **SCHC/VOICI handler**
     (NOT 5683, NOT CoAP)
     VOICI handler receives payload: [VOICI byte] [0xEF] [0x..CTEXT..]

Step 5: VOICI header processed
     VOICI: V=0, O=1, I=0, CI=1 (SCHC), SSS=Session ID for I2
     Discriminator value: VOICI Session ID
     Source: VOICI header in the carrier delivery (above carrier port, below I2's Stratum)
     Dispatcher routes → Instance I2 (CoAP outer)

Step 6: Instance I2 decompresses
     I2's Context has Stratum [CoAP outer] — single layer
     I2 decompresses [0xEF] → CoAP outer header
     CoAP outer: Code=POST, Token=<..partial IV..>, Uri-Path="sensors/temp"
     Payload (ciphertext) passed through untouched
     VOICI O flag noted: original UDP port 5683 will be restored later

Step 7: OSCORE processing
     Partial IV extracted from Token
     Lookup OSCORE security context (sender ID 0x01, etc.)
     Decrypt ciphertext [0x..CTEXT..]
     Output: [0xAB 0xCD] {reading: 42}

Step 8: DISCUSSION POINT — how does I3 get selected?
     See "I3 Discriminator Discussion" below.

Step 9: Instance I3 decompresses
     I3's Context has Stratum [CoAP inner] — single layer
     I3 decompresses [0xAB 0xCD] → CoAP inner header
     CoAP inner: Code=POST, Uri-Path="temp"
     Payload: {reading: 42}

Step 10: VOICI final restoration
     VOICI O flag: restore original UDP port 5683
     CoAP handler on port 5683 receives reconstituted CoAP message

Step 11: Application receives
     CoAP POST to /temp, payload {reading: 42}
```

### Key Observations

1. **Each Instance has a Discriminator in its carrier layer**, adjacent below the Stratum's lower boundary. No Instance's Discriminator is within its own Stratum.

2. **The carrier layer is not always "L2"**: I2's carrier is the UDP payload delivery stage; I3's carrier is the OSCORE decryption output stage. "Below" means "predecessor in processing time," not "lower in the protocol stack diagram."

3. **Instance selection is sequential and chained**: I1 runs first, its output feeds into CoAP processing, which selects I2, whose output feeds OSCORE, whose output selects I3. At no point is there ambiguity.

4. **Rule design constraints**: I2's Rules must preserve the Token field (containing the partial IV), because the Token is needed by OSCORE — which is downstream but whose output is the carrier for I3. Similarly, I1's Rules must preserve the IPv6 Next Header and UDP header so that UDP demux works. These are Rule-level constraints, not Discriminator-level.

5. **Stratum boundaries are independent of Discriminator location**: The Stratum definition ([lower, upper]) tells you which headers a Rule can touch. The Discriminator tells you which Instance handles this packet. They are separate concerns, confirmed by the three-Stratum OSCORE case.

---

## I3 Discriminator: CoAP Processing Pipeline as Carrier

### The Problem with I3

After OSCORE decrypts the Inner Plaintext, the receiver has:
- `[Inner SCHC residue] + [Application payload]`

The Inner SCHC residue needs Instance I3 to decompress it into the CoAP inner header. But what selects I3?

### RFC 8824 Specifies the Pipeline

RFC 8824 Section 7.2 states:

> *"The OSCORE message translates into a segmented process where SCHC compression is applied independently in two stages, each with its corresponding set of Rules, with the Inner SCHC Rules and the Outer SCHC Rules."*

> *"Note that since the corresponding endpoint can only decrypt the Inner part of the message, this endpoint will also have to implement Inner SCHC Compression/Decompression."*

This means Inner/Outer SCHC Instances are **part of the CoAP processing pipeline**, not separate network-layer entities. The CoAP stack orchestrates the processing order:

```
CoAP receives OSCORE message
  → Outer SCHC Instance (I2) decompresses CoAP outer
  → OSCORE option provides partial IV, security context
  → OSCORE decrypts → ciphertext → Inner Plaintext
  → Inner Plaintext = [Inner SCHC residue] + payload
  → **CoAP stack invokes Inner SCHC Instance (I3)**
  → I3 decompresses Inner SCHC residue → CoAP inner header
  → Application receives fully reconstituted CoAP message
```

### I3's Discriminator is Intrinsic

I3's Discriminator is **not an explicit field** in the Datagram. It is the **intrinsic processing state** of the CoAP stack: "I have just decrypted the Inner Plaintext and need to decompress the compressed inner header."

This is fundamentally different from I1 and I2:

| Instance | Discriminator type | Source | Explicit or Intrinsic? |
|---|---|---|---|
| I1 | L2 Dispatch byte | Frame field | **Explicit** |
| I2 | VOICI Session ID | VOICI header field | **Explicit** |
| I3 | CoAP pipeline state | Processing stage context | **Intrinsic** |

### Implications for the Architecture

1. **Discriminators can be intrinsic**: The architecture must acknowledge that Discriminators are not always explicit on-wire fields. They can be implicit variables exposed by the processing pipeline (here, the CoAP/OSCORE stack).

2. **CoAP is the authority**: OSCORE and SCHC compression/decompression order for inner/outer headers is specified within the CoAP processing pipeline, not the network stack. SCHC Instances I2 and I3 are invoked by the CoAP implementation, not by a generic network-layer Dispatcher.

3. **The Discriminator chain extends beyond the network**: The Discriminator DAG includes application-layer processing stages. I3's entry point is a CoAP internal state, not a network carrier layer.

4. **This is a cross-layer concern**: From the network perspective (I1, I2), Discriminators are explicit. From the application perspective (I3), the Discriminator is intrinsic. The architecture should define Discriminators as "explicit or intrinsic values or contexts that enable the Dispatcher to select the correct Instance."

### Distinction: SCHC as Application Utility vs. Network Stack Component

This points to a fundamental distinction that should be explicit in the architecture. There are two fundamentally different ways an Instance is invoked:

**Case A: SCHC integrated into the network stack**

The Instance is invoked by a **Dispatcher** using a **Discriminator** derived from the network carrier layer. The Instance participates in routing decisions. Domains, Instance Configurations, and Discriminators all apply.

Examples: I1 (L2.5 Stratum), I2 when invoked via VOICI Session ID.

**Case B: SCHC as an application compression utility**

The Instance is invoked directly by the application's processing pipeline. No Dispatcher, no Discriminator, no Domain involvement. The Instance is called as a library function by the application, in an order dictated by the application's own processing logic.

Examples: I2 and I3 in the OSCORE case, invoked by the CoAP/OSCORE stack.

### Instance Invocation Context

A new concept is needed: **Instance Invocation Context** — the mechanism by which an Instance receives the Datagram it must process. The Invocation Context determines whether Instance-level routing machinery (Discriminator, Dispatcher, Domain) applies:

**For Case A (network stack):**

The Invocation Context is the Dispatcher/Discriminator chain. The carrier layer produces a Discriminator; the Dispatcher uses it to select the Instance. The Instance's Context is then applied to process the Datagram.

**For Case B (application utility):**

The Invocation Context is the application's processing stage. The CoAP/OSCORE pipeline decides "now decompress inner header" and invokes the Instance directly. No Discriminator is needed.

### Architectural Consequences

| Property | Case A (network) | Case B (application) |
|---|---|---|
| Invocation | Dispatcher → Discriminator | Application pipeline call |
| Discriminator | Required (explicit or implicit) | Not needed |
| Domain | Applicable | Not applicable |
| Instance Configuration | Applicable (device policy) | Not applicable (application config) |
| Stratum | Defined (protocol scope) | Defined (application scope) |
| Context | Provisioned | Provisioned by application |
| Rules | Managed by Domain | Managed by application |
| Session | Between network Instances | Between application Instances |

### The OSCORE Example Revisited

In the I1 + I2 + I3 example:
- **I1** is Case A: network Instance, invoked by Dispatcher/L2 Dispatch byte
- **I2** is Case B: application Instance, invoked by CoAP outer processing stage
- **I3** is Case B: application Instance, invoked by CoAP inner processing stage

I1's invocation is governed by network-layer Discriminators and Domains. I2 and I3's invocation is governed by the CoAP/OSCORE processing pipeline. The same architectural concepts (Instance, Context, Rule) apply, but the routing/configuration mechanisms differ.

### Open Questions

1. Should the architecture explicitly distinguish these two invocation modes?
2. Can SCHC Instances straddle both worlds? (e.g., an Instance that's network-configured but application-invoked?)
3. Does the Stratum concept change between the two cases? For Case B, the Stratum is a single application-layer header — not a multi-layer range. Does this matter?
4. Should the architecture define a separate subclass (e.g., "Application Instance") or note both cases under the Instance definition?

**Status**: Requires architecture terminology section update. The Instance Invocation Context concept is the bridge between the two cases.
