require "rails_helper"

RSpec.describe "School Page", service: :claims, type: :system do
  let(:school1) { create(:school, :claims, name: "School B") }
  let(:school2) { create(:school, :claims, name: "School A") }

  scenario "User visits his school" do
    user_exists_in_dfe_sign_in(
      user: given_there_is_an_existing_user_for("Anne"),
    )
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    when_i_click_on_school_details
    then_i_see_the_school_details
  end

  scenario "User with multiple schools changes between them" do
    user = given_there_is_an_existing_user_for("Mary")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_multiple_schools(user)
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    then_i_see_schools_ordered_by_name

    i_go_to_school_details_page("School B")
    when_i_click_on_school_details
    then_i_see_the_school_details

    i_click_on_change_organisation
    i_go_to_school_details_page("School A")
    when_i_click_on_school_details
    then_i_see_the_school_details
  end

  private

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def when_i_click_on_school_details
    click_on "Organisation details"
  end

  def given_the_claims_persona(persona_name)
    create(:claims_user, persona_name.downcase.to_sym)
  end

  def and_user_has_multiple_schools(user)
    create(:user_membership, user:, organisation: school2)
  end

  def given_there_is_an_existing_user_for(user_name)
    user = create(:claims_user, user_name.downcase.to_sym)
    create(:user_membership, user:, organisation: school1)
    user
  end

  def then_i_see_schools_ordered_by_name
    expect(page.body.index("School A")).to be < page.body.index("School B")
  end

  def then_i_see_the_school_details
    within(".govuk-heading-l") do
      expect(page).to have_content "Organisation details"
    end

    expect(page).to have_content "Grant funding"
    expect(page).to have_content "Contact details"

    within("#organisation-details") do
      expect(page).to have_content "Organisation name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
    end

    within("#contact-details") do
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone number"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end
  end

  def i_go_to_school_details_page(school_name)
    click_on school_name
  end

  def i_click_on_change_organisation
    click_on "Change organisation"
  end
end
