require "rails_helper"

RSpec.describe "View organisations", type: :system do
  around do |example|
    Capybara.app_host = "http://#{ENV["CLAIMS_HOST"]}"
    example.run
    Capybara.app_host = nil
  end

  scenario "I sign in as persona Mary with multiple organistions" do
    persona = given_the_claims_persona("Mary")
    and_persona_has_multiple_organisations(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    i_can_see_a_list_marys_claims_organisations(persona)
  end

  scenario "I sign in as persona Anne with one organisation" do
    persona = given_the_claims_persona("Anne")
    and_persona_has_one_organisation(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    i_am_redirected_to_the_root_path
  end
end

private

def given_the_claims_persona(persona_name)
  create(:persona, persona_name.downcase.to_sym, service: "claims")
end

def and_persona_has_multiple_organisations(persona)
  school1 = create(:school)
  school2 = create(:school)
  create(:membership, user: persona, organisation: school1)
  create(:membership, user: persona, organisation: school2)
end

def and_persona_has_one_organisation(persona)
  create(:membership, user: persona, organisation: create(:school))
end

def when_i_visit_claims_personas
  visit personas_path
end

def when_i_click_sign_in(persona)
  click_on "Sign In as #{persona.first_name}"
end

def i_can_see_a_list_marys_claims_organisations(persona)
  expect(page).to have_content("Organisations")
  expect(page).to have_content(persona.schools.first.name)
  expect(page).to have_content(persona.schools.last.name)
end

def i_am_redirected_to_the_root_path
  expect(page).to have_content("It works!")
end
