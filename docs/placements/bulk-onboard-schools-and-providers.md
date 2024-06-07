# Bulk onboard schools and providers

You can bulk onboard schools and providers using a CSV import. This will onboard organisations into the service and set up their first user account.

1. Authenticate to the Kubernetes cluster

   [Follow the steps in this guide](https://github.com/DFE-Digital/itt-mentor-services/blob/main/docs/connect-to-azure.md#1-authenticate-to-the-kubernetes-cluster)

2. Get the pod name

   Assuming you're trying to connect to the staging environment, you'll need to get pod names for the app `itt-mentor-services-staging`:

   ```
   kubectl -n bat-staging get pods -l app=itt-mentor-services-staging
   ```

   Keep a copy of this pod name. You'll need it in the next steps.

   ```
   export POD_NAME=$(kubectl -n bat-staging get pods -l app=itt-mentor-services-staging -o jsonpath="{.items[0].metadata.name}")
   ```

3. Copy the CSV file up to the container

   ```
   kubectl -n bat-staging cp ~/path/to/schools.csv $POD_NAME:/app/tmp/
   ```

4. Open a `sh` shell on the container

   ```
   kubectl -n bat-staging exec -ti $POD_NAME -- sh
   ```

   You should be able to see the file you copied up:

   ```
   ls /app/tmp
   ```

5. Open a Rails console and run the importer

   Using the `sh` shell you already have open, run:

   ```
   rails console
   ```

   Then run the importer:

   ```ruby
   Placements::Importers::SchoolUsersImporter.call("/app/tmp/schools.csv")
   ```
