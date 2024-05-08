require "rails_helper"

RSpec.describe "Placements / Schools / School Contacts / Edit a school contact",
               type: :system, service: :placements do
  let(:school) { build(:placements_school) }
  let(:school_contact) { create(:school_contact, school:) }

  before do
    given_i_sign_in_as_anne
    school_contact
  end

  scenario "User edits the name of the school contact for their organisation" do
    when_i_view_my_organisation_details_page
    then_i_see_the_school_contact_details(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on_change(attribute: :name)
    then_i_see_the_inputs_pre_filled_with(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_fill_out_the_school_contact_form(
      name: "Placement Organiser",
      email_address: "placement_organiser@example.school",
    )
    and_i_click_on("Continue")
    then_i_return_to_my_organisation_details_page
    and_i_see_the_school_contact_details(
      name: "Placement Organiser",
      email_address: "placement_organiser@example.school",
    )
    and_i_see_success_message
  end

  scenario "User edits the email address of the school contact for their organisation" do
    when_i_view_my_organisation_details_page
    then_i_see_the_school_contact_details(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on_change(attribute: :email_address)
    then_i_see_the_inputs_pre_filled_with(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_fill_out_the_school_contact_form(
      name: "Placement Organiser",
      email_address: "placement_organiser@example.school",
    )
    and_i_click_on("Continue")
    then_i_return_to_my_organisation_details_page
    and_i_see_the_school_contact_details(
      name: "Placement Organiser",
      email_address: "placement_organiser@example.school",
    )
    and_i_see_success_message
  end

  scenario "User attempts to edit a school contact with an invalid email address" do
    when_i_view_my_organisation_details_page
    then_i_see_the_school_contact_details(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on_change(attribute: :email_address)
    and_i_fill_out_the_school_contact_form(
      name: "Placement Organiser",
      email_address: "placement organiser",
    )
    and_i_click_on("Continue")
    then_i_see_an_error("Enter an email address in the correct format, like name@example.com")
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

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
      expect(page).to have_link "Partner providers", current: "false"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_click_on_change(attribute:)
    link_num = attribute == :name ? 0 : 1

    within("#school-contact-details") do
      page.all("a", text: "Change")[link_num].click
    end
  end

  def then_i_see_the_school_contact_details(name:, email_address:)
    within("#school-contact-details") do
      expect(page).to have_content(name)
      expect(page).to have_content(email_address)
    end
  end
  alias_method :and_i_see_the_school_contact_details,
               :then_i_see_the_school_contact_details

  def then_i_see_the_inputs_pre_filled_with(name:, email_address:)
    expect(page.find("#placements-school-contact-name-field").value).to eq(name)
    expect(page.find("#placements-school-contact-email-address-field").value).to eq(email_address)
  end

  def when_i_fill_out_the_school_contact_form(name:, email_address:)
    fill_in "Full name", with: name
    fill_in "Email", with: email_address
  end
  alias_method :and_i_fill_out_the_school_contact_form,
               :when_i_fill_out_the_school_contact_form

  def then_i_return_to_my_organisation_details_page
    expect(page.find(".govuk-heading-l")).to have_content(school.name)
    expect_organisation_details_to_be_selected_in_primary_navigation
  end

  def and_i_see_the_school_contact_details(name:, email_address:)
    within("#school-contact-details") do
      expect(page).to have_content(name)
      expect(page).to have_content(email_address)
    end
  end

  def and_i_see_success_message
    expect(page).to have_content("School contact updated")
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
