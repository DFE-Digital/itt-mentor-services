require "rails_helper"

RSpec.describe "View Emails", service: :placements, type: :system do
  let(:support_user) { create(:placements_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "User visits the emails page" do
    when_i_visit_the_emails_page
    then_i_can_see_the_list_of_placements_email_templates
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_emails_page
    click_on "Settings"
    click_on "View components"
  end

  def then_i_can_see_the_list_of_placements_email_templates
    expect(page).to have_content("Placement/Status Tag Component")
    expect(page).to have_link("default (opens in new tab)", href: "/rails/view_components/placement/status_tag_component/default")

    expect(page).to have_content("Placement/Summary Component")
    expect(page).to have_link("default (opens in new tab)", href: "/rails/view_components/placement/summary_component/default")
  end
end
