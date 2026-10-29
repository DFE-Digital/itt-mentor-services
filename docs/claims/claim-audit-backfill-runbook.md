# Claim status history backfill and cutover

This runbook covers additive legacy backfill and read cutover for `Claims::ClaimStatusChange`. It does not authorize or perform a production migration, data review, rollout or operational approval.

## Safety and evidence

- Keep the original Audited rows (including associated mentor-training audits), `ClaimActivity` rows, source/batch rows, attachment metadata and existing files. Backfill and reconciliation must not update or delete them.
- Do not infer actors, occurrence times, transitions, batch relationships or claim links from current values, timestamps, or ambiguous CSV rows. Only explicit claim status audits produce canonical imported transitions.
- Draft-only status history before first submission is excluded from the canonical timeline and remains in the archive. Post-submission returns to draft are included.
- Unlinked activities and batch/file evidence remain available at their existing global/source surfaces and are classified by reconciliation. A source/activity is attached to a transition only where its persisted source identity proves the association.
- The per-claim legacy archive exposes the original claim and associated mentor-training audits with their serialized payload/metadata, plus the existing activity records and attributes. An activity or response with no exact claim/source association remains globally retained and reported as unlinked; CSV contents and timestamp proximity are not used to invent a per-claim link.
- The dry-run report contains source IDs and SHA-256 fingerprints plus attachment IDs, stored checksums, sizes and existence. Retain it in an approved restricted location; do not put it in a public artifact or an ephemeral temp directory.
- Reconciliation streams every available source file to verify its bytes against the Active Storage checksum. Missing files present in the baseline and checksum mismatches fail reconciliation. Files already missing at baseline are reported as historical gaps, not claimed as recovered.
- This migration intentionally does not archive immutable versions of replaced batch files. Existing latest-file semantics remain.
- The event table intentionally has no database foreign key to `claims`: removing a submitted claim keeps its immutable transition rows, matching Audited retention. Orphaned event/audit evidence is classified, not attached to a replacement claim. Non-production reset code explicitly clears events before resetting claims.

## Expand and prepare

1. Deploy the additive schema and code while the `:claim_status_history` Flipper flag remains **off**. With the flag off, all four support claim-detail surfaces continue to show the existing operational activity history; the new timeline is not queried.
2. Confirm writer code is active and old status-writing workers/queues are drained or compatible. Schedule a controlled window that pauses affected status/source/file writes for the baseline, apply and final reconciliation. The app must not permit unaudited status changes during any rollback.
3. Use a restored representative dataset to estimate volume, page size and storage verification time. Review access controls and retention for the restricted report. Production execution requires separate operational approval.

## Capture a baseline

Run a dry run with a fixed page size. Preserve the complete JSON output at a restricted, durable location approved by the service team:

```sh
bundle exec rake claims:claim_auditing:backfill DRY_RUN=true LIMIT=500
```

The report includes a `high_water_mark`, `last_audit_id`, classifications and `source_snapshot`. The high-water mark bounds the audit set while status writers are active. A dry run performs no database writes.

If investigating one claim, use `CLAIM_ID=<uuid>` consistently for dry run, apply and reconciliation. The full-service release gate must also reconcile the entire bounded dataset; a single-claim report is not a substitute.

## Apply the resumable backfill

Start at the beginning of the captured range, using its exact high-water mark:

```sh
bundle exec rake claims:claim_auditing:backfill \
  DRY_RUN=false LIMIT=500 HIGH_WATER_MARK=<captured-high-water-mark>
```

For each subsequent page, pass the same high-water mark and the prior page's `last_audit_id`:

```sh
bundle exec rake claims:claim_auditing:backfill \
  DRY_RUN=false LIMIT=500 AFTER_AUDIT_ID=<last-audit-id> \
  HIGH_WATER_MARK=<captured-high-water-mark>
```

The unique `legacy_audit_id` makes retries safe. A retry that finds an existing matching live event is treated as already present; a provenance/payload mismatch or unclassified status audit raises instead of being silently imported. Do not edit the source audits to make a run pass.

After the final page, repeat the bounded backfill from the beginning. It must report no additional imports. Retain page reports with the original dry-run report.

## Reconcile and release gate

Supply the retained dry-run JSON report as `BASELINE_FILE`:

```sh
bundle exec rake claims:claim_auditing:reconcile \
  BASELINE_FILE=<restricted-dry-run-report.json>
```

Reconciliation is read-only. It verifies source audit mappings and raw metadata fingerprints, transition payloads, duplicate provenance/operations, source row fingerprints, activity/batch classifications, attachment relationships, blob existence and file checksums. It fails on unexplained omissions, altered source metadata, missing baseline files, corruption and unclassified exceptions. Unknown historical actor/time, draft history, orphaned or unlinked evidence, unrepresented current statuses, and files missing in the baseline are reported as classified gaps for review; they are not fabricated into events.

Do not enable the new timeline until all of these are true:

- The second backfill adds zero events.
- Reconciliation exits successfully against the retained baseline.
- There are zero unexplained source omissions, event duplicates, source payload mismatches, missing baseline files or checksum failures.
- Classified historical gaps have been reviewed and recorded by the responsible operational team.
- Current claim status mismatches or non-draft claims with no event have been explicitly reviewed as gaps rather than "fixed" by synthesizing transitions.
- The legacy archive and event-source file endpoints have been checked with support authorization.

Only after that gate, enable `:claim_status_history` for the support timeline. The legacy archive and event-source file endpoints remain support-authorized independently of the flag. Keep the report and source evidence access-controlled.

The retained baseline is a migration-window comparison, not a forever-pinned file version. After cutover, normal batch resends may replace the latest attachment; do not reconcile that expected replacement against a stale pre-cutover snapshot and describe it as a migration loss. If a later reconciliation is required, capture a new approved baseline at its operational boundary and classify the existing latest-only replacement semantics.

## Rollback and retention

If the timeline is incorrect, turn the flag off to restore the existing operational activity history on the four support surfaces. Keep the new writer enabled while claim status changes continue; disabling event recording would permit unaudited writes. Do not drop the new table, remove imported events, or delete/rewrite original audits, activities, batches or files. Reconcile any post-cutover writes before changing writers or rolling back code. Retain legacy sources through the agreed rollback window and follow existing data-retention policy.

No production backfill, reconciliation or flag change has been performed as part of this code change.
