require "rails_helper"

RSpec.describe "School Page", type: :system do
  scenario "User visits his school" do
    persona = given_there_is_an_existing_persona_for("Anne")
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    i_can_see_organisation_details
    i_can_see_contact_details
  end

  scenario "User with multiple schools changes between them" do
    persona = given_the_claims_persona("Mary")
    and_persona_has_multiple_schools(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)

    i_go_to_school_details_page("School1")
    i_can_see_organisation_details
    i_can_see_contact_details

    i_click_on_change_organisation
    i_go_to_school_details_page("School2")
    i_can_see_organisation_details
    i_can_see_contact_details
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
    school1 = create(:school, :claims, name: "School1")
    school2 = create(:school, :claims, name: "School2")
    create(:membership, user: persona, organisation: school1)
    create(:membership, user: persona, organisation: school2)
  end

  def given_there_is_an_existing_persona_for(persona_name)
    user = create(:persona, persona_name.downcase.to_sym, service: "claims")
    create(:membership, user:, organisation: create(:school, :claims))
    user
  end

  def i_can_see_organisation_details
    expect(page).to have_css(".govuk-summary-list__value", text: "Hogwarts")
    expect(page).to have_css(".govuk-summary-list__value", text: "fake_uprn")
    expect(page).to have_css(".govuk-summary-list__value", text: 1)
  end

  def i_can_see_contact_details
    expect(page).to have_css(".govuk-summary-list__value", text: "mary@example.com")
    expect(page).to have_css(".govuk-summary-list__value", text: "0123456789")
    expect(page).to have_css(".govuk-summary-list__value", text: "www.hogwarts.com")
    expect(page).to have_css(".govuk-summary-list__value", text: "Hogwarts Castle")
    expect(page).to have_css(".govuk-summary-list__value", text: "Scotland")
    expect(page).to have_css(".govuk-summary-list__value", text: "United Kingdom")
  end

  def i_go_to_school_details_page(school_name)
    click_on school_name
  end

  def i_click_on_change_organisation
    click_on "Change organisation"
  end
end
