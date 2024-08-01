require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Placements / View a placement for partner school",
               service: :placements, type: :system do
  let!(:provider) { create(:placements_provider) }
  let!(:school) { create(:placements_school, phase: :primary, rating: "Good") }
  let(:placements_partnership) { create(:placements_partnership, school:, provider:) }
  let!(:assigned_placement) { create(:placement, school:, provider:) }

  before do
    placements_partnership
    given_i_sign_in_as_patricia
  end

  scenario "User views a placement for a partner school" do
    when_i_view_the_partner_school_placements_page
    and_i_click_on_a_placement(assigned_placement)
    then_i_see_the_placement_details_page
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_view_the_partner_school_placements_page
    visit placements_provider_partner_school_placements_path(provider, school)
  end

  def and_i_click_on_a_placement(placement)
    click_on placement.decorate.title
  end

  def when_i_click_on_the_placements_sub_nav
    within ".app-secondary-navigation" do
      click_on "Placements"
    end
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_content(assigned_placement.decorate.title)
    expect(page).to have_content(school.rating)
    expect(page).to have_content(school.phase)
  end
end
