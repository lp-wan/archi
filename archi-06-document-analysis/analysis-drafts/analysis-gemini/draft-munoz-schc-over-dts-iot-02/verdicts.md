# Architectural alignment review: draft-munoz-schc-over-dts-iot-02

## Verdicts
- Conceptual equivalence: High
- Transition difficulty: Easy
- SCHC Architecture adaptation need: None

## Grade calibration
| Dimension | Verdict | Why not one grade higher? | Why not one grade lower? |
|---|---|---|---|
| Conceptual equivalence | High | The terminology collision on the word 'session' and the introduction of internal F/R sub-processes (Assembler/Transporter) and dynamic in-band parameters (Parameter S) require explicit architectural framing and interpretation to map them to the -06 model. | The core technical behavior (FEC encoding, tiling, transmission, retransmissions, and Compound ACKs) is fully expressible within the -06 F/R framework and does not require reframing or profile-specific semantics that stretch the architecture. |
| Transition difficulty | Easy | It requires more than a simple search-and-replace; it requires careful rewording in sections describing the 'fragmentation session' and 'sub-processes' to align with the -06 component model. | The underlying protocol logic, message formats, state machines, and mathematical equations remain exactly the same. No complex restructuring of sections is required. |
| SCHC Architecture adaptation need | None | Highest grade | There are no structural or definition gaps in -06 that prevent the ARQ-FEC mode from being expressed. All required concepts (Instance, Session, Context, SoV, F/R function) are already sufficiently defined. |

## Executive assessment
The reference architecture (`draft-ietf-schc-architecture-06`) can naturally express the technical behavior and concepts of the draft under study (`draft-munoz-schc-over-dts-iot-02`). The principal conceptual mapping involves representing the ARQ-FEC fragmentation and defragmentation sub-processes (Assembler and Transporter) as internal components of the Fragmentation/Reassembly (F/R) function within a SCHC Instance. The principal migration difficulty lies in the overloaded term "session" — the draft uses "fragmentation session" to refer to the reassembly of a single packet, whereas -06 defines a "Session" as a persistent communication relationship between Instances. To resolve this, the draft's "fragmentation session" should be rebranded as a "fragmentation transaction" or "reassembly process" whose runtime state resides in the Instance's Set of Variables (SoV). No architecture gaps exist in `draft-ietf-schc-architecture-06` for this draft.

## Native conceptual model
| Native draft concept | Meaning in the draft | Owner / logical location | Scope | Identifier or selector | Cardinality and relationships | Notes |
|---|---|---|---|---|---|---|
| SCHC Packet | The packet received from or delivered to the compression sublayer. | Compression / Decompression sublayer | Session | None | 1 per fragmentation session | Size P bits. |
| Symbol | Basic data unit handled by the encoding/decoding process. | Encoding/decoding & Assembler processes | Coded structure | Index / position | k source symbols per source block; n encoded symbols per encoded block | Size m bits. Treated as indivisible. |
| Source Block | A subset of k source symbols representing a portion of the SCHC Packet. | Encoding/decoding process | Local to encoding | Block index | S source blocks per SCHC packet | |
| Encoded Block | A subset of n symbols resulting from FEC encoding of a source block. | Encoding/decoding & Assembler | Coded structure | Block index | 1 per source block | Requires >= k received symbols to decode. |
| Coded Data Structure (C-Matrix / C-Stream) | The structured arrangement of encoded blocks/symbols. | Encoding/decoding & Assembler | Fragmentation session | RuleID + DTag | 1 per SCHC Packet | Form depends on geometry (C-Matrix or C-Stream). |
| D-Matrix / D-Stream | The structured arrangement of source symbols prior to encoding. | Encoding/decoding | Local to encoding | None | 1 per SCHC Packet | Size S rows by k columns (matrix). |
| Residual coding bits | Bits leftover when dividing the SCHC Packet into source blocks. | Encoding & Assembler | Fragmentation session | None | 0 or 1 set per SCHC Packet | P mod (k * m) bits. Appended to the last tile. |
| Residual fragmentation bits | Bits leftover when dividing the Coded structure into regular tiles. | Assembler & Transporter | Fragmentation session | None | 0 or 1 set per SCHC Packet | Appended to the last tile. |
| Assembler sub-process | Sub-process responsible for mapping between coded structures and encoded SCHC packets. | F/R function (sender & receiver) | Fragmentation session | None | 1 per F/R process | Handles geometry, placement, and decodability checks. |
| Transporter sub-process | Sub-process responsible for splitting the encoded SCHC packet into tiles and transmitting them. | F/R function (sender & receiver) | Fragmentation session | RuleID + DTag | 1 per F/R process | Manages timers, attempts, and message flows. |
| Encoded SCHC packet | The continuous buffer of encoded symbols passed between sub-processes. | Assembler & Transporter | Fragmentation session | RuleID + DTag | 1:1 with Coded structure | Excludes residual coding bits. |
| Tile | The unit of fragment payload transmission. | Transporter | Link transmission | FCN + W | Many per window; multiple regular tiles per fragment | Regular tiles are same size; last tile carries residuals. |
| Parameter S | The number of rows in the C-matrix. | Encoding & Assembler | Fragmentation session | In first tile (FCN=WINDOW_SIZE-1, W=0) | 1 per matrix-based session | Dynamically calculated from packet size. |
| Correlative tile number (ctn) | A linear index calculated for a tile slot. | Assembler | Local calculation | None | 1:1 with tile position | Used to calculate row/column in matrix. |
| Fragmentation session | The lifecycle of transmitting and reassembling a single SCHC Packet. | Transporter & Assembler | Ephemeral (single packet) | RuleID + DTag | 1:1 with SCHC Packet | Concludes on success, abort, or timeout. |
| Attempts counter / S Attempts counter | Counters tracking All-1/ACK REQ or Parameter S transmissions. | Transporter (sender/receiver) | Per (RuleID, DTag) | None | 1 each per active reassembly context | Resets and increments during transmission. |
| Retransmission Timer / S Timer / Inactivity Timer | Timers managing retransmission timeouts and session inactivity. | Transporter (sender/receiver) | Per (RuleID, DTag) | None | 1 each per active reassembly context | Manages state transitions. |

