require "rails_helper"

RSpec.describe "View View components", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "User visits the view components page" do
    when_i_visit_the_view_components_page
    then_i_can_see_the_list_of_claims_view_component_templates
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_view_components_page
    click_on "Settings"
    click_on "View components"
  end

  def then_i_can_see_the_list_of_claims_view_component_templates
    expect(page).to have_content("Claim/Card Component")
    expect(page).to have_link("default (opens in new tab)", href: "/rails/view_components/claim/card_component/default")

    expect(page).to have_content("Claim/Mentor Training Form/Disclaimer Component")
    expect(page).to have_link("default (opens in new tab)", href: "/rails/view_components/claims/claim/mentor_training_form/disclaimer_component/default")
  end
end
