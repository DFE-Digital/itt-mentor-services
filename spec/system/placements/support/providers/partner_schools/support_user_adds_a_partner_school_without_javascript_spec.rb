require "rails_helper"

RSpec.describe "Support user adds a partner school without JavaScript",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_two_schools_exist
    and_a_provider_exists
    given_i_am_signed_in_as_a_placements_support_user

    when_i_click_on_westbrook_provider
    then_i_see_the_find_page

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

    when_i_type_in_the_incomplete_name_shelb
    and_i_click_on_continue
    then_i_see_the_multiple_school_results_page

    when_i_click_on_change_your_search
    then_i_see_the_add_school_page

    when_i_type_in_the_incomplete_name_shelb
    and_i_click_on_continue
    then_i_see_the_multiple_school_results_page

    when_i_choose_shelbyville_elementary
    and_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_back
    then_i_see_the_multiple_school_results_page_with_shelbyville_elementary_selected

    when_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_change_name
    then_i_see_the_add_school_page_with_shelb_prepopulated

    when_i_click_on_continue
    then_i_see_the_multiple_school_results_page

    when_i_choose_shelbyville_elementary
    and_i_click_on_continue
    then_i_see_the_check_details_page_for_shelbyville_school

    when_i_click_on_confirm_and_add_school
    then_i_return_to_the_partner_school_index_page_with_a_new_partner_school_and_a_success_banner

    when_i_click_on_add_school
    then_i_see_the_add_school_page

    when_i_type_in_the_incomplete_name_shelb
    and_i_click_on_continue
    then_i_see_the_multiple_school_results_page

    when_i_choose_shelbyville_elementary
    and_i_click_on_continue
    then_i_see_an_error_that_shelbyville_elementary_has_already_been_added
  end

  private

  def given_two_schools_exist
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
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
    @shelberg_high_school = create(
      :placements_school,
      name: "Shelberg High School",
    )
  end

  def and_a_provider_exists
    @provider = create(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
  end

  def when_i_click_on_westbrook_provider
    click_on "Westbrook Provider"
  end

  def then_i_see_the_find_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Westbrook Provider", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
  end

  def when_i_navigate_to_the_provider_schools_page
    within(primary_navigation) do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_paragraph("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_paragraph("There are no partner schools for Westbrook Provider")
  end

  def when_i_click_on_add_school
    click_on "Add school"
  end

  def then_i_see_the_add_school_page
    expect(page).to have_title("Add a school - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_hint("Enter a school name, unique reference number (URN) or postcode")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: placements_provider_partner_schools_path(@provider))
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

  def when_i_type_in_the_incomplete_name_shelb
    fill_in "Add a school", with: "Shelb"
  end

  def then_i_see_the_multiple_school_results_page
    expect(page).to have_title("2 results found for ‘Shelb’ - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_link("Change your search")
    expect(page).to have_hint("Change your search if the school you’re looking for is not listed.")
    expect(page).to have_field("Shelbyville Elementary", type: :radio)
    expect(page).to have_field("Shelberg High School", type: :radio)
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: placements_provider_partner_schools_path(@provider))
  end

  def when_i_click_on_change_your_search
    click_on "Change your search"
  end

  def when_i_choose_shelbyville_elementary
    choose "Shelbyville Elementary"
  end

  def then_i_see_the_multiple_school_results_page_with_shelbyville_elementary_selected
    expect(page).to have_title("2 results found for ‘Shelb’ - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_link("Change your search")
    expect(page).to have_hint("Change your search if the school you’re looking for is not listed.")
    expect(page).to have_checked_field("Shelbyville Elementary", type: :radio)
    expect(page).to have_field("Shelberg High School", type: :radio)
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: placements_provider_partner_schools_path(@provider))
  end

  def then_i_see_the_add_school_page_with_shelb_prepopulated
    expect(page).to have_title("Add a school - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_element(:span, class: "govuk-caption-l", text: "School details")
    expect(page).to have_element(:input, class: "govuk-input", value: "Shelb")
    expect(page).to have_hint("Enter a school name, unique reference number (URN) or postcode")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: placements_provider_partner_schools_path(@provider))
  end

  def then_i_see_the_check_details_page_for_shelbyville_school
    expect(page).to have_title("Confirm school details - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Confirm school details")
    expect(page).to have_paragraph("Once added, they will be able to assign you to their placements.")
    expect(page).to have_paragraph("We will send them an email to let them know you have added them.")
    expect(page).to have_summary_list_row("Name", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "54321")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "12345")
    expect(page).to have_summary_list_row("Email address", "shelbyville_elementary@sample.com")
    expect(page).to have_summary_list_row("Telephone number", "02083334444")
    expect(page).to have_summary_list_row("Website", "http://www.shelbyville_elementary.com")
    expect(page).to have_summary_list_row("Address", "44 Langton Way")
    expect(page).to have_button("Confirm and add school")
    expect(page).to have_link("Cancel", href: placements_provider_partner_schools_path(@provider))
  end

  def then_i_see_the_search_input_pre_filled_with_shelbyville_school
    find_field "Add a school", with: "Shelb"
  end

  def when_i_click_on_change_name
    click_on "Change Name"
  end

  def when_i_click_on_confirm_and_add_school
    click_on "Confirm and add school"
  end

  def then_i_return_to_the_partner_school_index_page_with_a_new_partner_school_and_a_success_banner
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_paragraph("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "12345" })
    expect(page).to have_success_banner("School added", "Shelbyville Elementary can now assign you to their placements.")
  end

  def then_i_see_an_error_that_shelbyville_elementary_has_already_been_added
    expect(page).to have_validation_error("Shelbyville Elementary has already been added. Try another school")
  end
end
