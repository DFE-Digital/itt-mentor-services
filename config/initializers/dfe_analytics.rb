ALLOWED_ENVS = %w[production qa sandbox staging].freeze
DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  # config.log_only = true

  # Whether to use ActiveJob or dispatch events immediately.
  #
  # config.async = true

  # Which ActiveJob queue to put events on
  #
  config.queue = :dfe_analytics

  # The name of the BigQuery table we’re writing to.
  #
  # config.bigquery_table_name = ENV['BIGQUERY_TABLE_NAME']

  # The name of the BigQuery project we’re writing to.
  #
  # config.bigquery_project_id = ENV['BIGQUERY_PROJECT_ID']

  # The name of the BigQuery dataset we're writing to.
  #
  # config.bigquery_dataset = ENV['BIGQUERY_DATASET']

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  # config.bigquery_api_json_key = ENV['BIGQUERY_API_JSON_KEY']

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  config.enable_analytics = proc { ALLOWED_ENVS.include?(ENV.fetch("HOSTING_ENV", "development")) }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  # config.environment = ENV.fetch('RAILS_ENV', 'development')

  # A proc which will be called with the user object, and which should
  # return the identifier for the user. This is useful for systems with
  # users that don't use the id field.
  #
  # config.user_identifier = proc { |user| user&.id }

  # Whether to pseudonymise the user_id field in the web request event.
  #
  # config.pseudonymise_web_request_user_id = false

  # Whether to run entity table checksum job.
  #
  config.entity_table_checks_enabled = true

  # A proc which will be called with the rack env, and which should
  # return a boolean indicating whether the page is cached and will
  # be served by rack middleware.
  #
  # config.rack_page_cached = proc { |_rack_env| false }

  # Schedule a maintenance window during which no events are streamed to BigQuery
  # in the format of '22-01-2024 19:30..22-01-2024 20:30' (UTC).
  #
  # config.bigquery_maintenance_window = ENV['BIGQUERY_MAINTENANCE_WINDOW']

  # Whether to use azure workload identity federation for authentication
  # instead of the BigQuery API JSON Key. Note that this also will also
  # use a new version of the BigQuery streaming APIs.
  config.azure_federated_auth = true
end
