require "rails_helper"

RSpec.describe "School Page", type: :system do
  let(:school1) { create(:school, :claims, name: "School1") }
  let(:school2) { create(:school, :claims, name: "School2") }

  scenario "User visits his school" do
    user_exists_in_dfe_sign_in(
      user: given_there_is_an_existing_user_for("Anne"),
    )
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    then_i_see_the_school_details
  end

  scenario "User with multiple schools changes between them" do
    user = given_there_is_an_existing_user_for("Mary")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_multiple_schools(user)
    when_i_visit_the_sign_in_page
    when_i_click_sign_in

    i_go_to_school_details_page("School1")
    then_i_see_the_school_details

    i_click_on_change_organisation
    i_go_to_school_details_page("School2")
    then_i_see_the_school_details
  end

  private

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_sign_in_page
    visit sign_in_path
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

  def then_i_see_the_school_details
    within(".govuk-heading-l") do
      expect(page).to have_content "Organisation details"
    end

    expect(page).to have_content "Additional details"
    expect(page).to have_content "Special educational needs and disabilities (SEND)"
    expect(page).to have_content "Ofsted"
    expect(page).to have_content "Contact details"

    within("#organisation-details") do
      expect(page).to have_content "Organisation name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
    end

    within("#additional-details") do
      expect(page).to have_content "Group"
      expect(page).to have_content "Type"
      expect(page).to have_content "Phase"
      expect(page).to have_content "Gender"
      expect(page).to have_content "Minimum age"
      expect(page).to have_content "Maximum age"
      expect(page).to have_content "Religious character"
      expect(page).to have_content "Admissions policy"
      expect(page).to have_content "Urban or rural"
      expect(page).to have_content "School capacity"
      expect(page).to have_content "Total pupils"
      expect(page).to have_content "Total girls"
      expect(page).to have_content "Total boys"
      expect(page).to have_content "Percentage free school meals"
    end

    within("#send-details") do
      expect(page).to have_content "Special classes"
      expect(page).to have_content "SEND provision"
      expect(page).to have_content "Training with disabilities"
    end

    within("#ofsted-details") do
      expect(page).to have_content "Rating"
      expect(page).to have_content "Last inspection date"
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
