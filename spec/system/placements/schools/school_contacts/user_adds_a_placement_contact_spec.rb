require "rails_helper"

RSpec.describe "School user adds a placement contact to their school", service: :placements, type: :system do
  scenario do
    given_i_am_signed_in

    when_i_view_my_organisation_details_page
    then_i_do_not_see_any_placement_contact_details

    when_i_click_on_add_placement_contact
    and_i_submit_the_form
    then_i_see_a_validation_error_for_the_email_address

    when_i_fill_in_the_placement_contact_form
    and_i_submit_the_form
    then_i_see_the_check_your_answers_page

    when_i_change_the_first_name
    and_i_submit_the_form
    then_i_see_the_check_your_answers_page_with_the_updated_first_name

    when_i_change_the_last_name
    and_i_submit_the_form
    then_i_see_the_check_your_answers_page_with_the_updated_last_name

    when_i_change_the_email_address
    and_i_submit_the_form
    then_i_see_the_check_your_answers_page_with_the_updated_email_address

    when_i_click_on_add_placement_contact
    then_i_see_my_placement_contact_details
    and_i_see_a_success_message
  end

  private

  def given_i_am_signed_in
    @school = build(:placements_school, with_school_contact: false, urn: "500005", ukprn: "10000001",
                                        name: "Springfield Elementary", phase: :primary)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_view_my_organisation_details_page
    click_on "Organisation details"
    expect(page).to have_title("Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Springfield Elementary")
    expect(page).to have_h2("Placement contact")
    expect(page).to have_h2("School")
    expect(page).to have_summary_list_row("Name", "Springfield Elementary")
    expect(page).to have_summary_list_row("UKPRN", "10000001")
    expect(page).to have_summary_list_row("URN", "500005")
  end

  def then_i_do_not_see_any_placement_contact_details
    expect(page).not_to have_css "#school-contact-details"
  end

  def when_i_click_on_add_placement_contact
    click_on "Add placement contact"
  end

  def when_i_fill_in_the_placement_contact_form
    fill_in "First name", with: "Placement"
    fill_in "Last name", with: "Coordinator"
    fill_in "Email address", with: "placement_coordinator@example.com"
  end

  def and_i_submit_the_form
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_the_email_address
    expect(page).to have_title("Error: Add placement contact - Organisation details - Manage school placements - GOV.UK")
    expect(page).to have_validation_error("Enter an email address")
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("First name", "Placement")
    expect(page).to have_summary_list_row("Last name", "Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.com")
  end

  def when_i_change_the_first_name
    click_on "Change First name"
    fill_in "First name", with: "Updated Placement Coordinator"
  end

  def then_i_see_the_check_your_answers_page_with_the_updated_first_name
    expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("First name", "Updated Placement")
    expect(page).to have_summary_list_row("Last name", "Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.com")
  end

  def when_i_change_the_last_name
    click_on "Change Last name"
    fill_in "Last name", with: "Updated Coordinator"
  end

  def then_i_see_the_check_your_answers_page_with_the_updated_last_name
    expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("First name", "Updated Placement")
    expect(page).to have_summary_list_row("Last name", "Updated Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.com")
  end

  def when_i_change_the_email_address
    click_on "Change Email address"
    fill_in "Email address", with: "updated_placement_coordinator@example.com"
  end

  def then_i_see_the_check_your_answers_page_with_the_updated_email_address
    expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("First name", "Updated Placement")
    expect(page).to have_summary_list_row("Last name", "Updated Coordinator")
    expect(page).to have_summary_list_row("Email address", "updated_placement_coordinator@example.com")
  end

  def then_i_see_my_placement_contact_details
    expect(page).to have_title("Organisation details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Springfield Elementary")
    expect(page).to have_h2("Placement contact")
    within "#school-contact-details" do
      expect(page).to have_summary_list_row("First name", "Updated Placement")
      expect(page).to have_summary_list_row("Last name", "Updated Coordinator")
      expect(page).to have_summary_list_row("Email address", "updated_placement_coordinator@example.com")
    end
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Placement contact added")
  end
end
