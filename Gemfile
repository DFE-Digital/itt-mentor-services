source "https://rubygems.org"
git_source(:github) { |_repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.1.2"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

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

gem "flipflop"
gem "redcarpet", "~> 3.6"

gem "govuk-components", "~> 5.0.1"
gem "govuk_design_system_formbuilder", "~> 5.0.0"

# DfE Sign-in
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"

# Decorators
gem "draper"

# Download files safely
gem "down", "~> 5.0"

# HTTP Request
gem "httparty"

gem "pg_search"

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
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "capybara-screenshot"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  # launch browser when inspecting capybara specs
  gem "launchy"
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
