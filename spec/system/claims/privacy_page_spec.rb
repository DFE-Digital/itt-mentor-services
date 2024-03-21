require "rails_helper"

RSpec.describe "Privacy Page", type: :system, service: :claims do
  scenario "User visits the privacy page" do
    given_i_am_on_the_privacy_page
    then_i_can_see_the_privacy_page
  end

  private

  def given_i_am_on_the_privacy_page
    visit claims_privacy_path
  end

  def then_i_can_see_the_privacy_page
    within(".govuk-heading-l") do
      expect(page).to have_content("Claim funding for mentor training privacy notice")
    end
  end
end
