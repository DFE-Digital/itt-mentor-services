require "rails_helper"

RSpec.describe "View support users", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user, :colin, created_at: "2024-02-01") }
  let!(:support_user_2) { create(:claims_support_user, created_at: "2024-01-01") }

  scenario "View list of all support users" do
    given_i_sign_in_as(support_user)
    when_i_visit_the_support_users_page
    then_i_see_the_list_of_all_support_users_ordered_by_latest_created_at_first
    and_the_page_title_is("Support users - Claim funding for mentor training - GOV.UK")
  end

  private

  def when_i_visit_the_support_users_page
    within(".app-primary-navigation nav") do
      click_on "Support users"
    end
  end

  def then_i_see_the_list_of_all_support_users_ordered_by_latest_created_at_first
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

  def and_the_page_title_is(title)
    expect(page).to have_title title
  end
end
