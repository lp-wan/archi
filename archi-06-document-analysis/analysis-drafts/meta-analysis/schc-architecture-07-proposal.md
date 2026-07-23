# SCHC Architecture -07 Minimal Consolidated Proposal

This active proposal keeps only the Architecture change selected after reviewing the AI meta-analysis and the maturity of individual drafts. The mixed analysis tree was not used.

## Proposed Architecture -07 Change

### Control Header routing or inspection pointers
- Motivating draft evidence: `draft-ietf-6lo-schc-15dot4-13`, with related framing evidence from protocol-number work.
- Change: allow a profile to use the Control Header to carry bit pointers or residue-length metadata so an intermediate node can locate selected fields or residues without the full decompression Context.

## Explicitly Not Included
- SCHC Header Format draft changes.
- VOICI draft changes.
- Structured payload / payload-capable C/D changes.
- Split F/R relay or proxy changes.
- Diet-ESP-specific secure-dispatch, trial-decryption, or implicit-RuleID changes.
- RuleID scope / RuleID-size determinability changes.
- Rule Fragment / composable-rule changes.
- Deterministic field descriptor ordering changes.
- Compute-address / dynamic SoV changes, because `draft-westerlund-schc-compute-address-00` is still an early individual document.

## Consolidated Diff

```diff
@@ Section 4.2.5.1 @@
    The Control Header may itself be a SCHC-compressed structure
    piggybacked on the Datagram, or an explicit protocol providing
    services such as:
@@
    *  Metadata (retain information that is lost when performing the SCHC
       operation, e.g., save the initial value of the EtherType field
       when it is changed to EtherType=SCHC)
+
+   *  Routing or inspection pointers, such as bit pointers or residue
+      length metadata, that allow an intermediate node to locate selected
+      fields or residues in a Datagram when the profile permits that node
+      to inspect or update them without possessing the full decompression
+      Context.
```
