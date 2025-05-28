require "rails_helper"

RSpec.describe "Signed out user accesses the service", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_i_visit_the_placements_page
    then_i_am_redirected_to_the_sign_in_page
  end

  private

  def given_a_school_exists
    @school = create(:placements_school, name: "Hogwarts")
  end

  def and_i_visit_the_placements_page
    # The user is not authenticated and therefore there is no link to click
    visit placements_school_placements_path(@school)
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_h1("Sign in to Manage school placements")
    expect(page).to have_element(:button, text: "Sign in using DfE Sign In", class: "govuk-button")
  end
end
