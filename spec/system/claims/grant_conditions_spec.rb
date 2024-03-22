require "rails_helper"

RSpec.describe "Grant conditions Page", type: :system, service: :claims do
  scenario "User visits the grant conditions page" do
    given_i_am_on_the_grant_conditions_page
    then_i_can_see_the_grant_conditions_page
  end

  private

  def given_i_am_on_the_grant_conditions_page
    visit claims_grant_conditions_path
  end

  def then_i_can_see_the_grant_conditions_page
    within(".govuk-heading-l") do
      expect(page).to have_content("General mentor training conditions of grant for early adopters")
    end
  end
end
