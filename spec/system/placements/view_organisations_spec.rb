require "rails_helper"

RSpec.describe "View organisations", type: :system do
  let(:placements_gias_school) { create(:gias_school, name: "Placements School") }
  let(:placements_school) { create(:school, gias_school: placements_gias_school) }
  let(:placement_provider) { create(:provider, name: "Plaements Provider") }
  let(:random_school) { create(:school) }
  let(:random_provider) { create(:provider) }

  around do |example|
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
    example.run
    Capybara.app_host = nil
  end

  scenario "I sign in as persona Mary with multiple organistions" do
    given_the_placements_persona("Mary")
    and_persona_has_multiple_organisations
    when_i_visit_placements_personas
    when_i_click_sign_in_as("Mary")
    i_am_redirected_to_organisation_index
  end

  scenario "I sign in as persona Anne with one organisation" do
    given_the_placements_persona("Anne")
    and_persona_has_one_organisation
    when_i_visit_placements_personas
    when_i_click_sign_in_as("Anne")
    i_am_redirected_to_organisation_index
  end

  private

  def persona(persona_name)
    @persona ||= create(:persona, persona_name.downcase.to_sym, service: "placements")
  end

  def given_the_placements_persona(persona_name)
    persona(persona_name)
  end

  def and_persona_has_multiple_organisations
    school = create(:school, name: "Placements School")
    provider = create(:provider, name: "Provider 1")
    create(:membership, user: @persona, organisation: school)
    create(:membership, user: @persona, organisation: provider)
  end

  def and_persona_has_one_organisation
    create(:membership, user: @persona, organisation: create(:school))
  end

  def when_i_visit_placements_personas
    visit personas_path
  end

  def when_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def i_am_redirected_to_organisation_index
    expect(page).to have_content("Organisations")
    expect(page).to have_content("Schools")

    @persona.schools.each do |school|
      expect(page).to have_content(school.name)
    end

    expect(page).to have_content("Providers") if @persona.providers.any?

    @persona.providers.each do |provider|
      expect(page).to have_content(provider.name)
    end
  end
end
