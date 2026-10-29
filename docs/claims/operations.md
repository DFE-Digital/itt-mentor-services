# Claims operations

[Claims documentation](README.md)

## Health and telemetry

| Surface | Evidence and use |
| --- | --- |
| `/healthcheck` | [OK Computer](../../config/initializers/okcomputer.rb) mount; use with database and SHA checks |
| `/healthcheck/database` | Registered Active Record database check |
| `/healthcheck/sha` | Registered app-version check; compare with intended deployment |
| `/good_job` | Support-only dashboard: inspect failures, queues, scheduled jobs and arguments |
| `/flipper` | Support-only feature flags; use [feature-flag guide](../feature-flags.md) |
| Sentry | [Organisation entry point](https://dfe-teacher-services.sentry.io/); select the service/environment. [Initializer](../../config/initializers/sentry.rb) identifies hosting environment and release SHA; GoodJob thread errors are sent to Sentry |
| Skylight | [Skylight entry point](https://www.skylight.io/) and [README application link](../../README.md); investigate slow requests/jobs |
| Logs / Logit | [Production logging](../../config/environments/production.rb) writes tagged stdout; [Terraform](../../terraform/application/application.tf) enables Logit for web/worker |
| StatusCake | [Terraform](../../terraform/application/statuscake.tf) configures environment-specific uptime, SSL and contact groups |
| Replication monitor | [Workflow](../../.github/workflows/database-replication-monitor.yml) checks QA/production WAL at 00:00, 06:00, 12:00 and 18:00 UTC |

Health checks do not prove Notify, reference-data syncs, financial exchanges or analytics are working. A `/up` logging setting is not evidence that `/up` is this application's health endpoint.

The team confirmed that alerts go to the [CFMT Development Teams channel](https://teams.microsoft.com/l/channel/19%3A2163e383d0ff428d8a02e3ff421682ff%40thread.tacv2/CFMT%20Development?groupId=5e035efe-5b2b-491b-9e3e-d832445e4ad1&tenantId=fad277c9-c60a-4da1-b5f3-b3b8b34a82f9) and that delivery has been tested. Channel and dashboard access require the appropriate organisational permissions.

StatusCake is used for monitoring. The team also reports health checks in CI. The checked deployment action runs smoke tests after Terraform apply; that is not evidence that StatusCake blocks rollout before changes occur.

No formal support hours, SLA/SLO or response targets were supplied as agreed at handover. Incident escalation creates a new private Teams channel, with membership decided for that incident. No formal rota was supplied.

> **Needs to be found.** Obtain application-log and StatusCake dashboard links, alert thresholds, formal support/on-call arrangements and evidence for any additional CI health gate. Sentry excludes `Google::Cloud::Error`; do not rely on Sentry alone for analytics failures.

## Jobs and queues

[GoodJob configuration](../../config/initializers/good_job.rb) runs asynchronously inside the server in development and in external workers in production Rails mode. Cron is enabled in production Rails mode, which includes hosted non-production environments using the production image. Completed jobs are configured for cleanup after four days.

The main work uses `default`; analytics uses `dfe_analytics`. Confirm current queue depth, oldest jobs, error rate and worker health before retrying. Do not assume a generic retry policy from the commented examples in [ApplicationJob](../../app/jobs/application_job.rb).

### Scheduled work

Expressions below are copied from [scheduled_jobs.yml](../../config/scheduled_jobs.yml). Verify the effective GoodJob/runtime timezone before translating them into local clock times, especially around daylight-saving changes. GitHub workflow cron times are UTC.

| Schedule | Job / purpose |
| --- | --- |
| `15 0 * * *` | `PublishTeacherTraining::Provider::SyncAllJob`: provider reference data |
| `30 23 * * *` | `Gias::SyncAllSchoolsJob`: school import/transformation |
| `5 0 * * *` | `TeachingRecord::SyncAllMentorsJob`: schedule mentor-name refreshes |
| `0 0 * * *` | `PublishTeacherTraining::Subject::SyncAllJob`: shared subject data |
| `10 0 * * *` | `Claims::RemoveInternalDraftClaimsJob`: remove internal drafts |
| `20 0 * * *` | `Claims::RemoveUnprocessedPaymentResponsesJob`: response cleanup |
| `0 01 * * *` | `Claims::User::NotifyUsersOfPaidClaimsJob`: paid notifications |
| `30 0 * * *` | `DfE::Analytics::EntityTableCheckJob`: entity-table checks |
| `15 * * * *` | `TrimExpiredSessionsJob`: session cleanup |
| `0 16 * * *` | `Claims::Slack::DailyRoundupJob`: Slack roundup |
| `0 9 * * MON` | `Claims::User::NotifyUsersOfInvalidProviderClaimsJob`: invalid-provider reminders |
| `0 9 * * MON` | `Claims::Sampling::SendProviderRemindersJob`: sampling reminders |
| `0 10 * * TUE` | `Claims::Sampling::SendSchoolRemindersJob`: school sampling reminders |
| `0 0 1 * *` | `BankHolidays::SyncJob`: refresh holidays |

See [Active Job](../active-job.md) for dashboard controls. Pausing cron does not cancel already-enqueued jobs.

### Investigate or retry a job

Prerequisites: support access, confirmed environment and authorisation for any replayed side effects.

1. Open that environment's `/good_job`; record job class, timestamps, state and error without copying personal arguments into public issues.
2. Check worker health, dependency failures and current affected records.
3. For financial/notification work, inspect [activity records and lifecycle](claim-lifecycle.md) and determine what has already been sent or applied.
4. Retry only after resolving the cause and agreeing the impact. If safe replay cannot be established, escalate instead.
5. Verify job outcome and affected business state. A queue leaving the dashboard is not proof of correct financial reconciliation.

## Support and periodic processes

| Task | Entry point / safeguards |
| --- | --- |
| School/provider/user onboarding | Support routes under [claims routes](../../config/routes/claims.rb); use the corresponding [wizards](../../app/wizards/claims/) and validate supplied eligibility data |
| Claim window changes | Support claim-window routes; [model](../../app/models/claims/claim_window.rb) validates date overlaps and hides discarded windows |
| Payments, sampling and clawbacks | [Lifecycle and file contracts](claim-lifecycle.md); verify upload results and async jobs |
| Reminders and support-created claims | Support UI and action-specific policies; exceptional paid claims have different notification behaviour |
| School deactivation | [Destructive console procedure](../deactivate-school.md), not ordinary account removal |
| Feature rollout | [Feature flags](../feature-flags.md); record previous targeting before changing |
| Academic-year readiness | Confirm years/windows, eligible schools/providers, training allowances, reference-data freshness and operations ownership before opening a window |
| Manual school email updates | [ADR 8](../../adr/00008-populate-school-emails-via-task.md) records the dependency; confirm current supplier and approved task/input before execution |

Register supplies eligibility data through a manual request. Policy sets claim windows and the financial-process dates. At the October 2026 handover, dates for the next several years were still being agreed. Do not infer the final dates from that planning activity.

> **Needs to be found.** Publish the agreed calendar once available, and confirm request/file owners, input approval and financial reconciliation controls. Do not treat ADR dates or historical frequency estimates as current schedules.

## Analytics and reporting

[DfE Analytics](../../config/initializers/dfe_analytics.rb) enables events for configured hosting environments, uses `dfe_analytics`, entity-table checks and federated Google authentication. Review [analytics fields](../../config/analytics.yml), [blocklist](../../config/analytics_blocklist.yml) and [hidden PII configuration](../../config/analytics_hidden_pii.yml) before adding data.

[Airbyte](../../terraform/application/airbyte.tf) provides a separate replication path. A healthy request-event queue does not prove replication freshness. WAL retention problems can affect the operational database. Inspect the replication monitor before using [replication repair workflow](../../.github/workflows/fix-airbyte-replication.yml); repair is not a routine read-only check.

The Analytics team owns analytics. Developers own reporting, as confirmed at handover.

> **Needs to be found.** Confirm BI/dashboard and dataset links, freshness targets, reconciliation and approved resync procedures. Owners for other integrations remain unspecified.

For incidents use [incident cheatsheet](../incident-cheatsheet.md). For symptoms use [troubleshooting](troubleshooting.md).
