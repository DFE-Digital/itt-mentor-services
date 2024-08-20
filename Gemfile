source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.1.3"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

gem "amazing_print"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# https://www.skylight.io/ -- for monitoring performance
gem "skylight"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build reusable view components [https://viewcomponent.org]
gem "view_component"

# GOV.UK Notify
gem "mail-notify"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

gem "csv"

gem "flipflop"

# Markdown
gem "govuk_markdown"
gem "redcarpet", "~> 3.6"

# GoodJob backend for Active Job
gem "good_job", "~> 4.1"

# Store user sessions in the database
gem "activerecord-session_store"

gem "govuk-components", "~> 5.4.1"
gem "govuk_design_system_formbuilder", "~> 5.5"

# DfE Sign-in
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"

# Pagination
gem "pagy", "~> 8.6"

# Decorators
gem "draper"

# Download files safely
gem "down", "~> 5.4"

# HTTP Request
gem "httparty"

gem "money-rails", "~> 1.12"

gem "pg_search"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# User-Resource Permissions and Scoping
gem "pundit"

gem "sentry-rails"

# Soft deletion
gem "discard"

# Geocoding
gem "geocoder"

# Audit trail
gem "audited"

# BigQuery
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.14.0"

# Migrations
gem "strong_migrations"

# Data Migrate [https://github.com/ilyakatz/data-migrate]
gem "data_migrate", "9.4.2"

# OK Computer [https://github.com/sportngin/okcomputer]
gem "okcomputer"

group :development do
  gem "annotate", require: false
  gem "prettier_print", require: false
  gem "rladr"
  gem "rubocop-govuk", require: false
  gem "solargraph", require: false
  gem "solargraph-rails", require: false
  gem "syntax_tree", require: false
  gem "syntax_tree-haml", require: false
  gem "syntax_tree-rbs", require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "rails-erd"
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

group :test do
  # Return null object for active record connection rather than raising error
  gem "activerecord-nulldb-adapter"
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  # The accessible selectors gem is maintained by Citizens Advice, not yet a registered gem.
  gem "capybara_accessible_selectors", git: "https://github.com/citizensadvice/capybara_accessible_selectors", branch: "main"
  gem "capybara-screenshot"
  gem "climate_control"
  gem "rails-controller-testing"
  gem "rspec-retry", git: "https://github.com/DFE-Digital/rspec-retry.git", branch: "main"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  # launch browser when inspecting capybara specs
  gem "launchy"
  gem "timecop"
  gem "undercover"
  gem "webmock"
end

group :test, :development do
  gem "better_html"
  gem "brakeman"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec"
  gem "rspec-rails"
end

group :development, :production do
  # Semantic logger
  gem "rails_semantic_logger"
end
