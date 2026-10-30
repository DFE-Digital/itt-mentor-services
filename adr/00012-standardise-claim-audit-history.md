# 12. Standardise claim audit history

Date: 2026-10-29

## Status

Accepted

## Context

A claim passes through several stages, from submission to payment and, sometimes, checks and repayment. Support staff need to understand what happened to a claim, who made each change and which files were used.

Today, that information is spread across several logs. They record different details, and some record an action without showing whether the claim's status actually changed. This makes it difficult to explain a claim's history with confidence.

We also need to keep the evidence we already hold. Some older records do not identify who made a change or when it happened. Bringing those records together must not lose information or fill gaps with guesses.

## Decision

Create one consistent history of claim status changes, starting with submission. Each entry will show the previous and new status, who made the change and when it happened. Changes made by an automated process will name that process. Where we have a recorded link to a relevant file, support staff will be able to access it from the history.

This is the best fit because it gives support staff a clear account of a claim's progress without replacing the detailed records that other parts of the service still use. Recording the status change and its history entry together also prevents a change from being saved without its audit record.

Keep the existing logs and files unchanged in a separate archive. Copy confirmed historical status changes into the new history, showing missing names or dates as unknown. Do not treat other recorded actions as proof of a status change.

The history and archive are for support users only. They include changes made by school and provider users as well as support staff and automated processes.

## Alternatives considered

1. **Build the history from the existing general-purpose audit log.** This would reuse the Audited library, which records changes to individual fields. However, we would still need rules to distinguish claim progress from other edits and connect it to users, actions and files. A separate status history makes those requirements explicit while keeping the detailed field log.
2. **Add a dedicated status history and retain the existing logs.** This is the chosen option. It gives support staff a consistent view while preserving existing evidence and the service features that depend on it. The trade-off is an additional record to store and maintain for each status change.
3. **Record changes automatically in the database.** Database triggers could catch changes made outside the application. However, the application would still need to supply the user, automated process and reason for the change. We chose to keep these checks together in the application rather than split responsibility between application code and database triggers.

## Consequences

- Support staff can follow a claim's status changes in one place and consult the original records when they need more detail.
- Preparing an initial draft does not appear in the new history. Once a claim has been submitted, later status changes are recorded, including returns to draft. Edits that do not change status remain in the detailed logs.
- New status changes require an identified user or a named automated process. Older gaps stay visible rather than being presented as facts.
- Keeping both the new history and the original records adds storage and maintenance costs. Recording each change also adds work to claim processing; the measured impact and limits are described in the [performance assessment](../docs/claims/claim-audit-performance.md).
- Deployment replaces the support history view directly, without a feature flag. During the deployment window, the team must import and check historical records before reopening support access.
- The new history does not recover missing files or keep every version of a file that has been replaced. Where a batch holds only its latest file, that remains the case.
- Removing a claim must not remove its audit history. This does not introduce a new retention policy.

## Implementation notes

These notes describe the technical safeguards behind the decision. Operational commands and release checks are in the [backfill and rollout runbook](../docs/claims/claim-audit-backfill-runbook.md).

### Recording new changes

- `Claims::ClaimStatusChange` is the authoritative record of saved claim status changes. Audited continues to record detailed field changes for existing service behaviour.
- Each entry stores the claim ID, old and new statuses, a sequence number within the claim, occurrence time, actor identity and name snapshot, and an actor kind of `user`, `system` or `unknown`. It also stores the source and operation identifiers, whether it was imported, and structured details.
- Save the status change and its history entry in the same database transaction: either both succeed or neither does. Direct SQL, `update_all` and other writes that skip the recording callbacks are not supported ways to change status.
- Approved seed and maintenance operations must name the system operation. Missing historical attribution does not relax the checks for new changes.

### Importing and preserving older records

- Import only explicit claim status changes from Audited. Exclude draft-only history before submission and retain later returns to draft. Do not infer changes from manual activities, batches, CSV contents, current status or nearby timestamps.
- Read historical data using Audited's deserializer. Imported entries reference their exact source audit through a unique `legacy_audit_id`, so retrying the import does not duplicate that transition.
- Do not update or delete original claim audits, associated mentor-training audits, activities, source and batch rows, attachment metadata or files. The archive exposes the original claim and mentor-training audits and existing activity records.
- Keep activities that cannot be linked to a particular claim available through the existing service-wide or source views. Report the missing link; do not create one by matching CSV contents or timestamps.
- The historical import, or backfill, supports dry runs and restartable pages. A fixed upper audit ID and the last processed ID define the range and restart point.
- Reconciliation compares the import with the original evidence. It checks record contents, source links, attachment associations, file existence and checksums, which detect changed file contents. Classify and report unresolved gaps.
- Store comparison reports in an approved restricted location because they contain source identifiers and checksums.

### Display, rollout and recovery

- Deployment immediately replaces the history view on all four support claim-detail pages. There is no feature flag or old-view fallback. Pause affected writes and support access during the deployment window, then complete backfill, reconciliation and gap review before reopening. Production execution, timing and approval are separate operational responsibilities.
- The timeline, archive and file download routes all require support access.
- There is no flag-based rollback. If the new view needs to be withdrawn, deploy a corrective release that preserves status recording. Keep affected writes paused if recording cannot be guaranteed. Do not delete imported entries or original evidence, and retain the existing sources and schema through the agreed rollback window.
- A comparison captured before migration detects file loss or corruption during that migration. It does not preserve old file versions: a later batch resend may legitimately replace the latest attachment.

### Deleted claims and limits

- Store the claim UUID without a database foreign key, with an optional association to the live claim. Deleting a submitted claim must leave its status history intact, matching Audited's existing behaviour.
- Classify records whose claim has been deleted as orphaned evidence; do not attach them to a replacement claim. Non-production reset tooling explicitly deletes status entries before clearing claim data.
- This design does not recover unavailable historical file versions or protect audit evidence against changes made by a database administrator.
