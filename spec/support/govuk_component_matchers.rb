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
          td = row.find("td.govuk-table__cell", exact_text: expected_value)
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

  matcher :have_tag do |text, colour|
    match do |page|
      page.find(".govuk-tag.govuk-tag--#{colour}", text:)
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

  matcher :have_paragraph do |text|
    match do |page|
      page.find("p[class^='govuk-body']", text: text)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_span_caption do |text|
    match do |page|
      page.find("span[class^='govuk-caption-']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_inset_text do |text|
    match do |page|
      page.find("div[class^='govuk-inset-text']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_hint do |text|
    match do |page|
      page.find("div[class^='govuk-hint']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_paragraph do |text|
    match do |page|
      page.find("p[class^='govuk-body']", text:)
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_warning_text do |text|
    match do |page|
      page.within(".govuk-warning-text") do
        page.find(".govuk-warning-text__icon")
        page.find(".govuk-warning-text__text", text:)
      end
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_success_banner do |heading_text, body_text = nil|
    match do |page|
      page.within(".govuk-notification-banner.govuk-notification-banner--success") do
        page.find(".govuk-notification-banner__title", text: "Success")
        page.find(".govuk-notification-banner__heading", text: heading_text)

        if body_text
          page.find(".govuk-body", text: body_text)
        end
      end
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_important_banner do |text|
    match do |page|
      page.within(".govuk-notification-banner") do
        page.find(".govuk-notification-banner__title", text: "Important")
        page.find(".govuk-notification-banner__heading", text:)
      end
      true
    rescue Capybara::ElementNotFound
      false
    end
  end

  matcher :have_validation_error do |text|
    match do |page|
      page.within(".govuk-error-summary") do
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

  def header_navigation
    page.find(".govuk-header__navigation")
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

  matcher :have_claim_card do |expected_claim_details|
    match do |page|
      all_claim_cards = page.all("div.claim-card")

      # Does a claim card exist which contains...
      all_claim_cards.any? do |claim_card|
        # ...all of the expected header & value pairs?
        expected_claim_details.all? do
          header = claim_card.find("div.claim-card__header")
          header.find_link(expected_claim_details["title"], href: expected_claim_details["url"])

          body = claim_card.find("div.claim-card__body")
          details = body.find("div.claim-card__body__details")
          details.find("div.govuk-body-s:nth-of-type(1)", text: expected_claim_details["academic_year"])
          details.find("div.govuk-body-s:nth-of-type(2)", text: expected_claim_details["provider_name"])

          right = body.find("div.claim-card__body__right")
          right.find("div.govuk-body-s:nth-of-type(1)", text: expected_claim_details["submitted_date"])
          right.find("div.govuk-body-s:nth-of-type(2)", text: expected_claim_details["amount"])

          true
        rescue Capybara::ElementNotFound
          false
        end
      end
    end
  end

  matcher :have_panel do |panel_title, panel_body = nil|
    match do |page|
      page.within(".govuk-panel") do
        page.find(".govuk-panel__title", text: panel_title)
        page.find(".govuk-panel__body", text: panel_body) if panel_body.present?
      end
      true
    rescue Capybara::ElementNotFound
      false
    end
  end
end
