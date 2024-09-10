# Incident Cheatsheet

## Incident Response

Stay calm and refer to the [incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html). This cheatsheet supplements the playbook with service-specific details.

## Maintenance Page

### Temporary Ingress URL

After enabling the maintenance page, use the temporary ingress URL to access the environment for tasks like health checks or verifying code deployments. Find the URL in the "Enable maintenance app summary" section of the GitHub action under TEMP URLS for both the claims and placements services.

### Terraform File

The `application.tf` file is in the root of the repository. Update the `send_traffic_to_maintenance_page` variable to `true` to persist the maintenance page between deployments. Missing this step will disable the maintenance page unintentionally.

### Maintenance Page HTML

The `maintenance_page.html` file is in the `maintenance_page/html` directory. This file is displayed when the maintenance page is enabled.

## Current Deployment SHA Ref

To find the SHA ref of the current deployment, check the health check endpoint at `/healthcheck/all` from the temporary ingress URL. The SHA ref is listed under the "commit SHA" label.
