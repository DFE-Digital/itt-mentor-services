# Claim funding for mentor training - Handover Document

> **How to read this document:** Regular headings follow the run-state handover template. `✦` headings add service-specific context. `⚠` sections contain gaps or controls not yet established. This document summarises repository evidence and operational answers supplied at the 29 October 2026 handover. Reported practice is distinguished from independently verified controls. The scope is claims; historical placements material is retained where it explains shared dependencies.

## Architecture

### Service overview

Schools claim funding for mentor training. Provider users respond to sampling requests. Support users manage onboarding, claims, payment exchanges and assurance. The root README lists claims as the current service. Placements code, routes and database tables remain from the shared-codebase design.

→ [Service README](https://github.com/DFE-Digital/itt-mentor-services/blob/main/README.md)
→ [Architecture and Mermaid context diagram](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/architecture.md)

### Infrastructure and tech stack

Rails web and GoodJob worker workloads run on Azure Kubernetes Service. Postgres holds business data, sessions, jobs and feature flags. Active Storage uses Azure Blob Storage in production Rails mode. Configuration comes from Terraform and Key Vault-backed application configuration. The stack includes Ruby, Rails, Stimulus, GOV.UK components, Sass and esbuild. Read manifests for versions.

→ [Application Terraform](https://github.com/DFE-Digital/itt-mentor-services/blob/main/terraform/application/application.tf)
→ [Gemfile](https://github.com/DFE-Digital/itt-mentor-services/blob/main/Gemfile)
→ [Package manifest](https://github.com/DFE-Digital/itt-mentor-services/blob/main/package.json)
→ [Dockerfile](https://github.com/DFE-Digital/itt-mentor-services/blob/main/Dockerfile)

### Decisions and data model

Existing ADRs explain shared code, Pundit, Stimulus, testing, geocoding and wizards. Some describe historical designs rather than current claims behaviour. The claims data guide contains Mermaid ERDs, a data dictionary and database-versus-application constraint notes.

→ [ADR applicability index](https://github.com/DFE-Digital/itt-mentor-services/blob/main/adr/README.md)
→ [Claims data model](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/data-model.md)
→ [Schema](https://github.com/DFE-Digital/itt-mentor-services/blob/main/db/schema.rb)

### Third-party integrations

The register covers DfE Sign-in, GIAS, Publish Teacher Training, Teaching Record, GOV.UK Notify, financial file exchanges, bank holidays, analytics and operational telemetry. It identifies configuration names and failure boundaries without exposing credentials. External access and ownership need confirmation.

→ [Integration register](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/integrations.md)
→ [Secret configuration guide](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/environment-variables-in-azure.md)

---

## API

### HTTP interfaces, versioning and rate limits

The service is primarily server-rendered. Session-authenticated JSON suggestion endpoints return schools/providers, including academic-year provider filtering. They are unversioned and capped at 50 results. Signed-out requests redirect to sign-in. No endpoint-specific application rate limiter was found in the inspected implementation; platform limits and compatibility expectations need confirmation.

Payment, sampling and clawback are file exchanges, not a public claims REST API. No OpenAPI generation process is configured in the inspected documentation/workflows.

→ [API reference and examples](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/api.md)
→ [Shared routes](https://github.com/DFE-Digital/itt-mentor-services/blob/main/config/routes.rb)
→ [CSV contracts](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/claim-lifecycle.md)

---

## Environments

### Environment list

The canonical production sign-in address is https://claim-funding-for-itt-mentor-training.service.gov.uk/sign-in, confirmed by the team. The former `education.gov.uk` address is not a supported alias. Other environment URLs follow repository configuration, not live reachability checks. Legacy redirects remain in domain Terraform and need platform reconciliation.

| Environment | Documented URL | Cluster | Namespace |
| --- | --- | --- | --- |
| Production | https://claim-funding-for-itt-mentor-training.service.gov.uk | production | bat-production |
| Sandbox | https://sandbox.claim-funding-for-itt-mentor-training.service.gov.uk | production | bat-production |
| Staging | https://staging.claim-funding-for-itt-mentor-training.service.gov.uk | test | bat-staging |
| QA | https://qa.claim-funding-for-itt-mentor-training.service.gov.uk | test | bat-qa |
| PR review | Generated; use deployment output | test | bat-qa |
| Development review | Generated; use deployment output | Selected development cluster | development |
| Platform-test review | Generated; use deployment output | platform-test | development |

→ [Environment inventory and sign-in modes](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/deployment.md)
→ [Environment configuration](https://github.com/DFE-Digital/itt-mentor-services/tree/main/terraform/application/config/)

### Infrastructure configuration and promotion

Application and domain Terraform are separate. Main deployments proceed through QA, staging and sandbox before production. The team reports no additional manual approval after merge. Actual CI blocking checks and legacy domain configuration still need verification.

→ [Terraform](https://github.com/DFE-Digital/itt-mentor-services/tree/main/terraform/)
→ [Promotion workflow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/build_and_deploy.yml)

---

## Deployment

### CI/CD and container build

Main pushes build an image and deploy through the environment chain. Labelled PRs can deploy review apps. Build/test is a separate workflow. Do not infer branch protection or approval gates from YAML alone. The shared deployment action applies Terraform and then runs smoke specs. Web and worker modules depend on the migration job.

The confirmed review process requires a PR review environment, product review and approval from a second developer. Any other developer can perform that review. Merge is manual, with no further manual approval reported. Terraform/Kubernetes setup or smoke-test failures stop the deployment job and further promotion; non-production failures block production. Changes already applied are not automatically undone, so a production smoke-test failure may require PR-revert recovery. The inspected deployment workflow does not establish a dependency on the separate test workflow; branch-protection checks remain unverified.

→ [Deployment guide and Mermaid flow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/deployment.md)
→ [Build and test](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/build_and_test.yml)
→ [Deployment action](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/actions/deploy-environment/action.yml)
→ [Container build](https://github.com/DFE-Digital/itt-mentor-services/blob/main/Dockerfile)

### ⚠ Rollback, frequency and schedule

The team's rollback approach is to revert the failing PR through the normal pipeline. The manual deployment workflow does not offer production. Reverting code does not reverse data changes or external side effects.

> **Needs to be found.** Rehearse PR-revert recovery, verify CI/rollout gates and migration compatibility, and confirm freeze periods and operational release cadence. Deployment triggers are documented; actual frequency and successful rollback evidence are not established here.

→ [Manual deploy workflow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/deploy.yml)
→ [Audit G4](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)

---

## Operations

### Monitoring, health checks and alerts

Use `/healthcheck`, `/healthcheck/database` and `/healthcheck/sha` on the intended host. GoodJob and Flipper dashboards require support access. Repository configuration covers Sentry, Skylight, Logit, StatusCake and replication monitoring. Google cloud errors are excluded from Sentry; check analytics queues and replication separately.

The team uses the CFMT Development Teams channel for alerts and reports that delivery has been tested. Sentry and Skylight entry points are supplied in the operations guide. StatusCake is used for monitoring; CI smoke checks in the inspected action occur after apply.

> **Needs to be found.** Obtain application-log and StatusCake dashboard links, thresholds and any formal rota/support arrangements. The reported CI health-check use is not proof of a pre-deployment gate.

→ [Operations telemetry register](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/operations.md)
→ [Health configuration](https://github.com/DFE-Digital/itt-mentor-services/blob/main/config/initializers/okcomputer.rb)

### Background jobs and periodic activities

GoodJob uses Postgres. Cron is enabled in production Rails mode, including hosted non-production environments using the production image. Jobs cover reference-data sync, claims cleanup, notifications, entity checks, sessions, reminders and bank holidays. Check effective cron timezone before interpreting local times.

Academic-year readiness requires windows, school/provider eligibility, training rules and operational coordination. Do not substitute historical ADR assumptions for current policy.

Register supplies eligibility data by manual request. Policy sets claim windows and financial-process dates. The multi-year calendar was still being agreed at handover.

→ [Job inventory and support processes](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/operations.md)
→ [Schedule](https://github.com/DFE-Digital/itt-mentor-services/blob/main/config/scheduled_jobs.yml)
→ [GoodJob controls](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/active-job.md)

### User access, permissions and authentication

School, provider and support identities have different policy scopes. One person can have multiple role records. DfE Sign-in and persona modes are selected by configuration, not automatic failover. Production/staging are configured for DfE Sign-in; QA/sandbox use personas. Application support access is separate from cloud deployment permission.

Request production access through the service PM, then activate it through Azure PIM. Out-of-hours authorisation remains unconfirmed.

→ [Security and sign-in sequence](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/security.md)
→ [Identity resolution](https://github.com/DFE-Digital/itt-mentor-services/blob/main/app/models/dfe_sign_in_user.rb)
→ [Claims policies](https://github.com/DFE-Digital/itt-mentor-services/tree/main/app/policies/claims/)

### BI and reporting

DfE Analytics sends async events/entity checks through `dfe_analytics`. Airbyte provides a separate database replication path. The Analytics team owns analytics; developers own reporting. Confirm reporting consumers, dataset access, freshness objectives and resync procedures with those owners.

→ [Analytics initializer](https://github.com/DFE-Digital/itt-mentor-services/blob/main/config/initializers/dfe_analytics.rb)
→ [Airbyte Terraform](https://github.com/DFE-Digital/itt-mentor-services/blob/main/terraform/application/airbyte.tf)
→ [Integration data-flow diagram](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/integrations.md)

### ⚠ Non-functional requirements and SLAs

No formal service commitments, support hours or SLA/SLO targets were supplied as agreed at handover.

> **Needs to be found.** Establish objectives and support commitments with the service owner if required. Alert thresholds, capacity expectations and dependency agreements remain unconfirmed. Do not derive guarantees from replica counts or schedule configuration.

→ [Audit G2/G3](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)

### ✦ Claims lifecycle and financial controls

The lifecycle guide documents allowances, submission, payments, sampling, provider responses, amendments and clawbacks. The payment export is not the payer-response upload format. Validate files and reconcile async work before retries.

→ [Lifecycle, Mermaid state/sequence diagrams and contracts](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/claim-lifecycle.md)
→ [Regional funding](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/school_region_calulations.md)

---

## Run-books

### Local development setup

Use declared tools, a disposable local database and a Notify test key. The setup script copies the example environment file only when the local override is absent. It prepares the database and clears logs/tempfiles. The developer guide identifies focused tests and current interfaces where older convention examples have drifted.

→ [Developer onboarding](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/development.md)
→ [Setup script](https://github.com/DFE-Digital/itt-mentor-services/blob/main/bin/setup)
→ [Conventions](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/conventions.md)

### Support and infrastructure operations

Prefer the authorised support UI. Confirm environment, cluster, namespace, deployment and SHA before console/task access. School deactivation deletes claims and memberships; it is not a reversible account-disable operation.

→ [Support processes](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/operations.md)
→ [Azure console/task access](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/connect-to-azure.md)
→ [School deactivation](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/deactivate-school.md)
→ [Feature flags](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/feature-flags.md)

### ⚠ On-call procedures

Escalation creates a private Teams channel with membership decided for the incident. Production access is requested through the PM and activated through PIM.

> **Needs to be found.** Confirm any formal rota and out-of-hours authorisation. No support targets or rota were supplied at handover.

→ [Audit G1/G2](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)

---

## Incident management

### Incident process

Confirm environment and impact. Appoint an incident owner. Follow the platform incident playbook linked from the cheatsheet. Inspect health, logs, jobs and dependencies. Agree containment and recovery before changes. Verify business state and record the timeline before closing.

Maintenance mode controls web traffic, not all workers or external effects. Terraform deployment can overwrite maintenance routing.

→ [Incident cheatsheet and platform playbook link](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/incident-cheatsheet.md)
→ [Recovery checklist](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/disaster-recovery.md)

### ⚠ Recurring errors, communications and post-incident review

No recurring incidents were reported by the team. Higher-level communication and post-incident review guidance is stored externally. Diagnostic possibilities in the troubleshooting guide are not confirmed historical incidents.

> **Needs to be found.** Obtain the authoritative external guidance links and any applicable templates/update cadence. No independent review of live incident history was performed.

→ [Troubleshooting](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/troubleshooting.md)
→ [Audit G11](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)

---

## Troubleshooting

### Tools, common checks and resolutions

Start with read-only checks: host, SHA, database, jobs, request IDs and current records. The guide covers access, provider eligibility, training allowances, CSV validation, async updates, reference-data imports, notifications and replication. Establish prior side effects before replaying work.

→ [Troubleshooting guide](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/troubleshooting.md)
→ [Operational tools](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/operations.md)

---

## Disaster recovery

### Backup and restore mechanisms

The scheduled backup workflow targets production daily at 03:00 UTC. Manual logical restore, point-in-time restore and deleted-server recovery workflows exist. Production recovery inputs include confirmation guards. Verify the actual backup file and format rather than guessing from the restore default. Point-in-time recovery creates a new server and does not establish an automatic application cutover.

The team confirmed the daily backup schedule as 03:00 UTC, matching the checked workflow. Database-backed incomplete jobs may be restored with the selected database snapshot; safe replay is not guaranteed.

→ [Recovery guide and Mermaid decision flow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/disaster-recovery.md)
→ [Backup workflow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/database-backup.yml)
→ [Restore workflow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/postgres-restore.yml)
→ [Point-in-time workflow](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/workflows/postgres-ptr.yml)

### ⚠ Retention, recovery objectives and test evidence

The last DR exercise was reported as approximately autumn 2025, without available evidence. No RTO/RPO is agreed. There is no file-recovery plan. Secrets are held separately in Key Vault, but no secret-recovery guide is available. Recovery/reconciliation ownership is unconfirmed; the policy team was suggested, not assigned.

> **Needs to be found.** Verify successful backup runs, retention and DR exercise evidence. Assign recovery owners and establish file/secret recovery, cutover and reconciliation procedures. Blob soft-delete retention is not a complete backup policy.

Recovery must reconcile database state with files, restored jobs, payments, sent email and analytics. No recovery workflow was run to validate this documentation.

→ [Audit G5/G6](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)
→ [Storage configuration](https://github.com/DFE-Digital/itt-mentor-services/blob/main/terraform/application/storage_account.tf)

---

## Security

### Scanning, secrets and repository-visible controls

Dependabot schedules updates. Brakeman is available. The image-build action receives a Snyk token. Production configuration forces SSL and secure cookies. The runtime image uses a non-root user. Parameter filtering and private blob storage are configured. These observations are not a security assurance result.

The lead developer reviews vulnerability alerts and dependency updates. Automatic approval where possible is planned, not documented as active. The team reports annual accessibility audits and penetration testing; report links were not supplied.

Secrets belong in approved secret stores and ignored local overrides, never examples or diagrams.

→ [Security handover](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/security.md)
→ [Dependabot](https://github.com/DFE-Digital/itt-mentor-services/blob/main/.github/dependabot.yml)
→ [Environment-variable handling](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/environment-variables-in-azure.md)

### ⚠ SBOM, posture and data-sharing agreements

Retention/deletion and data-sharing documents are being developed, not supplied as approved. No remediation targets, access-review cadence or credential-rotation procedure was supplied as established.

> **Needs to be found.** Obtain SBOM evidence, scan outcomes and annual audit/test reports. Establish missing procedures and link governance documents once approved. Do not infer approval from a configured integration.

→ [Audit G7/G10](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)

### ✦ Handover acceptance and maintenance

The receiving team should demonstrate local setup, trace a claim, locate telemetry, explain deployment and rehearse recovery safely. Resolve or explicitly acknowledge the audit's open gaps. Repository documentation completion is separate from organisational acceptance.

The claims index assigns proposed owning roles and review triggers. Update guides and diagrams with changes to schema, routes, policies, jobs, integrations and infrastructure.

→ [Documentation index and maintenance map](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/README.md)
→ [Audit, evidence and open questions](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/claims/documentation-audit.md)
