# How claim auditing affects performance

## Summary

Recording a claim's history adds database work each time its status changes. The claim update waits for this work to finish, so processing takes longer than before.

The performance improvements remove repeated checks and make matching responses to claims much faster. In the local 5,000-claim test, the improved version was about **25% faster** than the first implementation, but still about **59% slower** than the previous recording approach. These are local measurements, not a prediction of production capacity.

The safety checks remain: a status change and its history entry succeed together, concurrent changes to the same claim are handled in order, and retries do not repeat the same operation. The technical details and measurement limits are below.

## Local measurements

The tests ran on an Apple M3 Pro with Ruby 3.4.12, Rails 8.1.3.1 and local PostgreSQL 17.10. Each combination of batch size and implementation ran three times. The table shows the middle result, or median, rather than a promised production processing rate.

Each test processes unpaid responses for different claims, moving them from `payment_in_progress` to `payment_information_requested`. It measures the work inside the individual claim jobs, not the whole uploaded-batch journey. The comparison with the previous approach keeps the existing Audited field log but disables the new status recorder in the benchmark. Setup is not timed. Each run checks the expected audit and history-entry counts, then rolls back its test-data transaction.

| Claims | Legacy status write | Initial implementation | Optimized implementation |
| ---: | ---: | ---: | ---: |
| 100 | 0.234 s | 0.763 s | 0.548 s |
| 1,000 | 3.769 s | 9.037 s | 6.834 s |
| 5,000 | 17.177 s | 36.568 s | 27.357 s |

Times varied on the shared development machine. At 5,000 claims, runs ranged from 11.071-29.283 seconds for the previous approach, 36.470-39.393 seconds for the first implementation and 26.322-29.118 seconds after improvements. The number of database statements is a more reliable comparison:

| Per successful claim | Legacy | Initial | Optimized |
| --- | ---: | ---: | ---: |
| SQL statements | 4 | 14 | 10 |
| Explicit row-lock reads | 0 | 3 | 1 |
| Actor-existence checks | 0 | 3 | 1 |
| Additional lifecycle event inserts | 0 | 1 | 1 |

For 5,000 claims, the improvements reduce the measured work from **70,000 to 50,000 statements**, including **15,000 to 5,000 explicit lock reads**. A row lock prevents two processes from changing the same claim at the same time. The remaining six statements above the previous approach cover that lock, retry detection, checking the user, linking the original audit, ordering entries and saving the new entry. The lookup fields have database indexes.

### Measurement limitations

- The jobs run one at a time, with the response and user already loaded. The tests exclude queue waits, preparing and reloading queued jobs, database network delays and multiple workers running at once.
- Each sample runs inside one transaction that is rolled back. It does not measure the cost of committing each job separately to durable storage.
- Only unpaid responses are measured. Paid responses also look up school users and schedule notifications. Exports also generate CSV files and upload attachments.
- The test claims have no reference or previous field audits, so they omit the reference-uniqueness query. Statement counts exclude cached queries and database schema lookups. Real jobs also manage transactions and may make more queries. Claims with long histories and larger production indexes may behave differently.
- Repeat measurements with representative staging data before setting a processing target or maximum batch size.

## What happens with larger jobs

### Response dispatch

Previously, finding each claim's response meant searching the response list again. As the batch grew, the same work was repeated more often. The parent job now builds a lookup table once and uses it to find each response directly. If a claim appears more than once, it still uses the first response, preserving the previous behaviour.

For developers: the old `find` loop performs roughly `N * (N + 1) / 2` comparisons. The new hash lookup makes the overall matching work grow in proportion to batch size. Both keep the response data in memory; the hash adds one reference per distinct claim.

A separate test of just the Ruby matching code, including building the lookup table, gave these median results from three runs at each size:

| Response rows | Previous lookup median | Indexed lookup median |
| ---: | ---: | ---: |
| 1,000 | 22.591 ms | 0.241 ms |
| 5,000 | 554.894 ms | 1.269 ms |
| 10,000 | 2,064.481 ms | 2.506 ms |

This measures only matching, not database queries or putting jobs on the queue. Each claim still has its own queued job and can be retried separately. No lock is held across the whole batch.

### Live recording and exports

- Each status change adds one history record and its index entries alongside the existing field audit. Files are linked, not copied.
- The job, status service and recording callback share **one row lock for the transaction**. Different claims can be processed independently; changes to the same claim must wait their turn.
- The user is checked once **per status change**, not once for the whole batch. If a user is deleted during processing, later changes cannot continue relying on an earlier check.
- Exports still keep affected claim rows locked until the batch transaction commits. The extra audit writes lengthen that transaction. Measure lock waits and transaction duration for very large exports in staging.
- Normal status recording does not download files or check their contents. Generating and uploading CSV files remains part of batch processing.

### Backfill and reconciliation

- The historical import, or backfill, processes a page at a time. When resuming, it may need to read earlier records to distinguish initial draft preparation from a return to draft after submission. It reuses that information within the page.
- Reconciliation checks the import against the original evidence. It loads original audits for at most 1,000 history entries at a time, rather than loading them all at once.
- Comparing history with current claim statuses uses two history queries per claim batch rather than two per claim. Tests check that adding claims within a batch does not add more of these queries.
- The report still grows with the number of records. Some checks still look up related data for each record. Files are read in streams rather than loaded whole, but storage delays and total file size can still account for much of the running time.
- Run these checks separately from normal claim processing and page requests. They are too expensive for a routine health check. Follow the paused-write deployment window and reopening checks in the [deployment runbook](claim-audit-backfill-runbook.md).

## Operational checks

Before production deployment, test realistic batch sizes with the expected number of workers in staging. Measure total completion time, queue length, database processor and disk use, lock waits, transaction duration, peak worker memory and storage delays. Include paid responses, exports, retries and competing changes to the same claim.

The local tests show that repeated work has been reduced. They do not establish a safe production maximum batch size or justify running more workers without further measurement.
