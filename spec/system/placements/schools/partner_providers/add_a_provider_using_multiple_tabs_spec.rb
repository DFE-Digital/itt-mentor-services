require "rails_helper"

RSpec.describe "School user adds providers to their list of providers using multiple tabs", :js, service: :placements, type: :system do
  scenario do
    given_providers_exist
    and_i_am_signed_in

    when_i_use_two_tabs_to_add_providers
    and_i_am_on_the_providers_index_page_in_the_first_tab
    and_i_click_on_add_provider_in_the_first_tab
    then_i_see_the_add_provider_page_in_the_first_tab

    when_i_enter_springfield_university
    then_i_see_a_dropdown_item_for_springfield_university

    when_i_click_on_the_springfield_university_dropdown_item
    and_i_click_on_tab_one_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    when_i_am_on_the_providers_index_page_in_the_second_tab
    and_i_click_on_add_provider_in_the_second_tab
    then_i_see_the_add_provider_page_in_the_second_tab

    when_i_enter_shelbyville_university
    then_i_see_a_dropdown_item_for_shelbyville_university

    when_i_click_on_the_shelbyville_university_dropdown_item
    and_i_click_on_tab_two_continue
    then_i_see_the_confirm_provider_details_page_for_shelbyville_university

    when_i_return_to_the_first_tab_and_refresh_the_page
    then_i_see_that_springfield_university_details_have_not_changed

    when_i_click_on_tab_one_confirm_and_add_provider
    then_i_return_to_the_tab_one_provider_index
    and_i_see_springfield_university_listed

    when_i_return_to_the_second_tab_and_refresh_the_page
    then_i_see_that_shelbyville_university_details_have_not_changed

    when_i_click_on_tab_two_confirm_and_add_provider
    then_i_return_to_the_tab_two_provider_index
    and_i_see_shelbyville_university_listed
  end

  private

  def given_providers_exist
    @springfield_university = create(:placements_provider,
                                     name: "Springfield University",
                                     ukprn: "10101010",
                                     urn: "101010",
                                     email_addresses: ["reception@springfield.ac.uk"],
                                     telephone: "0101 010 0101",
                                     website: "http://www.springfield.ac.uk",
                                     address1: "Undisclosed")

    @shelbyville_university = create(:placements_provider,
                                     name: "Shelbyville University",
                                     ukprn: "99999999",
                                     urn: "999999",
                                     email_addresses: ["reception@shelbyville.ac.uk"],
                                     telephone: "9999 999 9999",
                                     website: "http://www.shelbyville.ac.uk",
                                     address1: "1 Sycamore Avenue")
  end

  def and_i_am_signed_in
    @school = create(:school, :placements)
    @windows = [open_new_window, open_new_window]
  end

  def when_i_use_two_tabs_to_add_providers
    sign_in_placements_user(organisations: [@school])
  end

  def and_i_am_on_the_providers_index_page_in_the_first_tab
    within_window @windows.first do
      visit placements_school_partner_providers_path(@school)

      expect(page).to have_current_path(placements_school_partner_providers_path(@school))
      expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_h1("Providers you work with")
    end
  end
  alias_method :then_i_return_to_the_tab_one_provider_index, :and_i_am_on_the_providers_index_page_in_the_first_tab

  def and_i_click_on_add_provider_in_the_first_tab
    within_window @windows.first do
      click_on "Add provider"
    end
  end

  def then_i_see_the_add_provider_page_in_the_first_tab
    within_window @windows.first do
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_title("Add a provider - Provider details - Manage school placements - GOV.UK")

      expect(page).to have_element(:span, text: "Provider details", class: "govuk-caption-l")
      expect(page).to have_element(:div, text: "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode", class: "govuk-hint")
      expect(page).to have_button("Continue")
      expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
    end
  end

  def when_i_enter_springfield_university
    within_window @windows.first do
      fill_in "Add a provider", with: "Springfield University"
    end
  end

  def then_i_see_a_dropdown_item_for_springfield_university
    within_window @windows.first do
      expect(page).to have_css(".autocomplete__option", text: "Springfield University")
    end
  end

  def when_i_click_on_the_springfield_university_dropdown_item
    within_window @windows.first do
      page.find(".autocomplete__option", text: "Springfield University").click
    end
  end

  # First tab only
  def and_i_click_on_tab_one_continue
    within_window @windows.first do
      click_on "Continue"
    end
  end

  def then_i_see_the_confirm_provider_details_page_for_springfield_university
    within_window @windows.first do
      expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_h1("Confirm provider details")
      expect(page).to have_element(:p, text: "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.", class: "govuk-body")
      expect(page).to have_h2("Provider")
      expect(page).to have_summary_list_row("Name", "Springfield University")
      expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10101010")
      expect(page).to have_summary_list_row("Unique reference number (URN)", "101010")
      expect(page).to have_summary_list_row("Email address", "reception@springfield.ac.uk")
      expect(page).to have_summary_list_row("Telephone number", "0101 010 0101")
      expect(page).to have_summary_list_row("Address", "Undisclosed")
      expect(page).to have_button("Confirm and add provider")
      expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
    end
  end
  alias_method :then_i_see_that_springfield_university_details_have_not_changed, :then_i_see_the_confirm_provider_details_page_for_springfield_university

  def when_i_am_on_the_providers_index_page_in_the_second_tab
    within_window @windows.second do
      visit placements_school_partner_providers_path(@school)

      expect(page).to have_current_path(placements_school_partner_providers_path(@school))
      expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_h1("Providers you work with")
    end
  end
  alias_method :then_i_return_to_the_tab_two_provider_index, :when_i_am_on_the_providers_index_page_in_the_second_tab

  def and_i_click_on_add_provider_in_the_second_tab
    within_window @windows.second do
      click_on "Add provider"
    end
  end

  def then_i_see_the_add_provider_page_in_the_second_tab
    within_window @windows.second do
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_title("Add a provider - Provider details - Manage school placements - GOV.UK")

      expect(page).to have_element(:span, text: "Provider details", class: "govuk-caption-l")
      expect(page).to have_element(:div, text: "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode", class: "govuk-hint")
      expect(page).to have_button("Continue")
      expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
    end
  end

  def when_i_enter_shelbyville_university
    within_window @windows.second do
      fill_in "Add a provider", with: "Shelbyville University"
    end
  end

  def then_i_see_a_dropdown_item_for_shelbyville_university
    within_window @windows.second do
      expect(page).to have_css(".autocomplete__option", text: "Shelbyville University")
    end
  end

  def when_i_click_on_the_shelbyville_university_dropdown_item
    within_window @windows.second do
      page.find(".autocomplete__option", text: "Shelbyville University").click
    end
  end

  def and_i_click_on_tab_two_continue
    within_window @windows.second do
      click_on "Continue"
    end
  end

  def then_i_see_the_confirm_provider_details_page_for_shelbyville_university
    within_window @windows.second do
      expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Providers")
      expect(page).to have_h1("Confirm provider details")
      expect(page).to have_element(:p, text: "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.", class: "govuk-body")
      expect(page).to have_h2("Provider")
      expect(page).to have_summary_list_row("Name", "Shelbyville University")
      expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "99999999")
      expect(page).to have_summary_list_row("Unique reference number (URN)", "999999")
      expect(page).to have_summary_list_row("Email address", "reception@shelbyville.ac.uk")
      expect(page).to have_summary_list_row("Telephone number", "9999 999 9999")
      expect(page).to have_summary_list_row("Address", "1 Sycamore Avenue")
      expect(page).to have_button("Confirm and add provider")
      expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
    end
  end
  alias_method :then_i_see_that_shelbyville_university_details_have_not_changed, :then_i_see_the_confirm_provider_details_page_for_shelbyville_university

  def when_i_return_to_the_first_tab_and_refresh_the_page
    within_window @windows.first do
      visit current_path
    end
  end

  def when_i_click_on_tab_one_confirm_and_add_provider
    within_window @windows.first do
      click_on "Confirm and add provider"
    end
  end

  def and_i_see_springfield_university_listed
    within_window @windows.first do
      expect(page).to have_table_row({
        "Name" => "Springfield University",
        "UK provider reference number (UKPRN)" => "10101010",
      },
                                     wait: 10)
    end
  end

  def when_i_return_to_the_second_tab_and_refresh_the_page
    within_window @windows.second do
      visit current_path
    end
  end

  def when_i_click_on_tab_two_confirm_and_add_provider
    within_window @windows.second do
      click_on "Confirm and add provider"
    end
  end

  def and_i_see_shelbyville_university_listed
    within_window @windows.second do
      expect(page).to have_table_row({
        "Name" => "Shelbyville University",
        "UK provider reference number (UKPRN)" => "99999999",
      },
                                     wait: 10)
    end
  end
end
