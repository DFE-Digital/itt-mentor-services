# Troubleshooting

[Claims documentation](README.md)

These are diagnostic paths supported by code/configuration, not a list of confirmed recurring incidents. For an outage use the [incident cheatsheet](../incident-cheatsheet.md) and current incident playbook first.

No recurring incidents were reported during the October 2026 handover. This is not an independent review of monitoring history.

## Safety and evidence

Confirm the host, namespace, deployment and SHA before investigating. Use read-only checks first. Record timestamp, request/job ID and release SHA without exposing personal data, CSV contents or credentials.

| Symptom | Checks | Resolution / escalation |
| --- | --- | --- |
| Wrong service, route or callback | Compare requested host with [hosting rules](../../lib/hosting_environment.rb), environment YAML and [domain map](../../terraform/domains/environment_domains/config/) | Resolve host/alias/callback configuration with platform; do not change DfE credentials on a hostname guess |
| Redirected to sign-in | Session timeout, configured sign-in method and [role resolution](../../app/models/dfe_sign_in_user.rb) | Sign in again; confirm service-specific user record and memberships through approved support tools |
| Signed in but action unavailable | [Policies](../../app/policies/claims/), window dates, eligibility, grant conditions and current claim state | Correct approved eligibility/access data; do not bypass Pundit or edit claim status directly |
| Provider missing in suggestions | Query text, selected academic year, provider eligibility and NIoT filtering | Check [API contract](api.md); `accredited` alone does not make a claims provider eligible |
| Fewer hours than expected | Mentor/provider/year history and [TrainingAllowance](../../app/models/claims/training_allowance.rb) | Check cross-school claims and year boundary; do not apply historical ADR allowance figures |
| CSV rejected | Required headers, MIME type, lowercase statuses, reference state, payment details or sample reason | Use [contracts](claim-lifecycle.md#payment-and-assurance-exchanges); export and response formats differ |
| Upload accepted but claim unchanged | Collection and child jobs, present claim status and business activity | Check [payer job](../../app/jobs/claims/payment/update_claim_with_payer_response_job.rb); `submitted` input is not a paid/unpaid outcome |
| Mail absent or delayed | GoodJob, Notify, delivery scheduling and prior sends | Establish whether it was sent before retrying; use test credentials only outside approved live delivery |
| Reference data stale | [Scheduled sync](operations.md#scheduled-work), worker availability and import logs | Identify the failed stage/dependency; rerun only the affected job after assessing side effects |
| Teaching Record mentor not found | TRN, [sync job](../../app/jobs/teaching_record/sync_mentor_job.rb) and Sentry | Not-found is explicitly reported; other HTTP failures raise. Escalate data issues through approved channels |
| Analytics stale / WAL growth | `dfe_analytics`, federated identity, Airbyte and [replication monitor](../../.github/workflows/database-replication-monitor.yml) | Escalate to data/platform before repair/resync; Google cloud errors are excluded from Sentry |
| Missing CSV download | Record attachment, blob existence, access controls and correct environment | Do not recreate or resend a financial batch before reconciliation; see [recovery](disaster-recovery.md) |
| Local assets or boot fail | Declared tools, PostgreSQL, PROJ, `yarn install --immutable`, local env and watcher output | Resolve the failed dependency/configuration; avoid repeated destructive setup/reset |

## Debug surfaces

- [Azure connection guide](../connect-to-azure.md): read-only logs and approved console access.
- [Operations](operations.md#health-and-telemetry): health, SHA, Sentry, Skylight, logs and jobs.
- [Request and system specs](development.md#test-and-lint-entry-points): reproduce with synthetic local data.
- [Claim services](../../app/services/claims/claim/) and [activity model](../../app/models/claims/claim_activity.rb): locate transitions and exchange evidence.

Do not globally enable verbose production logging as a first step. [Production configuration](../../config/environments/production.rb) warns that debug logging can expose personal information.

Escalation creates a private Teams channel with membership decided for the incident. Higher-level communication and post-incident review guidance is stored externally. See [operations](operations.md#health-and-telemetry) for the development alert channel and supplied Sentry/Skylight entry points.

> **Needs to be found.** Link the authoritative external incident guidance, application logs, StatusCake checks and any tested resolution examples when available. Record only sanitised evidence in the public documentation.
