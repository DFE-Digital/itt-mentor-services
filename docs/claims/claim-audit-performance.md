# Claim audit performance

## Summary

Lifecycle recording adds synchronous database work to each status change. The timeline flag only controls reads: turning it off does **not** disable this overhead.

The performance pass removes duplicate row locks and actor-existence checks, changes response collection matching from quadratic to linear, and batches reconciliation lookups. It retains transactional recording, per-claim serialization, stale-write detection and operation idempotency; it does not bypass callbacks or bulk-insert live events.

## Local measurements

Measured on an Apple M3 Pro with Ruby 3.4.12, Rails 8.1.3.1 and local PostgreSQL 17.10. Three samples were taken per size and implementation. Values below are medians, not production throughput commitments.

The workload processes distinct claims from `payment_in_progress` to `payment_information_requested` through the payer-response child job body. The baseline uses the equivalent successful-path status update with generic Audited enabled but the new recorder disabled. Setup is outside the measurement. Every sample verifies the expected generic-audit and lifecycle-event counts, then rolls back its isolated test-data transaction.

| Claims | Legacy status write | Initial implementation | Optimized implementation |
| ---: | ---: | ---: | ---: |
| 100 | 0.234 s | 0.763 s | 0.548 s |
| 1,000 | 3.769 s | 9.037 s | 6.834 s |
| 5,000 | 17.177 s | 36.568 s | 27.357 s |

At 5,000 claims, the optimization reduced measured time by approximately **25%** versus the initial implementation. The optimized workload was approximately **59% slower** than the legacy baseline in this local run.

Timing was noisy on the shared development machine: the 5,000-claim samples ranged from 11.071-29.283 s for legacy, 36.470-39.393 s initially and 26.322-29.118 s after optimization. Database query counts are the more reliable comparison:

| Per successful claim | Legacy | Initial | Optimized |
| --- | ---: | ---: | ---: |
| SQL statements | 4 | 14 | 10 |
| Explicit row-lock reads | 0 | 3 | 1 |
| Actor-existence checks | 0 | 3 | 1 |
| Additional lifecycle event inserts | 0 | 1 | 1 |

For 5,000 claims this is **70,000 to 50,000 statements**, including **15,000 to 5,000 explicit lock reads**. The remaining six statements above the legacy baseline enforce the lock, operation lookup, attribution, generic-audit linkage, event sequence and event insert. Lookup keys are indexed.

### Measurement limitations

- These are sequential worker-body measurements with an already-loaded response and actor. They exclude queue latency, Active Job serialization/deserialization, source/actor reloads, network database latency and worker concurrency.
- Samples run inside a rolled-back outer transaction, so they do not measure an individual durable commit/fsync per child job. They are not end-to-end uploaded-batch timings.
- All rows use the unpaid path. Paid responses additionally perform existing school-user queries and notification scheduling; large exports additionally generate CSVs and upload attachments.
- The fixture claims have no reference or previous generic audits, so they omit the reference-uniqueness query. Query counts exclude cache hits and schema introspection. Real jobs also incur transaction control and can have additional uncached/reloaded queries. Claims with long histories and production-sized indexes can behave differently.
- Absolute times and percentage overhead must therefore be remeasured on representative staging data before setting an operational capacity target.

## Larger-job behavior

### Response dispatch

Previously each child lookup searched the full response array with `find`: processing all rows performs roughly `N * (N + 1) / 2` comparisons. A first-response-preserving hash now indexes the payload once, with constant-time lookup per claim. Both approaches retain the existing payload in memory; the hash adds one reference per distinct claim.

A separate Ruby-only lookup benchmark, including hash construction and three samples per size, measured:

| Response rows | Previous lookup median | Indexed lookup median |
| ---: | ---: | ---: |
| 1,000 | 22.591 ms | 0.241 ms |
| 5,000 | 554.894 ms | 1.269 ms |
| 10,000 | 2,064.481 ms | 2.506 ms |

This is only the matching portion of the parent job, not the database queries or enqueue work. Children remain individually queued and retryable; no global batch lock was introduced.

### Live recording and exports

- Successful recording remains linear in the number of transitions. Each adds one event row plus its indexes, alongside the existing generic audit. Files are referenced, not duplicated.
- The child job, status service and callback share **one transaction-scoped row lock**. Distinct claims can be processed independently. Concurrent changes to the same claim intentionally serialize.
- Attribution is checked once **per transition**, not cached across a whole batch. A deleted actor cannot remain trusted for later changes.
- Export services retain their existing outer transaction: affected rows remain locked until batch creation commits. The extra writes extend that transaction, so very large exports still warrant staging measurements of lock waits and transaction duration.
- No extra storage downloads or checksums run during normal status recording. CSV generation/attachment upload remains batch work.

### Backfill and reconciliation

- Backfill remains explicitly paginated. Resumed pages inspect preceding claim evidence when necessary to distinguish initial drafts from post-submission draft transitions, with lifecycle state reused within the page.
- Reconciliation fetches source audits in batches of at most 1,000 referenced events rather than materializing every referenced audit at once.
- Current-state reconciliation uses two event queries per claim batch instead of two per claim. Regression tests assert a fixed query count while the number of claims grows within one batch.
- Full source snapshots, classifications and attachment verification are intentionally comprehensive. The snapshot/report still grows with the evidence count; some classification passes still perform per-record association lookups. File verification streams bytes, but storage latency and total file volume can dominate runtime.
- Run migration reconciliation separately from interactive requests and normal response processing. It is not a cheap health check. Retain the controlled-write window and release gates in the [backfill runbook](claim-audit-backfill-runbook.md).

## Operational checks

Before production cutover, use representative staging batch sizes and worker concurrency to measure wall-clock completion, queue depth, database CPU/I/O, row-lock waits, transaction duration, peak worker memory and storage latency. Include paid responses, exports, retries and contention on the same claim.

The local pass demonstrates reduced avoidable work and linear response matching; it does not establish a production maximum batch size or justify raising worker concurrency without measurement.
