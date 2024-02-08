require "rails_helper"

RSpec.describe "View support console as a non support user", type: :system, service: :claims do
  let(:school1) { create(:school, :claims, name: "School1") }

  scenario "As a non support user I cant access a support page" do
    user_exists_in_dfe_sign_in(
      user: given_there_is_an_existing_user_for("Anne"),
    )
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    when_i_visit_a_support_page
    then_i_am_unable_to_access_the_page
  end

  private

  def when_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_an_existing_user_for(user_name)
    user = create(:claims_user, user_name.downcase.to_sym)
    create(:membership, user:, organisation: school1)
    user
  end

  def when_i_visit_a_support_page
    visit claims_support_root_path
  end

  def then_i_am_unable_to_access_the_page
    expect(page).to have_content("You cannot perform this action")
  end
end
