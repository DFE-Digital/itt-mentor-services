require "rails_helper"

RSpec.describe "Cookies Page", service: :claims, type: :system do
  scenario "User visits the cookies page" do
    given_i_am_on_the_cookies_page
    then_i_can_see_the_cookies_page
  end

  private

  def given_i_am_on_the_cookies_page
    visit claims_cookies_path
  end

  def then_i_can_see_the_cookies_page
    within(".govuk-heading-l") do
      expect(page).to have_content("Cookies on Claim funding for mentor training")
    end
  end
end
