# Documentation audit and handover gaps

[Claims documentation](README.md)

Scope: Claim funding for mentor training, including the shared application and infrastructure it uses. This is a repository-based audit. It is not evidence that a deployment, alert, backup or recovery procedure has worked in a live environment.

## Documentation inventory

The shared and claims guides and all eleven existing ADRs were read. Placements-only documentation is outside this handover.

| Topic / existing material | Audit finding | Action / canonical destination |
| --- | --- | --- |
| [Root README](../../README.md) | Partial; local environment-file guidance differed from the setup script | Correct setup guidance; link the claims index |
| [Claims index](README.md) | Previously linked only to regional funding calculations | Expand into the documentation map |
| [Shared data model](../data-model.md) | Historical draft; claims states, provider access and eligibility descriptions have drifted | Label as historical; use [claims data model](data-model.md) |
| [Regional funding](school_region_calulations.md) | Formula still exists; worked example and field references needed correction | Link the current calculation and explain units |
| [Conventions](../conventions.md) and its five linked guides | Useful design guidance; simplified examples are not all current APIs | Retain; [development](development.md) identifies source-of-truth classes and example drift |
| [ADRs](../../adr/README.md) | Existing rationale is valuable; not every record describes current claims implementation | Add an applicability index, retain historical records |
| [Active Job](../active-job.md) | GoodJob guidance exists; old dashboard URLs and two-service framing were stale | Refresh shared guide; [operations](operations.md) inventories jobs |
| [Azure connection](../connect-to-azure.md) | Said production did not exist | Correct scope; add environment checks and production cautions |
| [Environment variables](../environment-variables-in-azure.md) | Existing Key Vault and non-secret configuration instructions | Retain and qualify access approvals and redeployment guidance |
| [Incident cheatsheet](../incident-cheatsheet.md) | Existing maintenance and SHA guidance; old Terraform line link | Update claims maintenance guidance and link current source |
| [Feature flags](../feature-flags.md) | Refers to unspecified rake tasks; support-only UI exists | Document the UI and guard against unsafe example targeting |
| [Deactivate school](../deactivate-school.md) | Destructive helper is documented; connection link was wrong | Fix link; add approval, impact and verification safeguards |
| [Placements onboarding](../placements/bulk-onboard-schools-and-providers.md) | Placements-only | Preserve; not the claims onboarding procedure |
| Architecture and lifecycle | No consolidated claims reference | Create [architecture](architecture.md) and [lifecycle](claim-lifecycle.md) |
| HTTP and batch contracts | No consolidated API reference | Create [API](api.md) and [integrations](integrations.md) |
| Deployment, recovery, security and troubleshooting | Scattered configuration and workflows, not a complete handover | Create focused guides; preserve unknowns below |

## Evidence register

| Claim | Primary evidence | Supporting evidence |
| --- | --- | --- |
| Claims entry points and host routing | [routes](../../config/routes.rb), [claims routes](../../config/routes/claims.rb) | [hosting environment](../../lib/hosting_environment.rb) |
| School, provider and support identities | [DfESignInUser](../../app/models/dfe_sign_in_user.rb) | [claims user models](../../app/models/claims/), [policies](../../app/policies/claims/) |
| Physical schema and logical associations | [schema](../../db/schema.rb) | [claims models](../../app/models/claims/) |
| Submission behaviour | [Submit](../../app/services/claims/claim/submit.rb) | [submission spec](../../spec/services/claims/claim/submit_spec.rb) |
| Training rules | [TrainingAllowance](../../app/models/claims/training_allowance.rb), [TrainingHours](../../app/models/claims/training_hours.rb) | [allowance spec](../../spec/models/claims/training_allowance_spec.rb), [hours spec](../../spec/models/claims/training_hours_spec.rb) |
| Provider suggestions and year eligibility | [controller](../../app/controllers/api/provider_suggestions_controller.rb) | [request spec](../../spec/requests/api/provider_suggestions_spec.rb) |
| Payment outcomes | [payer-response job](../../app/jobs/claims/payment/update_claim_with_payer_response_job.rb) | [job spec](../../spec/jobs/claims/payment/update_claim_with_payer_response_job_spec.rb) |
| Runtime, storage and deployment | [application Terraform](../../terraform/application/application.tf), [storage](../../terraform/application/storage_account.tf) | [deployment workflow](../../.github/workflows/build_and_deploy.yml), [deployment action](../../.github/actions/deploy-environment/action.yml) |
| Scheduled tasks and telemetry | [schedule](../../config/scheduled_jobs.yml), [GoodJob](../../config/initializers/good_job.rb) | [Sentry](../../config/initializers/sentry.rb), [StatusCake](../../terraform/application/statuscake.tf) |
| Recovery mechanisms | [backup](../../.github/workflows/database-backup.yml), [restore](../../.github/workflows/postgres-restore.yml), [point-in-time restore](../../.github/workflows/postgres-ptr.yml) | [database Terraform](../../terraform/application/database.tf) |

Specs are linked evidence of intended behaviour, not a statement that they were run for this documentation change.

## Team-input register

The operational answers below were supplied during the handover interview on 29 October 2026. **Recorded** means the current practice or absence of a process is documented, not that a live control was independently tested. **Partial**, **pending** and **open** entries still need follow-up.

