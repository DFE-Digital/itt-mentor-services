require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / Views a partner provider",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider) }
  let(:partnership) { create(:placements_partnership, school:, provider:) }

  before { partnership }

  scenario "User views a school partner provider" do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    when_i_view_the_partner_provider_show_page
    then_i_see_the_details_of(provider)
  end

  private

  def when_i_view_the_partner_provider_show_page
    visit placements_school_partner_provider_path(school, provider)

    expect_partner_providers_to_be_selected_in_primary_navigation
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
      expect(page).to have_content "Telephone"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end
  end

  def expect_partner_providers_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Providers", current: "page"
    end
  end
end
