# Connect to an instance running in Azure

This Rails app runs on the [Teacher Services Cloud](https://github.com/DFE-Digital/teacher-services-cloud) Kubernetes infrastructure in Azure.

Follow these instructions to [run a Rake task](#run-a-rake-task) or [open a Rails console](#open-a-rails-console).

> [!NOTE]
> The commands below target **QA on the test cluster**. Production and sandbox use the production cluster; staging also has its own namespace. See the [environment inventory](claims/deployment.md#environment-inventory).
>
> Request production access through the service PM and activate it through Azure Privileged Identity Management (PIM). Confirm permissions and change/incident approval before using a console or executing tasks. Do not copy QA commands into another environment without checking cluster, namespace and deployment.

## 1. Authenticate to the Kubernetes cluster

You'll need to configure your command line console so it can connect to the Kubernetes cluster. Your authenticated state should persist for several days, but you may need to re-authenticate every once in a while.

1. Login to the [Microsoft Azure portal](https://portal.azure.com)

   > Use your `@digitalauth.education.gov.uk` account.
   >
   > Make sure it says "DfE Platform Identity" in the top right corner of the screen below your name. If not, click the settings/cog icon and choose it from the list of directories.

2. Open a console. Navigate to the `itt-mentor-services` repo directory and run:

   ```
   $ az login
   ```

   > If you have trouble logging in, try switching browser. Chrome is known to be buggy with this step, so copy & paste the URL into Safari instead.
   >
   > Otherwise you might have more success with this command:
   >
   > ```
   > $ az login --use-device-code
   > ```

3. Then run:

   ```
   $ make qa get-cluster-credentials
   ```

4. Assuming everything worked correctly, you should now be able to access the Kubernetes cluster using the `kubectl` command.

   > You can test you have access by running this command:
   >
   > ```
   > kubectl -n bat-qa get deployments
   > ```
   >
   > You should see a list of Kubernetes deployments. If you don't, something is wrong.

## 2. Get the Kubernetes Deployment name

Before selecting a deployment, check the current context:

```sh
kubectl config current-context
kubectl -n bat-qa get deployments
```

Confirm these match the intended QA cluster and deployment. Stop if they do not. Sandbox and production share a namespace, so namespace alone is not sufficient identification.

Multiple instances of the app run on the `test` cluster. There's one for the QA environment, and one for each Pull Request that has a `deploy` label. Each one is a Kubernetes [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) resource.

To connect to the **QA environment**, the deployment name is:

```
itt-mentor-services-qa
```

To connect to a **review app**, the deployment is named after the PR number:

```
itt-mentor-services-[PR_NUMBER]
```

For example, PR #123 would be `itt-mentor-services-123`.

> [!TIP]
> For a list of all active deployments, run:
>
> ```
> $ kubectl -n bat-qa get deployments
> ```
>
> This will include other BAT apps because they all run in the same [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).

## 3. Connect to a running container

These commands will connect to the QA environment. Change the deployment name accordingly for PR review apps.

### Open a Rails console

An interactive console can modify data and send notifications. Prefer read-only diagnostics. For approved writes, record the target, expected impact and verification/reversal plan.

Open an interactive Rails console using this command:

```
$ kubectl -n bat-qa exec -it deployment/itt-mentor-services-qa -- rails console
```

### Open a shell console

Open an interactive Linux shell using this command:

```
$ kubectl -n bat-qa exec -it deployment/itt-mentor-services-qa -- sh
```

### Run a Rake task

Inspect the task and obtain approval for its side effects first. Do not run imports, deletion tasks or financial jobs simply to test connectivity.

Run Rake tasks using this command:

```
$ kubectl -n bat-qa exec -it deployment/itt-mentor-services-qa -- rake [TASK_TO_RUN]
```

Or list all available Rake tasks with:

```
$ kubectl -n bat-qa exec -it deployment/itt-mentor-services-qa -- rake -T
```

# Useful links

- [Teacher Services Cloud documentation](https://github.com/DFE-Digital/teacher-services-cloud/tree/main/documentation)
- [Developer onboarding](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/developer-onboarding.md) for the Teacher Services Cloud
- If in doubt, ask in the [#teacher-services-infra](https://ukgovernmentdfe.slack.com/archives/C011EM7HU85) Slack channel
