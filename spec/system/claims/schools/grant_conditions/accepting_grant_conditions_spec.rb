require "rails_helper"

RSpec.describe "Accepting grant conditions", service: :claims, type: :system do
  let(:grant_conditons_accepted_school) { create(:claims_school, :claims, urn: "123456") }
  let(:grant_conditons_not_accepted_school) { create(:claims_school, :claims, urn: "123457", claims_grant_conditions_accepted_at: nil) }

  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: grant_conditons_accepted_school)],
    )
  end

  let(:another_anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: grant_conditons_not_accepted_school)],
    )
  end

  scenario "School has already accepted the grant conditions" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    then_i_can_see_the_schools_claims_page
    click_on "Organisation details"
    expect(page).to have_content("Organisation details")
  end

  scenario "School has NOT accepted the grant conditions" do
    user_exists_in_dfe_sign_in(user: another_anne)
    given_i_sign_in
    then_i_can_see_the_grant_conditions_page
  end

  scenario "School accepts the grant conditions" do
    user_exists_in_dfe_sign_in(user: another_anne)
    given_i_sign_in
    then_i_can_see_the_grant_conditions_page
    then_i_accept_the_grant_conditions
  end

  scenario "School has NOT accepted the grant conditions so cant visit the school related pages" do
    user_exists_in_dfe_sign_in(user: another_anne)
    given_i_sign_in
    visit claims_school_path(grant_conditons_not_accepted_school)
    then_i_can_see_the_grant_conditions_page
    visit claims_school_claims_path(grant_conditons_not_accepted_school)
    then_i_can_see_the_grant_conditions_page
    visit claims_school_mentors_path(grant_conditons_not_accepted_school)
    then_i_can_see_the_grant_conditions_page
    visit claims_school_users_path(grant_conditons_not_accepted_school)
    then_i_can_see_the_grant_conditions_page
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def then_i_can_see_the_schools_claims_page
    expect(page).to have_current_path(claims_school_claims_path(school_id: grant_conditons_accepted_school), ignore_query: true)
    expect(page).to have_content("Claims")
  end

  def then_i_can_see_the_grant_conditions_page
    expect(page).to have_current_path(claims_school_grant_conditions_path(school_id: grant_conditons_not_accepted_school), ignore_query: true)
    expect(page).to have_content("Grant conditions")
  end

  def then_i_accept_the_grant_conditions
    click_on "Accept grant conditions"
    expect(page).to have_content("Claims")
  end
end
