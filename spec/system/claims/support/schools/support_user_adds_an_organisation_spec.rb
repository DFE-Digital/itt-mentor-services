require "rails_helper"

RSpec.describe "Support user adds an organisation", service: :claims, type: :system do
  scenario do
    given_a_claim_window_exists
    and_i_am_signed_in
    then_i_am_on_the_organisations_page

    when_i_click_on_add_organisation
    then_i_see_the_enter_an_organisation_page

    when_i_click_on_the_organisation_is_not_listed
    then_i_see_the_details_text

    when_i_click_on_manually_add_them_to_the_service
    then_i_see_the_enter_the_organisation_name_page

    when_i_click_continue
    then_i_see_the_organisation_name_error

    when_i_enter_an_organisation_name
    and_i_click_continue
    then_i_see_the_vendor_number_page

    when_i_click_continue
    then_i_see_the_vendor_number_error

    when_i_click_on_the_vendor_number_details_summary
    then_i_see_the_vendor_number_details_text

    when_i_enter_a_vendor_number
    and_i_click_continue
    then_i_see_the_claim_window_page

    when_i_click_continue
    then_i_see_the_claim_window_error

    when_i_click_on_the_claim_window_details_summary
    then_i_see_the_claim_window_details_text

    when_i_select_the_current_claim_window
    and_i_click_continue
    then_i_see_the_region_page

    when_i_click_continue
    then_i_see_the_region_error

    when_i_select_a_region
    and_i_click_continue
    then_i_see_the_address_page

    when_i_click_continue
    then_i_see_the_address1_error
    and_i_see_the_town_error
    and_i_see_the_postcode_error

    when_i_enter_address1
    and_i_enter_town
    and_i_enter_postcode
    and_i_click_continue
    then_i_see_the_contact_details_page

    when_i_click_continue
    then_i_see_the_website_error
    and_i_see_the_telephone_error

    when_i_enter_a_website
    and_i_enter_a_telephone
    and_i_click_continue
    then_i_see_the_check_your_answers_page

    when_i_click_to_change_the_organisation_name
    then_i_see_the_enter_the_organisation_name_page

    when_i_change_the_organisation_name
    and_i_navigate_back_to_check_your_answers_from_the_organisation_name_page
    then_i_see_the_check_your_answers_page_with_changed_organisation_name

    when_i_click_to_change_the_vendor_number
    then_i_see_the_vendor_number_page

    when_i_change_the_vendor_number
    and_i_navigate_back_to_check_your_answers_from_the_vendor_number_page
    then_i_see_the_check_your_answers_page_with_changed_vendor_number

    when_i_click_to_change_the_claim_window
    then_i_see_the_claim_window_page

    when_i_change_the_claim_window
    and_i_navigate_back_to_check_your_answers_from_the_claim_window_page
    then_i_see_the_check_your_answers_page_with_changed_claim_window

    when_i_click_to_change_the_region
    then_i_see_the_region_page

    when_i_change_the_region
    and_i_navigate_back_to_check_your_answers_from_the_region_page
    then_i_see_the_check_your_answers_page_with_changed_region

    when_i_click_to_change_the_address
    then_i_see_the_address_page

    when_i_change_the_address
    and_i_navigate_back_to_check_your_answers_from_the_address_page
    then_i_see_the_check_your_answers_page_with_changed_address

    when_i_click_to_change_the_telephone_number
    then_i_see_the_contact_details_page

    when_i_change_the_telephone_number
    and_i_navigate_back_to_check_your_answers_from_the_contact_details_page
    then_i_see_the_check_your_answers_page_with_changed_telephone_number

    when_i_click_to_change_the_website
    then_i_see_the_contact_details_page

    when_i_change_the_website
    and_i_navigate_back_to_check_your_answers_from_the_website_page
    then_i_see_the_check_your_answers_page_with_changed_website

    when_i_click_save_organisation
    then_i_see_the_organisations_page
    and_i_see_the_success_message
  end

  def given_a_claim_window_exists
    @claim_window = create(:claim_window, :current).decorate
    @claim_window_2 = create(:claim_window, :upcoming).decorate
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def then_i_am_on_the_organisations_page
    expect(page).to have_title("Organisations (0) - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_h1("Organisations (0)")
    expect(page).to have_link("Add organisation")
  end

  def when_i_click_on_add_organisation
    click_on "Add organisation"
  end

  def then_i_see_the_enter_an_organisation_page
    expect(page).to have_title("Enter a school name, URN or postcode - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_element(:label, text: "Enter a school name, URN or postcode", class: "govuk-label govuk-label--l")
  end

  def when_i_click_on_the_organisation_is_not_listed
    find(".govuk-details__summary").click
  end

  def then_i_see_the_details_text
    within ".govuk-details" do
      within ".govuk-details__text" do
        expect(page).to have_element(:li, text: "Ask the organisation to provide information about your banking and payments to DfE (opens in new tab). This will give them a vendor number, it may take up to 6 weeks for them to receive it.")
        expect(page).to have_element(:li, text: "Wait for the organisation to send you their vendor number.")
        expect(page).to have_element(:li, text: "Return to this page to manually add them to the service. You will need the vendor number, organisation name, address, phone number and website url.")
        expect(page).to have_link("provide information about your banking and payments to DfE (opens in new tab)", href: "http://www.gov.uk/guidance/provide-information-about-your-banking-and-payments-to-dfe")
      end
    end
  end

  def when_i_click_on_manually_add_them_to_the_service
    click_on "manually add them to the service"
  end

  def then_i_see_the_enter_the_organisation_name_page
    expect(page).to have_title("Enter the organisation name - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_element(:label, text: "Enter the organisation name", class: "govuk-label govuk-label--l")
    expect(page).to have_link("Back")
  end

  def when_i_click_continue
    click_on "Continue"
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_see_the_organisation_name_error
    expect(page).to have_validation_error("Please enter the name of the organisation")
  end

  def when_i_enter_an_organisation_name
    fill_in "Enter the organisation name", with: "Test Organisation"
  end

  def then_i_see_the_vendor_number_page
    expect(page).to have_title("Enter the organisation&#39;s vendor number - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_element(:label, text: "Enter the organisation's vendor number", class: "govuk-label govuk-label--l")
    expect(page).to have_link("Back")
  end

  def then_i_see_the_vendor_number_error
    expect(page).to have_validation_error("Please enter a vendor number for the organisation")
  end

  def when_i_click_on_the_vendor_number_details_summary
    find(".govuk-details__summary").click
  end

  def then_i_see_the_vendor_number_details_text
    within ".govuk-details" do
      within ".govuk-details__text" do
        expect(page).to have_element(:p, text: "The organisation can get a vendor number by providing information about their banking and payments to DfE (opens in new tab). Receiving a vendor number may take up to 6 weeks", class: "govuk-body")
        expect(page).to have_element(:p, text: "Once they have provided you with a vendor number, you will be able to manually add them.", class: "govuk-body")
        expect(page).to have_link("providing information about their banking and payments to DfE (opens in new tab)", href: "http://www.gov.uk/guidance/provide-information-about-your-banking-and-payments-to-dfe")
      end
    end
  end

  def when_i_enter_a_vendor_number
    fill_in "Enter the organisation's vendor number", with: "123456789"
  end

  def then_i_see_the_claim_window_page
    expect(page).to have_title("Select a claim window - Add organisation - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_element(:h1, text: "Select a claim window", class: "govuk-fieldset__heading")
    expect(page).to have_link("Back")
  end

  def then_i_see_the_claim_window_error
    expect(page).to have_validation_error("Please select a claim window")
  end

  def when_i_click_on_the_claim_window_details_summary
    find(".govuk-details__summary").click
  end

  def then_i_see_the_claim_window_details_text
    within ".govuk-details" do
      within ".govuk-details__text" do
        expect(page).to have_content("If you cannot see the dates you need you can create an additional claim window (opens in new tab).")
        expect(page).to have_link("create an additional claim window (opens in new tab)", href: "/support/claim_windows")
      end
    end
  end

  def when_i_select_the_current_claim_window
    choose @claim_window.name
  end

  def then_i_see_the_region_page
    expect(page).to have_title("Enter the organisation&#39;s region - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_element(:h1, text: "Enter the organisation's region", class: "govuk-fieldset__heading")
    expect(page).to have_element(:div, text: "The region is required to calculate the claim amount", class: "govuk-hint")
    expect(page).to have_link("Back")
  end

  def then_i_see_the_region_error
    expect(page).to have_validation_error("Please select a region for the organisation")
  end

  def when_i_select_a_region
    find("label", text: "Fringe").click
  end

  def then_i_see_the_address_page
    expect(page).to have_title("Enter the organisation&#39;s address - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_h1("Enter the organisation's address")
    expect(page).to have_link("Back")
  end

  def then_i_see_the_address1_error
    expect(page).to have_validation_error("Please enter the first line of the address for the organisation")
  end

  def and_i_see_the_town_error
    expect(page).to have_validation_error("Please enter the town or city for the organisation")
  end

  def and_i_see_the_postcode_error
    expect(page).to have_validation_error("Please enter the postcode for the organisation")
  end

  def when_i_enter_address1
    fill_in "Address line 1", with: "123 Test Street"
  end

  def and_i_enter_town
    fill_in "Town or city", with: "Test Town"
  end

  def and_i_enter_postcode
    fill_in "Postcode", with: "AB12 3CD"
  end

  def then_i_see_the_contact_details_page
    expect(page).to have_title("Enter the organisation&#39;s contact details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_h1("Enter the organisation's contact details")
    expect(page).to have_link("Back")
  end

  def then_i_see_the_website_error
    expect(page).to have_validation_error("Please enter a website address for the organisation")
  end

  def and_i_see_the_telephone_error
    expect(page).to have_validation_error("Please enter a telephone number for the organisation")
  end

  def when_i_enter_a_website
    fill_in "Website", with: "https://www.testorganisation.com"
  end

  def and_i_enter_a_telephone
    fill_in "Telephone number", with: "01234 567890"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_summary_list_row("Organisation name", "Test Organisation")
    expect(page).to have_summary_list_row("Vendor number", "123456789")
    expect(page).to have_summary_list_row("Claim window", @claim_window.name)
    expect(page).to have_summary_list_row("Region", "Inner London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "123 Test Street Test Town AB12 3CD")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")

    expect(page).to have_link("Back")
  end

  def when_i_click_to_change_the_organisation_name
    click_link "Change Organisation name"
  end

  def when_i_change_the_organisation_name
    fill_in "Enter the organisation name", with: "Changed Organisation"
  end

  def and_i_navigate_back_to_check_your_answers_from_the_organisation_name_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_organisation_name
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "123456789")
    expect(page).to have_summary_list_row("Claim window", @claim_window.name)
    expect(page).to have_summary_list_row("Region", "Inner London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "123 Test Street Test Town AB12 3CD")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
  end

  def when_i_click_to_change_the_vendor_number
    click_link "Change Vendor number"
  end

  def when_i_change_the_vendor_number
    fill_in "Enter the organisation's vendor number", with: "987654321"
  end

  def and_i_navigate_back_to_check_your_answers_from_the_vendor_number_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_vendor_number
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window.name)
    expect(page).to have_summary_list_row("Region", "Inner London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "123 Test Street Test Town AB12 3CD")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
  end

  def when_i_click_to_change_the_claim_window
    click_link "Change Claim window"
  end

  def when_i_change_the_claim_window
    choose @claim_window_2.name
  end

  def and_i_navigate_back_to_check_your_answers_from_the_claim_window_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_claim_window
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window_2.name)
    expect(page).to have_summary_list_row("Region", "Inner London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "123 Test Street Test Town AB12 3CD")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
  end

  def when_i_click_to_change_the_region
    click_link "Change Region"
  end

  def when_i_change_the_region
    find("label", text: "Outer London").click
  end

  def and_i_navigate_back_to_check_your_answers_from_the_region_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_region
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window_2.name)
    expect(page).to have_summary_list_row("Region", "Outer London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "123 Test Street Test Town AB12 3CD")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
  end

  def when_i_click_to_change_the_address
    click_link "Change Address"
  end

  def when_i_change_the_address
    fill_in "Address line 1", with: "456 Changed Street"
    fill_in "Town or city", with: "Changed Town"
    fill_in "Postcode", with: "EF45 6GH"
  end

  def and_i_navigate_back_to_check_your_answers_from_the_address_page
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_address
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window_2.name)
    expect(page).to have_summary_list_row("Region", "Outer London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "456 Changed Street Changed Town EF45 6GH")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
  end

  def when_i_click_to_change_the_telephone_number
    click_link "Change Telephone number"
  end

  def when_i_change_the_telephone_number
    fill_in "Telephone number", with: "09876 543210"
  end

  def and_i_navigate_back_to_check_your_answers_from_the_contact_details_page
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_telephone_number
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window_2.name)
    expect(page).to have_summary_list_row("Region", "Outer London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "456 Changed Street Changed Town EF45 6GH")
    expect(page).to have_summary_list_row("Website", "https://www.testorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "09876 543210")
  end

  def when_i_click_to_change_the_website
    click_link "Change Website"
  end

  def when_i_change_the_website
    fill_in "Website", with: "https://www.changedorganisation.com"
  end

  def and_i_navigate_back_to_check_your_answers_from_the_website_page
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_changed_website
    expect(page).to have_summary_list_row("Organisation name", "Changed Organisation")
    expect(page).to have_summary_list_row("Vendor number", "987654321")
    expect(page).to have_summary_list_row("Claim window", @claim_window_2.name)
    expect(page).to have_summary_list_row("Region", "Outer London")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Address", "456 Changed Street Changed Town EF45 6GH")
    expect(page).to have_summary_list_row("Website", "https://www.changedorganisation.com")
    expect(page).to have_summary_list_row("Telephone number", "09876 543210")
  end

  def when_i_click_save_organisation
    click_on "Save organisation"
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations (1) - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_h1("Organisations (1)")
    expect(page).to have_link("Add organisation")
    expect(page).to have_link("Changed Organisation")
  end

  def and_i_see_the_success_message
    expect(page).to have_success_banner("Organisation added")
  end
end
