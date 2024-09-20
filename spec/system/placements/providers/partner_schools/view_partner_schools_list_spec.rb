require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / View a list of partner schools",
               service: :placements, type: :system do
  let!(:provider) { create(:placements_provider, name: "Springfield Community College") }
  let!(:another_provider) { create(:placements_provider, name: "Burns University") }
  let!(:school) { create(:placements_school, name: "Springfield Elementary School", urn: "1234") }
  let!(:another_school) { create(:placements_school, name: "Shelbyville Elementary School", urn: "5678") }

  scenario "User views provider partner schools page where provider has no partner schools" do
    given_i_sign_in_as_patricia
    when_i_view_the_partner_schools_page
    then_i_see_the_empty_state
  end

  scenario "User views provider partner schools page where provider has partner schools" do
    given_a_partnership_exists_between(school, provider)
    and_a_partnership_exists_between(another_school, another_provider)
    and_i_sign_in_as_patricia
    when_i_view_the_partner_schools_page
    then_i_see_partner_school(school)
    and_i_cannot_see_partner_school(another_school)
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
  alias_method :and_i_sign_in_as_patricia, :given_i_sign_in_as_patricia

  def when_i_view_the_partner_schools_page
    visit placements_provider_partner_schools_path(provider)

    expect_partner_schools_to_be_selected_in_primary_navigation
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

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
