require "capybara/rspec"
require "capybara-screenshot/rspec"

# Use different Capybara ports when running tests in parallel
if ENV["TEST_ENV_NUMBER"]
  Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
end

Capybara.always_include_port = true

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=1400,1400")
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  config.around(:each, type: :system, smoke_test: true) do |example|
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.run_server = false
    example.run
    Capybara.run_server = true
    Capybara.current_driver = Capybara.default_driver
  end

  config.before(:each, type: :system) do
    driven_by Capybara.current_driver
  end
end
