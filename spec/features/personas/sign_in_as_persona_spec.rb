# frozen_string_literal: true

require "rails_helper"

feature "Sign In as Persona" do
  scenario "I sign in as persona Anne" do
    given_there_is_an_existing_persona_for("Anne")
    when_i_visit_the_personas_page
    then_i_see_the_persona_for("Anne")
    when_i_click_sign_in_as("Anne")
    and_i_visit_my_account_page
    then_i_see_persona_details_for_anne
  end
end

private

def given_there_is_an_existing_persona_for(persona_name)
  create(:persona, persona_name.downcase.to_sym)
end

def when_i_visit_the_personas_page
  visit personas_path
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

def then_i_see_persona_details_for_anne
  page_has_persona_content(
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org"
  )
end

def page_has_persona_content(first_name:, last_name:, email:)
  expect(page).to have_content(first_name)
  expect(page).to have_content(last_name)
  expect(page).to have_content(email)
end
