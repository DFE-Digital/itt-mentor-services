# Incident Cheatsheet

## Incident Response

Stay calm and refer to the [incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html). This cheatsheet supplements the playbook with service-specific details.

## Maintenance Page

To stop users accessing the app, [enable the maintenance page](https://github.com/DFE-Digital/itt-mentor-services/actions/workflows/enable-maintenance.yml).

### Temporary Ingress URL

After enabling the maintenance page, use the temporary ingress URL to access the environment for tasks like health checks or verifying code deployments. Find the URL in the "Enable maintenance app summary" section of the GitHub action under TEMP URLS for both the claims and placements services.

### Terraform File

The `application.tf` file is located at [terraform/application/application.tf](/terraform/application/application.tf). Update the [`send_traffic_to_maintenance_page` variable to `true`](https://github.com/DFE-Digital/itt-mentor-services/blob/1d1d321cd90f33b94f1485c7e49acea9267d9e33/terraform/application/application.tf#L125) to persist the maintenance page between deployments. Missing this step will disable the maintenance page unintentionally when deploying new releases.

### Maintenance Page HTML

The maintenance page is located at [maintenance_page/html/index.html](/maintenance_page/html/index.html). This file is displayed when the maintenance page is enabled.

## Current Deployment SHA Ref

To find the SHA ref of the current deployment, check the health check endpoint at `/healthcheck/sha`. Use the temporary ingress URL if the maintenance page is enabled. The SHA ref is listed under the "sha" label.
