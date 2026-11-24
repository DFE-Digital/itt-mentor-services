# Incident Cheatsheet

## Incident Response

Stay calm and refer to the [incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html). This cheatsheet supplements the playbook with service-specific details.

1. Confirm the affected claims environment and current SHA. Record the symptoms and impact without exposing personal data.
2. Assign an incident owner and use the current incident playbook for severity, escalation and communication.
3. Check web/database health, workers, logs and dependencies using [claims operations](claims/operations.md).
4. Agree containment, recovery and verification before making changes.
5. Record the timeline, resolution and follow-up review. Obtain the current external communication/PIR guidance; its authoritative link is still outstanding in the [handover audit](claims/documentation-audit.md#team-input-register).

The team reports this escalation practice: create a new private Teams channel for the incident and decide its membership at that point. The [CFMT Development alert channel and monitoring entry points](claims/operations.md#health-and-telemetry) are documented separately. Alert delivery to that development channel has been tested by the team. No formal on-call rota or support targets were supplied.

## Maintenance Page

To stop users accessing the app, [enable the maintenance page](https://github.com/DFE-Digital/itt-mentor-services/actions/workflows/maintenance.yml).

The workflow offers staging and production. Confirm target, approval and mode before dispatch. Maintenance controls web traffic; it does not prove workers, scheduled imports or notifications have stopped.

### Temporary Ingress URL

After enabling maintenance, obtain the claims temporary ingress URL from the action's output for that environment. Use it for approved health/SHA checks and verification. Do not assume the public URL will reach the application while maintenance is enabled.

### Terraform File

The web application module currently sets `send_traffic_to_maintenance_page = false` in [application Terraform](../terraform/application/application.tf). A deployment can therefore overwrite operational maintenance state. If maintenance must persist through deployment, coordinate the approved Terraform change with platform operators and verify routing after apply. Do not change the setting or redeploy casually during an incident.

### Maintenance Page HTML

The claims maintenance page is [claim-funding-for-mentor-training](../maintenance_page/html/claim-funding-for-mentor-training.html).

Before disabling maintenance, verify the intended release, database health, access, read-only claims journeys and worker state. Use [deployment](claims/deployment.md) or [disaster recovery](claims/disaster-recovery.md) for the applicable checklist.

## Current Deployment SHA Ref

To find the SHA ref of the current deployment, check the health check endpoint at `/healthcheck/sha`. Use the temporary ingress URL if the maintenance page is enabled. The SHA ref is listed under the "sha" label.
