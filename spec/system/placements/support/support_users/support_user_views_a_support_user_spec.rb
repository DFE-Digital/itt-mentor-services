require "rails_helper"

RSpec.describe "Placements / Support Users / Support user views a support user", type: :system, service: :placements do
  let!(:support_user) { create(:placements_support_user, :colin) }

  scenario "View a support user" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_a_support_user(support_user)
    i_see_the_details_of_the_support_user(support_user)
  end

  private

  def when_i_sign_in_as_a_support_user(support_user)
    user_exists_in_dfe_sign_in(user: support_user)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def and_i_visit_the_support_users_page
    within(".app-primary-navigation nav") do
      click_on "Users"
    end
  end

  def and_i_click_on_a_support_user(_support_user)
    click_on "Colin Chapman"
  end

  def i_see_the_details_of_the_support_user(_support_user)
    expect(page).to have_selector("h1", text: "Colin Chapman")

    expect(page).to have_content "Colin"
    expect(page).to have_content "Chapman"
    expect(page).to have_content "colin.chapman@education.gov.uk"
  end
end
