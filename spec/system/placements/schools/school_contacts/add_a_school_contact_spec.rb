require "rails_helper"

RSpec.describe "Placements / Schools / School Contacts / Add a school contact",
               service: :placements, type: :system do
  let(:school) { build(:placements_school, with_school_contact: false) }

  before do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
  end

  scenario "User adds a school contact to their organisation" do
    when_i_view_my_organisation_details_page
    then_i_see_no_school_contact_details
    when_i_click_on("Add placement contact")
    and_i_fill_out_the_school_contact_form(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    and_i_click_on("Continue")
    then_i_see_the_check_your_answers_page(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on("Add placement contact")
    then_i_return_to_my_organisation_details_page
    and_i_see_the_school_contact_details(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    and_i_see_success_message
  end

  scenario "User reconsiders school contact details" do
    when_i_view_my_organisation_details_page
    then_i_see_no_school_contact_details
    when_i_click_on("Add placement contact")
    and_i_fill_out_the_school_contact_form(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    and_i_click_on("Continue")
    then_i_see_the_check_your_answers_page(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on("Back")
    then_i_see_the_inputs_pre_filled_with(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on("Continue")
    then_i_see_the_check_your_answers_page(
      first_name: "Placement",
      last_name: "Coordinator",
      email_address: "placement_coordinator@example.school",
    )
  end

  scenario "User attempts to add a school contact with an invalid email address" do
    when_i_view_my_organisation_details_page
    then_i_see_no_school_contact_details
    when_i_click_on("Add placement contact")
    and_i_fill_out_the_school_contact_form(
      first_name: "Placemen",
      last_name: "Coordinator",
      email_address: "invalid_email",
    )
    and_i_click_on("Continue")
    then_i_see_an_error("Enter an email address in the correct format, like name@example.com")
  end

  private

  def when_i_view_my_organisation_details_page
    visit placements_school_path(school)

    expect_organisation_details_to_be_selected_in_primary_navigation
  end

  def expect_organisation_details_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "page"
      expect(page).to have_link "Providers", current: "false"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_see_no_school_contact_details
    expect(page).to have_content("Placement contact")
    expect(page).to have_content("Add placement contact")
  end

  def when_i_fill_out_the_school_contact_form(first_name:, last_name:, email_address:)
    fill_in "First name", with: first_name
    fill_in "Last name", with: last_name
    fill_in "Email", with: email_address
  end
  alias_method :and_i_fill_out_the_school_contact_form,
               :when_i_fill_out_the_school_contact_form

  def then_i_see_the_check_your_answers_page(first_name:, last_name:, email_address:)
    expect(page).to have_content(first_name)
    expect(page).to have_content(last_name)
    expect(page).to have_content(email_address)
  end

  def then_i_return_to_my_organisation_details_page
    expect(page.find(".govuk-heading-l")).to have_content(school.name)
    expect_organisation_details_to_be_selected_in_primary_navigation
  end

  def and_i_see_the_school_contact_details(first_name:, last_name:, email_address:)
    within("#school-contact-details") do
      expect(page).to have_content(first_name)
      expect(page).to have_content(last_name)
      expect(page).to have_content(email_address)
    end
  end

  def and_i_see_success_message
    expect(page).to have_content("Placement contact added")
  end

  def then_i_see_the_inputs_pre_filled_with(first_name:, last_name:, email_address:)
    find_field "First name", with: first_name
    find_field "Last name", with: last_name
    find_field "Email address", with: email_address
  end

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end
end
