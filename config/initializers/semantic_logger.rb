if Rails.env.development? || Rails.env.production?
  Rails.application.configure do
    # Prepend all log lines with the following tags
    # config.log_tags = {
    #   request_id: :request_id,
    #   some_other_tag: "some other value",
    # }
    config.log_tags = [
      :request_id,
      "from semantic_logger.rb",
    ]
  end

  SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
  Rails.application.config.logger.info("Application logging to STDOUT")
end
