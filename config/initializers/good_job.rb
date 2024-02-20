# Configure GoodJob, an Active Job adapter backed by the Postgres database
# More details at: https://github.com/bensheldon/good_job

Rails.application.configure do
  # In development, execute jobs within the main `rails server` process
  config.good_job.execution_mode = :async if Rails.env.development?

  # In production, execute jobs in a separate worker process (i.e. `good_job start`)
  config.good_job.execution_mode = :external if Rails.env.production?

  # Read scheduled jobs from config file
  scheduled_jobs = YAML.load_file(
    Rails.root.join("config/scheduled_jobs.yml"),
    symbolize_names: true,
  )

  # Enable cron when running in production mode
  # Disabled in development and test so scheduled jobs don't run automatically
  config.good_job.enable_cron = Rails.env.production?
  config.good_job.cron = scheduled_jobs || {}
end
