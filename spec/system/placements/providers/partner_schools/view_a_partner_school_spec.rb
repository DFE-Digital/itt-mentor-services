require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Views a partner school",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider) }
  let(:partnership) { create(:placements_partnership, school:, provider:) }

  before { partnership }

  scenario "User views a provider partner school" do
    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
    when_i_view_the_partner_school_show_page
    then_i_see_the_details_of(school)
  end

  private

  def when_i_view_the_partner_school_show_page
    visit placements_provider_partner_school_path(provider, school)

    expect_partner_schools_to_be_selected_in_primary_navigation
  end

  def then_i_see_the_details_of(school)
    within(".govuk-heading-l") do
      expect(page).to have_content school.name
    end

    expect(page).to have_content "Additional details"
    expect(page).to have_content "Special educational needs and disabilities (SEND)"
    expect(page).to have_content "Ofsted"

    within("#organisation-details") do
      expect(page).to have_content "Name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone number"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end

    within("#additional-details") do
      expect(page).to have_content "Establishment group"
      expect(page).to have_content "Phase"
      expect(page).to have_content "Gender"
      expect(page).to have_content "Age range"
      expect(page).to have_content "Religious character"
      expect(page).to have_content "Admissions policy"
      expect(page).to have_content "Urban or rural"
      expect(page).to have_content "School capacity"
      expect(page).to have_content "Total pupils"
      expect(page).to have_content "Total girls"
      expect(page).to have_content "Total boys"
      expect(page).to have_content "Percentage free school meals"
    end

    within("#send-details") do
      expect(page).to have_content "Special classes"
      expect(page).to have_content "SEND provision"
    end

    within("#ofsted-details") do
      expect(page).to have_content "Rating"
      expect(page).to have_content "Last inspection date"
    end
  end

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Find", current: "false"
      expect(page).to have_link "My placements", current: "false"
      expect(page).to have_link "Schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
