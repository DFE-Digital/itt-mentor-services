ENV["RAILS_ENV"] ||= "test"

require "selenium/webdriver"
require "support/capybara"

RSpec.configure do |config|
  config.around(:each, :smoke_test, type: :system) do |example|
    service = self.class.metadata[:service]

    Capybara.current_driver = Capybara.javascript_driver
    Capybara.run_server = false
    Capybara.app_host = "http://#{service_external_host(service)}"

    example.run

    Capybara.app_host = nil
    Capybara.run_server = true
    Capybara.current_driver = Capybara.default_driver
  end

  private

  def service_external_host(service)
    case service.to_s
    when "claims"
      ENV["CLAIMS_EXTERNAL_HOST"]
    when "placements"
      ENV["PLACEMENTS_EXTERNAL_HOST"]
    end
  end
end
