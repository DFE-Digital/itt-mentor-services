# Rails Active Job

We use Rails [Active Job](https://guides.rubyonrails.org/active_job_basics.html) to process asynchronous workloads. Active Job supports various backends, or 'queue adapters', to execute jobs. We use one called [GoodJob](https://github.com/bensheldon/good_job). GoodJob is similar to the more widely used [Sidekiq](https://github.com/sidekiq/sidekiq), except it uses the existing Postgres database rather than requiring a Redis instance. This means we can keep our stack leaner and save on cloud infrastructure costs.

## Admin dashboard

You can access the GoodJob admin dashboard at the path `/good_job`.

| Service           | Environment | URL                                                                     |
| ----------------- | ----------- | ----------------------------------------------------------------------- |
| School Placements | QA          | https://manage-school-placements-qa.test.teacherservices.cloud/good_job |
| Track & Pay       | QA          | https://track-and-pay-qa.test.teacherservices.cloud/good_job            |

> [!IMPORTANT]  
> You must be signed in as a support user. Regular users cannot access the dashboard.

> [!NOTE]  
> Both services run from a single Rails app and database, so the job queues are shared. Both dashboards will show the same information.

From the dashboard, you can see jobs that have been queued and their status. Click in to an individual job to see more details, including its arguments and how long it took to run.

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

This is handy if you want to debug a job that usually runs out of business hours, without having to adjust the schedule and re-deploy the config file.

### Pausing a schedule

To pause a schedule, click the ⏸️ icon against the cron schedule in the admin dashboard.
