require "rails_helper"

RSpec.describe "School Page", type: :system do
  let(:school1) { create(:school, :claims, name: "School1") }
  let(:school2) { create(:school, :claims, name: "School2") }

  scenario "User visits his school" do
    persona = given_there_is_an_existing_persona_for("Anne")
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    then_i_see_the_school_details
  end

  scenario "User with multiple schools changes between them" do
    persona = given_the_claims_persona("Mary")
    and_persona_has_multiple_schools(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)

    i_go_to_school_details_page("School1")
    then_i_see_the_school_details

    i_click_on_change_organisation
    i_go_to_school_details_page("School2")
    then_i_see_the_school_details
  end

  private

  def when_i_click_sign_in(persona)
    click_on "Sign In as #{persona.first_name}"
  end

  def when_i_visit_claims_personas
    visit personas_path
  end

  def given_the_claims_persona(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: "claims")
  end

  def and_persona_has_multiple_schools(persona)
    create(:membership, user: persona, organisation: school1)
    create(:membership, user: persona, organisation: school2)
  end

  def given_there_is_an_existing_persona_for(persona_name)
    user = create(:persona, persona_name.downcase.to_sym, service: "claims")
    create(:membership, user:, organisation: school1)
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

    within("#school-details") do
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