## Native architectural model
The native architectural model of `draft-munoz-schc-over-dts-iot-02` defines the **ARQ-FEC fragmentation mode**, which introduces forward error correction (FEC) combined with selective retransmissions to enhance reliability in lossy networks.

At the sender side, the process begins when a **SCHC Packet** is received from the compression sublayer. The packet is processed by the **Encoding process**, which partitions it into **Source Blocks** consisting of $k$ **Source Symbols** (each $m$ bits wide). Any leftover bits are held as **Residual coding bits**. An FEC algorithm is applied to each block, producing an **Encoded Block** of $n$ symbols. These encoded blocks are arranged into a **Coded Data Structure** (either a 2D **C-Matrix** or a sequential **C-Stream** depending on the configured **Encoding Geometry**). 

The **Fragmentation process** is split into two sub-processes: the **Assembler sub-process** and the **Transporter sub-process**. The Assembler sub-process reads the symbols from the Coded Data Structure and serializes them into an **Encoded SCHC packet**. For C-Matrix, this is done column-by-column; for C-Stream, it is done sequentially, optionally applying an interleaving pattern to distribute block symbols across multiple windows. The Transporter sub-process divides this Encoded SCHC packet into **Regular Tiles** of equal size. The **Last Tile** is constructed by appending the Residual coding bits and **Residual fragmentation bits** (leftover from tiling) with padding. The Transporter sends these tiles over the L2 link in one or more **SCHC Fragment** messages. If the C-Matrix geometry is used, the first tile of the first window carries the dynamic **Parameter S** (number of rows), which the receiver needs to construct the matrix.

At the receiver side, the process is reversed. The receiver's Transporter sub-process starts a **Fragmentation session** upon receiving a fragment with a new **RuleID** (and optional **DTag**). It extracts the received tiles and passes them to the receiver's Assembler sub-process, which places them into the Coded Data Structure. For C-Matrix, the placement relies on converting the window ($W$) and fragment compressed number ($FCN$) of each tile into a linear **Correlative Tile Number (ctn)**, which is then mapped to a row and column. 

The Assembler sub-process continuously checks whether the Coded Data Structure has collected **enough symbols** to be decoded (at least $k$ symbols in each Encoded Block). If enough symbols are present, the Assembler notifies the Transporter sub-process, which sends a **SCHC Compound ACK** with the completion status ($C=1$) and forwards the structure to the **Decoding process**. The decoding process recovers the original source symbols, and reconstructs the SCHC Packet, appending the residual bits.

