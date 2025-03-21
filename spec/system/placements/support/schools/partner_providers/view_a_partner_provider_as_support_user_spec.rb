require "rails_helper"

RSpec.describe "Placements / Support / Schools / Partner providers / View a partner provider as support user",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider, name: "Provider 1") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }

  before do
    partnership
    given_i_am_signed_in_as_a_placements_support_user
  end

  scenario "Support user views a school partner provider" do
    when_i_visit_the_partner_providers_page_for(school)
    and_i_click_on("Provider 1")
    then_i_see_the_details_of(provider)
  end

  private

  def when_i_visit_the_partner_providers_page_for(school)
    visit placements_school_partner_providers_path(school)

    then_i_see_support_navigation_with_organisation_selected
    partner_providers_is_selected_in_secondary_nav
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_providers_is_selected_in_secondary_nav
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Providers", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
    end
  end

  def then_i_see_the_details_of(provider)
    within(".govuk-heading-l") do
      expect(page).to have_content provider.name
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
end
