require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Placements / View placements for partner school",
               service: :placements, type: :system do
  let!(:provider) { create(:placements_provider) }
  let!(:school) { create(:placements_school) }
  let(:placements_partnership) { create(:placements_partnership, school:, provider:) }
  let!(:assigned_placement) { create(:placement, school:, provider:) }
  let!(:unassigned_placement) { create(:placement, school:) }

  before do
    placements_partnership
    given_i_sign_in_as_patricia
  end

  scenario "User views placements for a partner school" do
    when_i_view_the_partner_school_show_page
    then_i_see_the_placements_tab
    when_i_click_on_the_placements_sub_nav
    then_i_see_the_placements_page
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

  def when_i_view_the_partner_school_show_page
    visit placements_provider_partner_school_path(provider, school)
  end

  def then_i_see_the_placements_tab
    expect(page).to have_text("Placements")
  end

  def when_i_click_on_the_placements_sub_nav
    within ".app-secondary-navigation" do
      click_on "Placements"
    end
  end

  def then_i_see_the_placements_page
    within "#placements-assigned-to-you" do
      expect(page).to have_content(assigned_placement.decorate.title)
      expect(page).to have_content("Not yet known")
    end

    within "#other-placements" do
      expect(page).to have_content(unassigned_placement.decorate.title)
      expect(page).to have_content("Available")
    end
  end
end