If the transmission reaches the end (an **All-1** fragment is received) and some blocks remain undecodable, the Assembler identifies the missing tiles and passes them to the Transporter. The Transporter sends a SCHC Compound ACK with $C=0$ and a bitmap of the missing tiles, requesting their selective retransmission. The sender then retransmits only the missing tiles. The session concludes successfully when the receiver decodes the packet, or fails if the **Attempts counter** exceeds $MAX\_ACK\_REQUESTS$, the **Inactivity Timer** expires, or a **Sender-Abort/Receiver-Abort** is received.

## Concept mapping
| Native draft concept | Meaning in the draft | SCHC -06 mapping | Match type | Scope alignment | Cardinality alignment | Semantic differences | Notes |
|---|---|---|---|---|---|---|---|
| SCHC Packet | Compressed/uncompressed packet. | `SCHC Packet` / `Datagram` | Direct | Yes | Yes | None. | |
| Symbol | Divisible m-bit FEC unit. | Profile-specific internal variable | Profile-specific | Yes | Yes | -06 doesn't specify F/R internal structures. | Fits as a profile-specific F/R parameter. |
| Source Block / Encoded Block | Subsets of k and n symbols. | Profile-specific internal state | Profile-specific | Yes | Yes | -06 doesn't specify F/R internal structures. | Part of the F/R function state. |
| Coded Data Structure | C-Matrix or C-Stream structure. | Profile-specific internal state | Profile-specific | Yes | Yes | -06 doesn't specify F/R internal structures. | Part of the F/R function state. |
| Assembler sub-process | Mapping between structure and tiles. | Part of `F/R` function | Profile-specific | Yes | Yes | -06 doesn't specify F/R sub-processes. | Internal processing step of the F/R function. |
| Transporter sub-process | Tiling and L2 transmission logic. | Part of `F/R` function | Profile-specific | Yes | Yes | -06 doesn't specify F/R sub-processes. | Internal processing step of the F/R function. |
| Tile | F/R transmission unit. | `Tile` | Direct | Yes | Yes | None. | Inherited from RFC 8724. |
| RuleID | Field selecting the rule. | `RuleID` | Direct | Yes | Yes | None. | Unique within the Context. |
| DTag | Demultiplexing field. | `DTag` (via Datagram) | Direct | Yes | Yes | None. | Inherited from RFC 8724. |
| Attempts / S Attempts / Timers | Counters and timers. | `Set of Variables (SoV)` | Direct | Yes | Yes | Scoped per reassembly transaction, not per long-lived Session. | SoV stores these variables keyed by (RuleID, DTag). |
| Fragmentation session | Single-packet reassembly lifecycle. | Reassembly context / transaction state | Misleading | No | No | "Session" in -06 is long-lived; this is ephemeral. | Must be mapped to an active transaction in the SoV. |
| Parameter S | C-matrix row count. | Profile-specific internal variable | Profile-specific | Yes | Yes | Carried in-band as dynamic state, not in Context. | Handled as dynamic state inside F/R. |

## Scope and cardinality comparison
| Relationship or identifier | Draft model | Architecture -06 model | Alignment | Consequence |
|---|---|---|---|---|
| ownership of Context | Owned by peer endpoints. Static. | Shared by Instances in a Domain. Managed by Domain Manager. | Aligned | The draft's static rules can be stored in the Context Repository and deployed to the Instances. |
| ownership of Set of Rules | Same as Context. | Owned by the Instance. | Aligned | Aligned. |
| ownership of Set of Variables | Owned by the transporter per active transaction. | Owned by the Instance per Session. | Partial | In -06, SoV is per-Session. The SoV must store variables in a structured list/map to support concurrent transactions (DTag). |
| Endpoint↔SCHC Instance | Peer-to-peer connection (1 Instance). | Endpoint can host multiple Instances. | Aligned | A single-instance Endpoint is a valid subset of the -06 architecture. |
| SCHC Instance↔Session | 1:1 communication relationship. | A Session is between two or more Instances. | Aligned | Aligned. |
| sharing of Context between Sessions/Instances | Multiple nodes share the same rules. | Multiple Sessions/Instances can share a Context. | Aligned | Aligned. |
| RuleID scope | Selects the ARQ-FEC rule. | Unique within the Context. | Aligned | Aligned. |
| Discriminator scope | Uses L2 address/metadata (DevEUI/fPort). | Used by Dispatcher to route to Instances. | Aligned | Aligned. |
| Control Header processing scope | Not applicable. | Optional header before/after RuleID. | Not applicable | The draft does not define a Control Header. |
| Domain membership and boundaries | Implicit. | Instances sharing Contexts in a Domain. | Aligned | Aligned. |