| ID | Priority | Status | Answer recorded | Remaining evidence / role to confirm |
| --- | --- | --- | --- | --- |
| G1 | P0 | Partial | Request production access through the service PM, then activate through Azure PIM. PR changes require a review environment, product review and approval from a second developer; any other developer can review. Merge is manual, with no further manual approval reported. | Out-of-hours authorisation and access-review arrangements remain unconfirmed; PM / platform |
| G2 | P0 | Partial | Alerts go to the CFMT Development Teams channel and delivery has been tested by the team. Sentry and Skylight entry points are supplied in [operations](operations.md). StatusCake is used for monitoring; the team also reports CI health checks. | Application-log and StatusCake dashboard links, thresholds and any formal rota remain unspecified. Post-apply CI checks must not be described as a pre-deploy guarantee. |
| G3 | P0 | Recorded absence | No formal service commitments, support hours or SLA/SLO targets were supplied as agreed. | Service owner to establish commitments if required |
| G4 | P0 | Partial | PR revert is the team's rollback approach. No manual gate follows merge. Clarified safeguard: Terraform/Kubernetes setup or smoke-test failures stop the deployment job and further promotion; non-production failures block production. Applied changes are not automatically undone, including after production smoke-test failures. | Test/deploy workflows are separate. Verify actual blocking checks, rollout safeguards, migration rollback handling, freeze periods and rehearsal evidence; technical lead / platform |
| G5 | P0 | Partial | Team confirmed daily backups are scheduled for 03:00 UTC, matching the checked workflow, and recalls a DR exercise around autumn 2025, with no evidence available. No RTO or RPO is agreed. | Confirm successful backup runs, database/PITR retention and test evidence; platform / service owner |
| G6 | P0 | Recorded gaps | Jobs are database-backed. Secrets are held separately in Key Vault. No file-recovery plan or secret-recovery guide exists at handover. | Recovery/reconciliation ownership is unconfirmed; policy team was suggested, not assigned. Confirm platform responsibilities, file recovery and financial reconciliation. |
| G7 | P0 | Pending | Retention, deletion and data-sharing policies/agreements are being developed; none supplied as approved. | Information governance / service owner to provide approved documents |
| G8 | P1 | Recorded | Canonical production sign-in is `https://claim-funding-for-itt-mentor-training.service.gov.uk/sign-in`. The former `education.gov.uk` address is not a supported alias. | Environment URLs now follow checked configuration. Legacy redirects remain in domain Terraform; platform must reconcile their intended status without assuming support. |
| G9 | P1 | Partial / pending | Register supplies eligibility data by manual request. Policy sets claim windows and the other financial-process dates. A multi-year calendar is being agreed. | Agreed dates, file owners, response formats, duplicate handling and reconciliation controls remain outstanding; policy / claims operations |
| G10 | P1 | Partial / recorded gaps | Lead developer reviews vulnerability alerts/dependency updates. Automatic approval where possible is planned, not current policy. Accessibility audits and penetration testing take place annually, as reported by the team. No other listed assurance procedures were supplied as established. | Audit/test reports and links, SBOM availability and scan outcomes remain unverified. Remediation targets, access reviews and credential-rotation procedures are not established. |
| G11 | P1 | Partial | No recurring incidents reported. Escalation creates a private Teams channel with membership decided for the incident. Higher-level incident communication/PIR guidance is stored externally. | Obtain the authoritative external guidance links; formal rota/support arrangements remain unspecified |
| G12 | P1 | Open | Rationale for GoodJob, analytics replication and financial CSV choices is unknown to the current respondent. | Outgoing decision makers or historical evidence needed; do not invent retrospective ADR rationale |

Analytics is owned by the Analytics team; reporting is owned by developers. Owners for other integrations remain to be confirmed.

Do not copy personal contact details, real CSVs, tokens or private incident material into this public repository.

## Validation and sign-off

Recording the interview answers does not establish missing controls or close the remaining evidence gaps. The new team should walk through [development](development.md), identify a claim and its lifecycle, locate monitoring, explain deployment and rehearse recovery in an approved non-production environment.

Documentation checks cover local links, diagram rendering and source comparisons. Live access, fresh-machine boot, deployment, alerts and disaster recovery still need operational validation. Do not execute destructive procedures merely to check the documentation.

### Checks performed for this pack

- Local and repository-source links and Markdown anchors were checked against this checkout.
- All Mermaid blocks in the changed documents were rendered locally with a session-only Mermaid CLI. New diagrams were visually inspected. No diagram contents were sent to an external renderer.
- The handover was checked for all ten template sections and for accidental pinned runtime versions.
- `git diff --check` was run to check patch whitespace.
- No application, dependency, infrastructure or CI configuration was changed.
- Rails tests, local setup, live access, deployment, backup/restore and alert exercises were not run for these documentation-only changes. Setup and operational exercises can mutate data, logs or external systems; they remain explicit receiving-team acceptance steps.

## Maintenance

The owning roles in the [claims index](README.md) are proposals for confirmation at handover. Review documents when their linked routes, schema, policies, jobs, integrations or infrastructure change. Update the diagram and prose together.
