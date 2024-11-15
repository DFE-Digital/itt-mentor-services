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

  matcher :have_result_detail_row do |expected_key, expected_value|
    match do |page|
      key = page.find(".app-result-detail__key", text: expected_key)
      row = key.find(:xpath, "..", class: "app-result-detail__row")
      row.find(".app-result-detail__value", text: expected_value)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  #
  # Asserts a table row exists with all of the specified column names and values.
  #
  # Example usage:
  #
  #   expect(page).to have_table_row({
  #     "Name" => "Joe Bloggs",
  #     "Email address" => "joe.bloggs@example.com",
  #   })
  #
  # Things to note:
  #
  #  - The order of columns within the table does not matter.
  #  - The table row may contain additional columns. This isn't an exclusive matcher.
  #  - This matcher simply asserts that all the expected column names and values
  #    exist within a single table row.
  #
  matcher :have_table_row do |expected_row|
    match do |page|
      all_rows = page.all("tbody.govuk-table__body tr.govuk-table__row")

      # Does a table row exist which contains...
      all_rows.any? do |row|
        thead = row.find(:xpath, "ancestor::table/thead")

        # ...all of the expected header & value pairs?
        expected_row.all? do |expected_header, expected_value|
          td = row.find("td.govuk-table__cell", text: expected_value)
          td_index = td.find_xpath("./preceding-sibling::td").count
          thead.find("th.govuk-table__header:nth-of-type(#{td_index + 1})", text: expected_header)
          true
        rescue Capybara::ElementNotFound
          false
        end
      end
    end
  end

  matcher :have_filter_tag do |text|
    match do |page|
      page.find(".app-filter-tags .app-filter__tag", text:)
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

  matcher :have_important_banner do |text|
    match do |page|
      within ".govuk-notification-banner" do
        page.find(".govuk-notification-banner__title", text: "Important")
        page.find(".govuk-notification-banner__heading", text:)
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
