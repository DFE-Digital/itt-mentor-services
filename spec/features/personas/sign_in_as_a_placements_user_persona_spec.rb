# frozen_string_literal: true

require "rails_helper"

feature "Sign In as a Placements User Persona" do
  around do |example|
    Capybara.app_host = "https://#{ENV["PLACEMENTS_HOST"]}"
    example.run
    Capybara.app_host = nil
  end

  scenario "I sign in as persona Anne" do
    given_there_is_an_existing_persona_for("Anne")
    when_i_visit_the_personas_page
    then_i_see_the_persona_for("Anne")
    when_i_click_sign_in_as("Anne")
    and_i_visit_my_account_page
    then_i_see_persona_details_for_anne
  end

  scenario "I sign in as persona Patricia" do
    given_there_is_an_existing_persona_for("Patricia")
    when_i_visit_the_personas_page
    then_i_see_the_persona_for("Patricia")
    when_i_click_sign_in_as("Patricia")
    and_i_visit_my_account_page
    then_i_see_persona_details_for_patricia
  end

  scenario "I sign in as persona Mary" do
    given_there_is_an_existing_persona_for("Mary")
    when_i_visit_the_personas_page
    then_i_see_the_persona_for("Mary")
    when_i_click_sign_in_as("Mary")
    and_i_visit_my_account_page
    then_i_see_persona_details_for_mary
  end

  scenario "I sign in as support user persona Colin" do
    given_there_is_an_existing_persona_for("Colin")
    and_there_are_placement_organisations
    when_i_visit_the_personas_page
    then_i_see_the_persona_for("Colin")
    when_i_click_sign_in_as("Colin")
    then_i_see_a_list_of_organisations

    and_i_visit_my_account_page
    then_i_see_persona_details_for_colin
  end
end

private

def given_there_is_an_existing_persona_for(persona_name)
  create(:persona, persona_name.downcase.to_sym, service: "placements")
end

def when_i_visit_the_personas_page
  visit personas_path
end

def and_there_are_placement_organisations
  create(:gias_school, name: "Placement School")
  create(:school, :placements)
  create(:provider, id: 123_456_789)
end

def then_i_see_the_persona_for(persona_name)
  expect(page).to have_content(persona_name)
end

def when_i_click_sign_in_as(persona_name)
  click_on "Sign In as #{persona_name}"
end

def and_i_visit_my_account_page
  visit account_path
end

def then_i_see_a_list_of_organisations
  expect(path).to eq dashboard_path
  expect(page).to have_content("Placements School")
  # We won't have a name or data for the providers until after the Provider API integration is done
  expect(page).to have_content("123456789")
end

def then_i_see_persona_details_for_anne
  page_has_persona_content(
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org"
  )
end

def then_i_see_persona_details_for_patricia
  page_has_persona_content(
    first_name: "Patricia",
    last_name: "Adebayo",
    email: "patricia@example.com"
  )
end

def then_i_see_persona_details_for_mary
  page_has_persona_content(
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com"
  )
end

def then_i_see_persona_details_for_colin
  page_has_persona_content(
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin@example.com"
  )
end

def page_has_persona_content(first_name:, last_name:, email:)
  expect(page).to have_content(first_name)
  expect(page).to have_content(last_name)
  expect(page).to have_content(email)
end
