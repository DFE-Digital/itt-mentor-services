module GovukComponentMatchers
  extend RSpec::Matchers::DSL

  matcher :have_summary_list_row do |expected_key, expected_value|
    match do |page|
      key = page.find(".govuk-summary-list__key", text: expected_key)
      row = key.find(:xpath, "..", class: "govuk-summary-list__row")
      row.find(".govuk-summary-list__value", text: expected_value)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_h1 do |text|
    match do |page|
      page.find("h1[class^='govuk-heading-']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_h2 do |text|
    match do |page|
      page.find("h2[class^='govuk-heading-']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_h3 do |text|
    match do |page|
      page.find("h3[class^='govuk-heading-']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_success_banner do |text|
    match do |page|
      within ".govuk-notification-banner.govuk-notification-banner--success" do
        page.find(".govuk-notification-banner__title", text: "Success")
        page.find(".govuk-notification-banner__heading", text:)
        true
      rescue Capybara::ElementNotFound
        false
      end
    end
  end

  matcher :have_validation_error do |text|
    match do |page|
      within ".govuk-error-summary" do
        page.find(".govuk-error-summary__title", text: "There is a problem")
        page.find(".govuk-error-summary__list a", text:)
      end
      page.find(".govuk-error-message", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  def primary_navigation
    page.find(".app-primary-navigation")
  end

  def secondary_navigation
    page.find(".app-secondary-navigation")
  end

  # Usage: expect(primary_navigation).to have_current_item("Schools")
  matcher :have_current_item do |text|
    match do |page|
      page.find("a[aria-current='page']", text:)

      # assert there is only one current nav item
      page.all("a[aria-current='page']", count: 1)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end
end
