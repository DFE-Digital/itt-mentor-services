# 12. Standardise claim audit history

Date: 2026-10-29

## Status

Accepted

## Context

Claim status history is currently reconstructed from generic Audited rows and operational activities. The sources differ in actor attribution and file relationships, and activities do not consistently represent persisted status changes. Historical data also includes draft preparation, associated mentor-training audits, unlinked activities, batch records and attachments. A new timeline must not turn incomplete evidence into invented transitions or remove the evidence that supports existing operational and business behaviour.

## Decision

Add `Claims::ClaimStatusChange` as the canonical record for persisted claim status changes. Keep Audited and the existing activity, batch and file records unchanged and available as the legacy evidence archive.

Each event records actual old/new status values, its claim, per-claim sequence, occurrence time when known, actor identity/name snapshot when known, an explicit `user`, `system` or `unknown` actor kind, operation/source provenance, import flag and structured details. Historical unknown actors and times remain explicitly unknown. They do not weaken live attribution validation. Import events reference their exact legacy audit through the unique `legacy_audit_id`; retries therefore cannot duplicate the same source transition.

Status and event persistence must be atomic through the application write boundary. Direct SQL, `update_all` or callback-skipping writes that change status without that boundary are unsupported. Approved seed/maintenance work must use an explicit named system operation; historical writes without enough provenance remain reported gaps.

The backfill derives transitions only from explicit claim status changes in Audited records. It excludes draft-only history before submission, retains returns to draft after submission, and does not infer a transition from a manual activity, batch, CSV content, current claim status or time proximity. Audited's deserializer is used to read historical payloads. Original audits, associated mentor-training audits, activities, source/batch rows, attachment metadata and files are not updated or deleted. Reconciliation checks source payload fingerprints, event provenance, attachment associations, stored checksums and file existence; unresolved historical gaps are classified and reported.

The legacy archive continues to expose original claim/associated audits and existing activity records. Payment-response activities with no exact persisted claim/source identity remain globally available and are reported as unlinked; CSV/time matching is not a migration rule.

The support timeline cutover is gated by the `:claim_status_history` Flipper flag, which remains off until backfill and reconciliation pass. The legacy archive and support-authorized event-source file endpoints remain available independently of that flag.

The event stores the claim UUID without a database foreign key and has an optional association to the live claim. This is deliberate: removing a submitted claim must preserve its immutable transition rows, as Audited already preserves its audit rows. A status audit for a deleted claim is retained and classified as orphaned rather than used to invent a replacement claim. Non-production reset tooling explicitly removes status events before resetting data.

We considered:

1. **Extending Audited for lifecycle history.** This would reuse an existing library but couples status semantics to generic field changes and does not solve activity, batch or file evidence relationships.
2. **Adding a dedicated status-change model while retaining Audited.** This gives status transitions a stable queryable contract and allows source provenance while retaining detailed audits and existing consumers. This is the chosen option.
3. **Database triggers.** Triggers could observe direct SQL writes but cannot reliably identify initiating users, named system operations or request/source context. They also move domain validation outside the application. Status writes must instead use the audited application write boundary.

Historical batch files remain latest-file only where the existing source replaces its attachment. A pre-cutover baseline detects file loss or corruption during the migration window; after cutover, a normal resend may replace a batch's previous latest attachment. This decision does not recreate unavailable historical file versions, infer CSV-to-claim links, or promise tamper evidence against database administrators.

## Consequences

- Status writers must persist the claim change and its attributed event atomically; unsupported direct status writes must not bypass the writer.
- Generic Audited rows remain useful for detailed field history and existing domain behaviour; they are not removed during this migration.
- Support users can inspect a unified status timeline and a separate legacy archive without presenting activities as status changes.
- Backfill is additive, dry-run-capable, paginated and restartable using an audit high-water mark and cursor. Reconciliation is read-only and must pass against the retained dry-run baseline before enabling the timeline flag.
- Production backfill, gap review, rollout timing and approval are operational responsibilities outside this code change. Keep the legacy sources and schema through the agreed rollback window.
- Rollback may disable the new timeline flag, but must not disable status recording while writes continue. Do not delete imported events or original evidence as part of rollback.
- The source and file inventory is emitted as a report; reports contain source identifiers and checksums and must be retained in an approved restricted location.
- Claim removal does not cascade to status events. The non-production reset path must explicitly delete them before clearing claim data.
