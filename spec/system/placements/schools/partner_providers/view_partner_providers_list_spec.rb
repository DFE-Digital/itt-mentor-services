require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / View a list of partner providers",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school, name: "Springfield Elementary School") }
  let!(:another_school) { create(:placements_school, name: "Shelbyville Elementary School") }
  let!(:provider) { create(:placements_provider, name: "Springfield Community College", ukprn: "1234") }
  let!(:another_provider) { create(:placements_provider, name: "Burns University", ukprn: "5678") }

  scenario "User views school partner providers page where school has no partner providers" do
    given_i_sign_in_as_anne
    when_i_view_the_partner_providers_page
    then_i_see_the_empty_state
  end

  scenario "User views school partner providers page where school has partner providers" do
    given_a_partnership_exists_between(school, provider)
    and_a_partnership_exists_between(another_school, another_provider)
    and_i_sign_in_as_anne
    when_i_view_the_partner_providers_page
    then_i_see_partner_provider(provider)
    and_i_cannot_see_partner_provider(another_provider)
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
  alias_method :and_i_sign_in_as_anne, :given_i_sign_in_as_anne

  def when_i_view_the_partner_providers_page
    visit placements_school_partner_providers_path(school)

    expect_partner_providers_to_be_selected_in_primary_navigation
  end

  def then_i_see_the_empty_state
    expect(page).to have_content "There are no partner providers for #{school.name}"
  end

  def given_a_partnership_exists_between(school, provider)
    create(:placements_partnership, school:, provider:)
  end
  alias_method :and_a_partnership_exists_between, :given_a_partnership_exists_between

  def then_i_see_partner_provider(provider)
    expect(page).to have_content(provider.name)
    expect(page).to have_content(provider.ukprn)
  end

  def and_i_cannot_see_partner_provider(provider)
    expect(page).not_to have_content(provider.name)
    expect(page).not_to have_content(provider.ukprn)
  end

  def expect_partner_providers_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Partner providers", current: "page"
    end
  end
end
