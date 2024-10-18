require "rails_helper"

RSpec.describe "Placements / Support Users / Support user views a support user", service: :placements, type: :system do
  let!(:support_user) { create(:placements_support_user) }

  scenario "View a support user" do
    given_i_am_signed_in_as_a_placements_support_user
    and_i_visit_the_support_users_page
    and_i_click_on_a_support_user(support_user)
    i_see_the_details_of_the_support_user(support_user)
  end

  private

  def and_i_visit_the_support_users_page
    within(".govuk-header__navigation-list") do
      click_on "Support users"
    end
  end

  def and_i_click_on_a_support_user(support_user)
    click_on support_user.full_name
  end

  def i_see_the_details_of_the_support_user(support_user)
    expect(page).to have_selector("h1", text: support_user.full_name)

    expect(page).to have_content support_user.first_name
    expect(page).to have_content support_user.last_name
    expect(page).to have_content support_user.email
  end
end
