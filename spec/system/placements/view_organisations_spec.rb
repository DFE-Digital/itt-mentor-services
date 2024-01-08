require "rails_helper"

RSpec.describe "View organisations", type: :system do
  around do |example|
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
    example.run
    Capybara.app_host = nil
  end

  scenario "I sign in as persona Mary with multiple organistions" do
    persona = given_the_placements_persona("Mary")
    and_persona_has_multiple_organisations(persona)
    when_i_visit_placements_personas
    when_i_click_sign_in(persona)
    i_am_redirected_to_organisation_index(persona)
  end

  scenario "I sign in as persona Anne with one organisation" do
    persona = given_the_placements_persona("Anne")
    and_persona_has_one_organisation(persona)
    when_i_visit_placements_personas
    when_i_click_sign_in(persona)
    i_am_redirected_to_organisation_index(persona)
  end

  private

  def given_the_placements_persona(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: "placements")
  end

  def and_persona_has_multiple_organisations(persona)
    school1 = create(:school)
    provider = create(:provider)
    create(:membership, user: persona, organisation: school1)
    create(:membership, user: persona, organisation: provider)
  end

  def and_persona_has_one_organisation(persona)
    create(:membership, user: persona, organisation: create(:school))
  end

  def when_i_visit_placements_personas
    visit personas_path
  end

  def when_i_click_sign_in(persona)
    click_on "Sign In as #{persona.first_name}"
  end

  def i_am_redirected_to_organisation_index(persona)
    expect(page).to have_content("Organisations")
    expect(page).to have_content("Schools")

    persona.schools.each do |school|
      expect(page).to have_content(school.name)
    end

    expect(page).to have_content("Providers") if persona.providers.any?

    persona.providers.each do |provider|
      expect(page).to have_content(provider.provider_code)
    end
  end
end
