require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / View a partner school as support user",
               service: :placements, type: :system do
  let!(:provider) { create(:placements_provider, name: "Springfield Community College") }
  let!(:another_provider) { create(:placements_provider, name: "Burns University") }
  let!(:school) { create(:placements_school, name: "Springfield Elementary School", urn: "1234") }
  let!(:another_school) { create(:placements_school, name: "Shelbyville Elementary School", urn: "5678") }

  before do
    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user views provider partner schools page for a provider with no partner schools" do
    when_i_visit_the_partner_schools_page_for(provider)
    then_i_see_the_empty_state
  end

  scenario "Support user views provider partner schools page for a provider with partner schools" do
    given_a_partnership_exists_between(school, provider)
    and_a_partnership_exists_between(another_school, another_provider)
    when_i_visit_the_partner_schools_page_for(provider)
    then_i_see_partner_school(school)
    and_i_cannot_see_partner_school(another_school)
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_partner_schools_page_for(provider)
    visit placements_provider_partner_schools_path(provider)

    then_i_see_support_navigation_with_organisation_selected
    partner_schools_is_selected_in_secondary_nav
  end

  def then_i_see_the_empty_state
    expect(page).to have_content "There are no partner schools for #{provider.name}"
  end

  def given_a_partnership_exists_between(school, provider)
    create(:placements_partnership, school:, provider:)
  end
  alias_method :and_a_partnership_exists_between, :given_a_partnership_exists_between

  def then_i_see_partner_school(school)
    expect(page).to have_content(school.name)
    expect(page).to have_content(school.urn)
  end

  def and_i_cannot_see_partner_school(school)
    expect(page).not_to have_content(school.name)
    expect(page).not_to have_content(school.urn)
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Schools", current: "page"
    end
  end
end
