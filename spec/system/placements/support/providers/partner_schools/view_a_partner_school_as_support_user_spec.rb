require "rails_helper"

RSpec.describe "Placements / Support/ Providers / Partner schools / View a partner school as support user",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school, name: "School 1") }
  let!(:provider) { create(:placements_provider) }
  let(:partnership) { create(:placements_partnership, school:, provider:) }

  before do
    partnership
    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support User views a provider partner school" do
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("School 1")
    then_i_see_the_details_for(school)
  end

  private

  def when_i_visit_the_partner_schools_page_for(provider)
    visit placements_support_provider_partner_schools_path(provider)

    then_i_see_support_navigation_with_organisation_selected
    partner_schools_is_selected_in_secondary_nav
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_see_the_details_for(school)
    within(".govuk-heading-l") do
      expect(page).to have_content school.name
    end

    within("#organisation-details") do
      expect(page).to have_content "Name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone number"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
    end
  end
end
