require "rails_helper"

RSpec.describe "Placements / Support / Schools / Partner providers / View partner provider list as support user",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school, name: "Springfield Elementary School") }
  let!(:another_school) { create(:placements_school, name: "Shelbyville Elementary School") }
  let!(:provider) { create(:placements_provider, name: "Springfield Community College", ukprn: "1234") }
  let!(:another_provider) { create(:placements_provider, name: "Burns University", ukprn: "5678") }

  before do
    given_i_am_signed_in_as_a_placements_support_user
  end

  scenario "Support user views school partner providers page where school has no partner providers" do
    when_i_visit_the_partner_providers_page_for(school)
    then_i_see_the_empty_state
  end

  scenario "Support user views school partner providers page where school has partner providers" do
    given_a_partnership_exists_between(school, provider)
    and_a_partnership_exists_between(another_school, another_provider)
    when_i_visit_the_partner_providers_page_for(school)
    then_i_see_partner_provider(provider)
    and_i_cannot_see_partner_provider(another_provider)
  end

  private

  def when_i_visit_the_partner_providers_page_for(school)
    visit placements_school_partner_providers_path(school)

    then_i_see_support_navigation_with_organisation_selected
    partner_providers_is_selected_in_secondary_nav
  end

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

  def then_i_see_the_empty_state
    expect(page).to have_content "There are no providers for #{school.name}"
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
end