## Challenged mappings
| Concept | Initial mapping | Challenge | Final mapping | Reason for change |
|---|---|---|---|---|
| Fragmentation session | `Session` | In the draft, "fragmentation session" is ephemeral (created per packet, destroyed on completion). In -06, a "Session" is a persistent communication channel. Mapping 1:1 would lead to constant Session creation/deletion. | Reassembly context / transaction state (part of the F/R function state) | To prevent term collision with -06's long-lived Sessions and align with the static context model. |
| Attempts / Timers | Flat variables in `SoV` | If SoV is flat, it can only support one active reassembly. Concurrent packet transmissions (via different DTags) would overwrite each other's timers/counters. | Collection of active transaction states in the `SoV` keyed by DTag | To support concurrent reassembly processes within the same long-lived Session. |
| Parameter S | `Context` | S is dynamically calculated per packet size. If mapped to Context, the static Context would have to change per packet. | Dynamic transaction state (inside `SoV` / F/R engine) | S is dynamic state, not static context. |

## Architectural risk points
- **Risk:** Term Collision on "Session"
  - **Why it matters:** Conflating the draft's ephemeral "fragmentation session" with the -06 "Session" may lead implementers to tear down the long-lived communication association, losing cached Context references or SoV state upon packet completion.
  - **Consequence for migration:** The draft must be edited to replace "fragmentation session" with "fragmentation transaction", "reassembly process", or "reassembly context", reserving the term "Session" for the long-lived Instance-to-Instance communication channel defined in -06.
- **Risk:** Concurrent Reassembly State in SoV
  - **Why it matters:** The -06 architecture defines the Set of Variables (SoV) as flat runtime parameters. If an implementation assumes a single flat set of variables, it cannot support concurrent fragmentations (distinguished by DTag) as required by the draft.
  - **Consequence for migration:** The draft should clarify that when concurrent fragmentation is supported, the Instance's SoV must maintain a structured map of transaction variables (timers, attempts counters) indexed by the DTag, rather than a single global set of variables.

## Needed modifications to the draft under study
| # | Section / location in draft | Current concept or text | Proposed change | Category | Rationale |
|---|---|---|---|---|---|
| 1 | 2.3, 2.3.1.2.2, 2.3.1.2.3, 2.3.2, 2.3.2.1, 2.3.2.2, 6, 8.3.1.1 | "fragmentation session" | "fragmentation transaction" (or "reassembly transaction") | REQUIRED FOR TERMINOLOGY MIGRATION | To avoid collision with the -06 "Session" which represents a long-lived communication relationship between Instances. |
| 2 | 2.3 | "fragmentation and defragmentation processes of ARQ-FEC mode are divided into two sub-processes: the assembler sub-process and the transporter sub-process" | "fragmentation and defragmentation processes of the F/R function in the SCHC Instance are divided into two sub-processes: the assembler sub-process and the transporter sub-process" | REQUIRED FOR TERMINOLOGY MIGRATION | Integrates the sub-processes into the -06 "F/R function" component of a "SCHC Instance". |
| 3 | 2.3.2 | "For each active pair of RuleID and DTag values, the sender MUST maintain..." | "For each active pair of RuleID and DTag values, the sender MUST maintain within its Set of Variables (SoV)..." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the storage of runtime variables (timers, counters) with the -06 Set of Variables (SoV). |
| 4 | 2.3.2 | "For each active pair of RuleID and DTag values, the receiver MUST maintain..." | "For each active pair of RuleID and DTag values, the receiver MUST maintain within its Set of Variables (SoV)..." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns the storage of runtime variables (timers, counters) with the -06 Set of Variables (SoV). |
| 5 | 2.3.2 | "Each Profile MUST specify which RuleID value(s) corresponds to SCHC F/R messages operating in this mode." | "Each Profile MUST specify which RuleID value(s) in the Context corresponds to SCHC F/R messages operating in this mode." | REQUIRED FOR TERMINOLOGY MIGRATION | Aligns with the -06 concept of RuleID residing in a Context. |

## Needed modifications to SCHC Architecture -06
No modification to SCHC Architecture -06 is required.

## Final migration assessment
- Can the draft be migrated without changing technical behavior? Yes
- Can the migration be performed mechanically? Mostly
- Does the draft expose a SCHC Architecture -06 gap? No
- Is the gap required for this draft or merely useful generally? Not applicable
- What is the single most important migration issue? Resolving the term collision where the draft uses "fragmentation session" for the ephemeral reassembly of a single packet, whereas -06 uses "Session" for a persistent communication channel between Instances.
