require "rails_helper"

RSpec.describe "Accessibility Page", type: :system, service: :claims do
  scenario "User visits the accessibility page" do
    given_i_am_on_the_accessibility_page
    then_i_can_see_the_accessibility_page
  end

  private

  def given_i_am_on_the_accessibility_page
    visit claims_accessibility_path
  end

  def then_i_can_see_the_accessibility_page
    within(".govuk-heading-l") do
      expect(page).to have_content("Accessibility statement for Claim funding for mentor training")
    end
  end
end
