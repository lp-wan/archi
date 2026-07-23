# SCHC Architecture -06 edits needed for draft-ietf-6lo-schc-15dot4-13

## Purpose
Two notions that draft-ietf-6lo-schc-15dot4 relies on are implicit or undefined in
draft-ietf-schc-architecture-06 and close through small, purely additive clarifications:
(1) an Instance's Role may need to be determined per Session rather than being a fixed
per-Instance parameter (needed for per-peer Dev/App roles in mesh topologies), and
(2) the notion of "compatible" Contexts in Section 6.2 needs a definition scoped to the
Session (needed for PRO/Mesh-Under RuleID reuse across disjoint peer pairs). Neither edit
changes the meaning of any existing -06 text or adds/removes an architectural concept.

## Proposed edits

Edit 1 — Role determination per Session
- Architecture section: 4.2.1.1 (Instance Configuration), paragraph "The Role of an Instance is typically derived from extrinsic properties."
- Architecture concept: Role of the Instance
- Reason: draft-ietf-6lo-schc-15dot4 (Sections 6.1 and 6.2) requires each SCHC C/D entity to know its role (Dev or App) "for each node it communicates with". A node hosting a single Instance that communicates with several peers may therefore hold different roles toward different peers. -06 lists Role as an Instance Configuration parameter (i.e., per Instance) and only implies a per-Session reading in one sentence; the Role model is otherwise deferred to future work (Appendix B.2).
- Classification: ARCHITECTURE GAP

```
  e.g., by configuration, but proper SCHC operation requires that the
  method used ensures that all Instances of a Session are aware of
  their role.
+
+ When an Instance participates in several Sessions, its Role may
+ differ from one Session to another: for example, a node in a mesh
+ topology may play the role of the Device in [RFC8724] toward one
+ peer and the role of the Application toward another.  In that case,
+ the Role is a property of the Instance's participation in each
+ Session rather than a fixed parameter of the Instance, and the
+ method used to determine roles must ensure that all Instances of
+ each Session are aware of their role in that Session.
```

Edit 2 — Definition of Context compatibility, scoped to the Session
- Architecture section: 6.2 (Context consistency)
- Architecture concept: Session / "share a common Context" / compatible partial Contexts
- Reason: In draft-ietf-6lo-schc-15dot4, PRO (Section 3.5.3) and Mesh-Under (Section 3.5.4) allow the same RuleID to identify *different* Rules used by *different, disjoint* sets of peer nodes, with delivery guarantees (routing on the destination-address residue, or the Mesh originator address) ensuring that a Datagram only reaches an Instance that holds the binding used by the sender. The participating nodes' Contexts are then not subsets of one another but overlap-divergent, which the current -06 text (which only illustrates the subset case and leaves "compatible" undefined) does not clearly cover.
- Classification: ARCHITECTURE GAP

```
  given Session, it is recommended to deploy the same Context (with
  identical SoR) on all Instances participating in a given Session.
  However, it is possible for one or more Instances to have only a
  subset of the SoR, as long as the Contexts of the Instances
  participating in a given session remain compatible.
+
+ Contexts are compatible for a given Session when every Rule
+ exchanged within that Session is identified by the same RuleID and
+ has the same definition in the Context of each participating
+ Instance.  Rules that are not used within the Session need not be
+ present in every participant's Context.  Furthermore, the same
+ RuleID may identify unrelated Rules in the Contexts of Instances
+ that do not participate in a common Session, provided that the
+ deployment guarantees (e.g., through addressing or routing) that a
+ Datagram is only delivered to Instances whose Context holds the
+ Rule used by the sender.
```

## Effect on the draft under study

- With Edit 1 accepted, the draft's per-peer Dev/App role requirement (Sections 6.1 and 6.2:
  "each SCHC C/D entity needs to know its role (Dev or App) ... for each node it communicates
  with") maps **Directly** to the -06 Role of the Instance, determined per Session, without
  forcing the draft's Single-Instance model into one-Instance-per-peer.
- With Edit 2 accepted, the draft's PRO and Mesh-Under feature "a RuleID MAY be used to
  identify different Rules used by different sets of peer nodes" (Sections 3.5.3 and 3.5.4)
  maps **Directly** as Session-scoped compatible Contexts, and the Session definition
  ("share a common Context") applies naturally to nodes whose stored Contexts diverge
  outside the Rules they exchange.
- All remaining mappings of the draft (Stratum, Discriminator, Dispatcher, Control Header,
  Instance/Context/Session decomposition of the -05 "SCHC Data end point", TPS Strata,
  TRO partial Contexts per -06 Appendix A.3) are Direct, Composite, or naturally
  Profile-specific without any further architecture change.
