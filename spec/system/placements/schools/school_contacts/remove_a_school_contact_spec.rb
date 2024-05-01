require "rails_helper"

RSpec.describe "Placements / Schools / School Contacts / Remove a school contact",
               type: :system, service: :placements do
  let(:school) { build(:placements_school) }
  let(:school_contact) { create(:school_contact, school:) }

  before do
    given_i_sign_in_as_anne
    school_contact
  end

  scenario "User removes a school contact from their organisation" do
    when_i_view_my_organisation_details_page
    then_i_see_the_school_contact_details(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on("Remove school contact")
    then_i_am_asked_to_confirm_school_contact(school_contact)
    when_i_click_on("Cancel")
    then_i_return_to_my_organisation_details_page
    and_i_see_the_school_contact_details(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    when_i_click_on("Remove school contact")
    then_i_am_asked_to_confirm_school_contact(school_contact)
    when_i_click_on("Remove school contact")
    then_i_return_to_my_organisation_details_page
    and_i_can_not_see_contact_detail(
      name: "Placement Coordinator",
      email_address: "placement_coordinator@example.school",
    )
    and_i_see_success_message
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

  def then_i_see_the_school_contact_details(name:, email_address:)
    within("#school-contact-details") do
      expect(page).to have_content(name)
      expect(page).to have_content(email_address)
    end
  end
  alias_method :and_i_see_the_school_contact_details,
               :then_i_see_the_school_contact_details

  def then_i_am_asked_to_confirm_school_contact(school_contact)
    expect_organisation_details_to_be_selected_in_primary_navigation

    expect(page).to have_title(
      "Are you sure you want to remove this school contact? - #{school_contact.name} - Manage school placements",
    )
    expect(page).to have_content school_contact.name
    expect(page).to have_content "Are you sure you want to remove this school contact?"
  end

  def then_i_return_to_my_organisation_details_page
    expect(page.find(".govuk-heading-l")).to have_content("Organisation details")
    expect(page).to have_content(school.name)
  end

  def and_i_can_not_see_contact_detail(name:, email_address:)
    expect(page).not_to have_content(name)
    expect(page).not_to have_content(email_address)
  end

  def and_i_see_success_message
    expect(page).to have_content("School contact removed")
  end
end
