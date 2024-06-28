require "rails_helper"

RSpec.describe "Terms Page", service: :claims, type: :system do
  scenario "User visits the terms page" do
    given_i_am_on_the_terms_page
    then_i_can_see_the_terms_page
  end

  private

  def given_i_am_on_the_terms_page
    visit claims_terms_path
  end

  def then_i_can_see_the_terms_page
    within(".govuk-heading-l") do
      expect(page).to have_content("Terms and conditions")
    end
  end
end
