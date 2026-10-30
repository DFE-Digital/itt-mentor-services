# Claim funding for mentor training documentation

This index covers claims and its shared dependencies. Placements-only behaviour is outside this handover.

## New developer reading order

1. [Developer onboarding and testing](development.md)
2. [Architecture and code map](architecture.md)
3. [Data model, ERDs and dictionary](data-model.md)
4. [Claim lifecycle, business rules and financial files](claim-lifecycle.md)
5. [API reference](api.md) and [integration register](integrations.md)
6. [Architecture decision records](../../adr/README.md) and [coding conventions](../conventions.md)

## Run-state and incident shortcuts

- [Handover document](../../handover-document.md)
- [Environments, deployment and rollback boundaries](deployment.md)
- [Operations, monitoring, jobs and support tasks](operations.md)
- [Incident cheatsheet](../incident-cheatsheet.md)
- [Disaster recovery and required evidence](disaster-recovery.md)
- [Security, authentication and access](security.md)
- [Troubleshooting](troubleshooting.md)
- [Azure connection](../connect-to-azure.md), [environment variables](../environment-variables-in-azure.md), [feature flags](../feature-flags.md), [school deactivation](../deactivate-school.md)
- [School region calculations](school_region_calulations.md)
- [Forecast and clawback reporting](forecast-reporting.md)
- [Documentation audit and team-input gaps](documentation-audit.md)

## Maintaining this pack

All diagrams are fenced Mermaid in Markdown. Update diagrams and prose with the implementation they describe. Link to manifests for runtime versions and to source for contracts; do not duplicate secrets, personal data or operational policy.

Analytics ownership by the Analytics team and reporting ownership by developers were confirmed during handover. Other proposed document-owning roles below still need confirmation. They are not assignments to named individuals.

| Guides | Proposed owner | Review trigger |
| --- | --- | --- |
| Architecture, data model, lifecycle, APIs, ADR index | Technical lead / developers | Route, schema, policy, workflow or architectural decision changes |
| Analytics and reporting | Analytics team (analytics); developers (reporting) | Data flow or reporting changes |
| Other integrations | Owner to confirm | API, credentials or integration changes |
| Development and conventions | Developers | Setup, toolchain or test changes |
| Deployment, operations, incident, recovery and troubleshooting | Platform / operations / technical lead | Workflow, infrastructure, alert, incident or recovery changes |
| Security | Technical lead / security / information governance | Identity, permissions, data sharing, retention or scanning changes |
| Handover and audit | Service owner / receiving team | Ownership changes, resolved evidence gaps and readiness review |
