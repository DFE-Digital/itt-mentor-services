require "smoke_tests/smoke_test_helper"

RSpec.describe "Home Page", :smoke_test, service: :claims, type: :system do
  it "User visits the claims homepage" do
    given_i_am_on_the_start_page
    i_can_see_the_dfe_logo_in_the_header
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_dfe_logo_in_the_header
    within ".govuk-header__logo" do
      expect(page).to have_css('a.govuk-header__link.govuk-header__link--homepage[href="/"]')

      expect(page).to have_css(
        'img.govuk-header__logotype[alt="Department for Education"][src$="department-for-education_white.png"]',
        visible: :all,
      )
    end
  end
end
