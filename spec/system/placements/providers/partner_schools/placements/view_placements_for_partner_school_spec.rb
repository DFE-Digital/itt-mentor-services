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
    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
  end

  scenario "User views placements for a partner school" do
    when_i_view_the_partner_school_show_page
    then_i_see_the_placements_tab
    when_i_click_on_the_placements_sub_nav
    then_i_see_the_placements_page
  end

  private
  
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
