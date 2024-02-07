Sentry.init do |config|
  # Sentry config here is mostly copied from apply-for-teacher-training
  # https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/config/initializers/sentry.rb
  config.environment = ActiveSupport::EnvironmentInquirer.new(ENV.fetch("HOSTING_ENV", "development"))
  config.release = ENV["SHA"]
  config.dsn = ENV.fetch("SENTRY_DSN", "")

  config.inspect_exception_causes_for_exclusion = true

  config.excluded_exceptions += [
    # Google cloud (ie Bigquery) errors are usually caused by transient network
    # issues. If there's a genuine problem the queues will stack up and the Sidekiq
    # latency check will alert. That takes at most 100 seconds to happen, so if
    # something is actually wrong it's not meaningfully less useful than hearing about
    # it via Sentry.
    "Google::Cloud::Error",
  ]
end
