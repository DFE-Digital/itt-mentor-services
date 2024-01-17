require "rails_helper"

RSpec.describe "Placements / Support / Users / Support User Views A User", type: :system do
  let(:school) { create(:school, :placements, name: "School 1") }
  let(:provider) { create(:placements_provider, name: "Provider 1") }
  let(:anne) do
    create(:placements_user,
           first_name: "Anne",
           last_name: "Wilson",
           email: "anne_wilson@example.com")
  end
  let(:mary) do
    create(:placements_user,
           first_name: "Mary",
           last_name: "Lawson",
           email: "mary_lawson@example.com")
  end

  before do
    given_i_am_signed_in_as_a_support_user
  end

  describe "schools" do
    scenario "Support User views the users listed for a school" do
      given_users_have_been_assigned_to_the(organisation: school)
      when_i_visit_the_users_page_for(organisation: school)
      then_i_see_the_users_names_listed
    end

    scenario "Support User views the user details a user assigned to a school" do
      given_users_have_been_assigned_to_the(organisation: school)
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click_user("Anne Wilson")
      then_i_see_the_details_for("Anne Wilson")
    end
  end

  describe "provider" do
    scenario "Support User views the users listed for a provider" do
      given_users_have_been_assigned_to_the(organisation: provider)
      when_i_visit_the_users_page_for(organisation: provider)
      then_i_see_the_users_names_listed
    end

    scenario "Support User views the user details a user assigned to a provider" do
      given_users_have_been_assigned_to_the(organisation: provider)
      when_i_visit_the_users_page_for(organisation: provider)
      and_i_click_user("Anne Wilson")
      then_i_see_the_details_for("Anne Wilson")
    end
  end

  private

  def and_there_is_an_existing_persona_for(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: :placements)
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def given_i_am_signed_in_as_a_support_user
    given_i_am_on_the_placements_site
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Colin")
  end

  def given_users_have_been_assigned_to_the(organisation:)
    [mary, anne].each do |user|
      create(:membership, user:, organisation:)
    end
  end

  def when_i_visit_the_users_page_for(organisation:)
    if organisation.is_a?(Provider)
      visit placements_support_provider_users_path(organisation)
    else
      visit placements_support_school_users_path(organisation)
    end
  end

  def then_i_see_the_users_names_listed
    expect(page).to have_content("Anne Wilson")
    expect(page).to have_content("Mary Lawson")
  end

  def and_i_click_user(user_name)
    page.find("a", text: user_name).click
  end

  def then_i_see_the_details_for(_user_name)
    details_for_anne
  end

  def details_for_anne
    expect(page).to have_content("Anne")
    expect(page).to have_content("Wilson")
    expect(page).to have_content("anne_wilson@example.com")
  end
end
