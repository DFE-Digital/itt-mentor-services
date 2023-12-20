require "rails_helper"

RSpec.describe "School Page", type: :system do
  scenario "User visits his school" do
    persona = given_there_is_an_existing_persona_for("Mary")
    when_i_visit_home_page
    when_i_click_sign_in(persona)
    when_i_visit_a_school_page
    i_can_see_organisation_details
    i_can_see_contact_details
  end

  private

  def when_i_visit_a_school_page
    visit("/schools/fakeid")
  end

  def when_i_visit_home_page
    visit("/")
  end

  def when_i_click_sign_in(persona)
    click_on "Sign In as #{persona.first_name}"
  end

  def given_there_is_an_existing_persona_for(persona_name)
    user = create(:persona, persona_name.downcase.to_sym, service: "claims")
    create(:membership, user:, organisation: create(:school))
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
end
