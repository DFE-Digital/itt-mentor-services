# Rails Active Job

We use Rails [Active Job](https://guides.rubyonrails.org/active_job_basics.html) to process asynchronous workloads. Active Job supports various backends, or 'queue adapters', to execute jobs. We use one called [GoodJob](https://github.com/bensheldon/good_job). GoodJob is similar to the more widely used [Sidekiq](https://github.com/sidekiq/sidekiq), except it uses the existing Postgres database rather than requiring a Redis instance. This means we can keep our stack leaner and save on cloud infrastructure costs.

## Admin dashboard

You can access the GoodJob admin dashboard at `/good_job` on the intended claims environment host. Use the [environment inventory](claims/deployment.md#environment-inventory) or the deployment workflow output, rather than a historical ingress URL.

> [!IMPORTANT]  
> You must be signed in as a support user. Regular users cannot access the dashboard.

> [!NOTE]  
> Jobs use the application's Postgres database. Shared and service-specific jobs can appear together. Always confirm the environment before changing job state.

From the dashboard, you can see jobs that have been queued and their status. Click in to an individual job to see more details, including its arguments and how long it took to run.

See [claims operations](claims/operations.md#jobs-and-queues) for the schedule inventory and safe retry checks. Development runs jobs in-process; production Rails mode uses external workers and enables cron. This includes hosted non-production environments using the production image. See [GoodJob configuration](../config/initializers/good_job.rb).

## Scheduled jobs (cron)

Some jobs need to run on a regular schedule – for example, to perform routine maintenance, or sync with external data sources. GoodJob supports scheduled jobs out of the box.

Scheduled jobs are configured in [config/scheduled_jobs.yml](/config/scheduled_jobs.yml), in the following format:

```yaml
name-of-job:
  cron: "* * * * * *"
  class: NameOfAJob
  description: Description is shown in the GoodJob dashboard.
```

Read the [GoodJob documentation](https://github.com/bensheldon/good_job?tab=readme-ov-file#cron-style-repeatingrecurring-jobs) for details of all supported config keys.

### Manually running a scheduled job

You can manually trigger a scheduled job by heading to the "Cron" section of the admin dashboard and clicking the ⏭️ icon next to the job.

Before triggering it, confirm permissions, environment and side effects. Financial exports, imports and email jobs are not guaranteed safe to replay. Inspect existing job results and business activity first.

This is handy if you want to debug a job that usually runs out of business hours, without having to adjust the schedule and re-deploy the config file.

### Pausing a schedule

To pause a schedule, click the ⏸️ icon against the cron schedule in the admin dashboard.

This does not cancel already-enqueued or running jobs. Record the previous state and verify both the queue and schedule when resuming.
