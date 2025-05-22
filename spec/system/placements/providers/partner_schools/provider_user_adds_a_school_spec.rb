require "rails_helper"

RSpec.describe "Provider user adds a school", :js,
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_a_school_exists_with_a_provider
    given_i_am_signed_in

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_no_schools

    when_i_click_on_add_school
    then_i_see_the_add_school_page

    when_i_click_on_continue
    then_i_see_an_error_that_i_must_enter_a_name_urn_or_postcode

    when_i_click_on_back
    then_i_see_the_provider_schools_index_with_no_schools

    when_i_click_on_add_school
    then_i_see_the_add_school_page

    when_i_type_in_shelbyville_school
    then_i_see_a_dropdown_item_for_the_shelbyville_school

    when_i_select_shelbyville_school_from_the_dropdown
    and_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_back
    then_i_see_the_search_input_pre_filled_with_shelbyville_school

    when_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_change_name
    then_i_see_the_search_input_pre_filled_with_shelbyville_school

    when_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_confirm_and_add_school
    then_i_return_to_the_partner_school_index_page_with_a_new_partner_school_and_a_success_banner

    when_i_click_on_add_school
    then_i_see_the_add_school_page

    when_i_type_in_shelbyville_school
    then_i_see_a_dropdown_item_for_the_shelbyville_school

    when_i_select_shelbyville_school_from_the_dropdown
    and_i_click_on_continue
    then_i_see_an_error_that_shelbyville_elementary_has_already_been_added
  end

  private

  def given_a_school_exists_with_a_provider
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = create(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
    @shelbyville_school = create(
      :placements_school,
      name: "Shelbyville Elementary",
      urn: "12345",
      email_address: "shelbyville_elementary@sample.com",
      ukprn: "54321",
      address1: "44 Langton Way",
      website: "www.shelbyville_elementary.com",
      telephone: "02083334444",
    )
  end

  def given_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_the_provider_schools_page
    within(".app-primary-navigation") do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_text("View all placements your schools have published.")
    expect(page).to have_text("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_text("There are no partner schools for Westbrook Provider")
  end

  def when_i_click_on_add_school
    click_on "Add school"
  end

  def then_i_see_the_add_school_page
    expect(page).to have_title("Add a school - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_element(:span, class: "govuk-caption-l", text: "School details")
    expect(page).to have_hint("Enter a school name, unique reference number (URN) or postcode")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_an_error_that_i_must_enter_a_name_urn_or_postcode
    expect(page).to have_validation_error("Enter a school name, unique reference number (URN) or postcode")
  end

  def when_i_type_in_shelbyville_school
    fill_in "Add a school", with: "Shelbyville Elementary"
  end

  def then_i_see_a_dropdown_item_for_the_shelbyville_school
    expect(page).to have_css(".autocomplete__option", text: "Shelbyville Elementary", wait: 10)
  end

  def when_i_select_shelbyville_school_from_the_dropdown
    page.find(".autocomplete__option", text: "Shelbyville Elementary").click
  end

  def then_i_see_the_check_details_page_for_shelbyville_school
    expect(page).to have_title("Confirm school details - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Confirm school details")
    expect(page).to have_text("Once added, they will be able to assign you to their placements.")
    expect(page).to have_text("We will send them an email to let them know you have added them.")
    expect(page).to have_summary_list_row("Name", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "54321")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "12345")
    expect(page).to have_summary_list_row("Email address", "shelbyville_elementary@sample.com")
    expect(page).to have_summary_list_row("Telephone number", "02083334444")
    expect(page).to have_summary_list_row("Website", "http://www.shelbyville_elementary.com")
    expect(page).to have_summary_list_row("Address", "44 Langton Way")
    expect(page).to have_button("Confirm and add school")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_search_input_pre_filled_with_shelbyville_school
    within(".autocomplete__wrapper") do
      find_field "Add a school", with: "Shelbyville Elementary"
    end
  end

  def when_i_click_on_change_name
    within(".govuk-summary-list") do
      click_on "Change"
    end
  end

  def when_i_click_on_confirm_and_add_school
    click_on "Confirm and add school"
  end

  def then_i_return_to_the_partner_school_index_page_with_a_new_partner_school_and_a_success_banner
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_text("View all placements your schools have published.")
    expect(page).to have_text("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "12345" })
    expect(page).to have_success_banner("School added", "Shelbyville Elementary can now assign you to their placements.")
  end

  def then_i_see_an_error_that_shelbyville_elementary_has_already_been_added
    expect(page).to have_validation_error("Shelbyville Elementary has already been added. Try another school")
  end
end
