require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IttMentorServices
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.assets.paths << Rails.root.join(
      "node_modules/govuk-frontend/dist/govuk/assets",
    )

    config.action_mailer.show_previews = true
    config.action_mailer.preview_paths << Rails.root.join("spec/mailers/previews").to_s

    config.view_component.preview_paths << Rails.root.join("spec/components/previews").to_s
    config.view_component.default_preview_layout = "component_preview"

    config.autoload_paths += %W[#{config.root}/app/assets/components]
    config.exceptions_app = routes

    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]

    config.skylight.probes << "active_job"

    # Store user sessions in the database
    config.session_store :active_record_store

    # Configure message verifiers to generate URL-safe tokens.
    config.before_initialize do |app|
      app.message_verifiers.clear_rotations
      app.message_verifiers.rotate(url_safe: true)
    end
  end
end
