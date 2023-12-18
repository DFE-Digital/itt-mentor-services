# frozen_string_literal: true

require "rails_helper"

feature "Attempting to sign in without a service specified" do
  scenario "I sign in as persona Anne" do
    given_there_is_an_existing_persona
    when_i_visit_the_personas_page
    then_i_see_a_404_error_page
  end

  private

  def given_there_is_an_existing_persona
    create(:persona)
  end

  def when_i_visit_the_personas_page
    visit personas_path
  end

  def then_i_see_a_404_error_page
    expect(page).to have_content "Page not found"
  end
end
