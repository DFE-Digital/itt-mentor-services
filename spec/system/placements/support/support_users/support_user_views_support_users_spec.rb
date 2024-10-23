require "rails_helper"

RSpec.describe "Placements / Support Users / Support user views support users",
               service: :placements, type: :system do
  let!(:support_user) { create(:placements_support_user, :colin, created_at: "2024-02-01") }
  let!(:support_user_2) { create(:placements_support_user, created_at: "2024-01-01") }

  scenario "View list of all support users" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_support_users_page
    i_see_the_list_of_all_support_users_ordered_by_latest_created_at_first
  end

  private

  def and_i_visit_the_support_users_page
    within(".govuk-header__navigation-list") do
      click_on "Support users"
    end
  end

  def i_see_the_list_of_all_support_users_ordered_by_latest_created_at_first
    expect(page).to have_selector("tbody tr", count: 2)

    within("tbody tr:nth-child(1)") do
      expect(page).to have_selector("td", text: support_user.full_name)
      expect(page).to have_selector("td", text: support_user.email)
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_selector("td", text: support_user_2.full_name)
      expect(page).to have_selector("td", text: support_user_2.email)
    end
  end
end
