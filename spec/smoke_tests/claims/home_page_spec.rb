require "smoke_tests/smoke_test_helper"

RSpec.describe "Home Page", :smoke_test, service: :claims, type: :system do
  it "User visits the claims homepage" do
    given_i_am_on_the_start_page
    i_can_see_the_claims_service_name_in_the_header
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_claims_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Claim funding for mentor training")
    end
  end
end
