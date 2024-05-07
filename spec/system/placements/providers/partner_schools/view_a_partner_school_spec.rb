require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Views a partner school",
               type: :system,
               service: :placements do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider) }
  let(:partnership) { create(:placements_partnership, school:, provider:) }

  before { partnership }

  scenario "User views a provider partner school" do
    given_i_sign_in_as_patricia
    when_i_view_the_partner_school_show_page
    then_i_see_the_details_of(school)
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

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
    expect(page).to have_content "Contact details"

    within("#organisation-details") do
      expect(page).to have_content "Organisation name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
    end

    within("#additional-details") do
      expect(page).to have_content "Group"
      expect(page).to have_content "Type"
      expect(page).to have_content "Phase"
      expect(page).to have_content "Gender"
      expect(page).to have_content "Minimum age"
      expect(page).to have_content "Maximum age"
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
      expect(page).to have_content "Training with disabilities"
    end

    within("#ofsted-details") do
      expect(page).to have_content "Rating"
      expect(page).to have_content "Last inspection date"
    end

    within("#contact-details") do
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone number"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end
  end

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
