require "rails_helper"

RSpec.describe "Accepting grant conditions", service: :claims, type: :system do
  let(:grant_conditons_accepted_school) { create(:claims_school, :claims, urn: "123456") }
  let(:grant_conditons_not_accepted_school) { create(:claims_school, urn: "123457", grant_conditions_accepted: false) }

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

  scenario "School accepted the grant conditions for a previous academic year" do
    given_the_school_accepted_the_grant_conditions_last_academic_year
    user_exists_in_dfe_sign_in(user: another_anne)
    given_i_sign_in
    then_i_can_see_the_grant_conditions_page
    then_i_accept_the_grant_conditions
    click_on "Organisation details"
    then_i_see_i_agreed_to_the_grant_conditions_this_academic_year
  end

  scenario "A claim window for a future academic year has been created but has not opened" do
    given_a_claim_window_for_a_future_academic_year_has_been_created
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    then_i_can_see_the_schools_claims_page
  end

  scenario "A claim window for a new academic year opens" do
    given_a_claim_window_for_a_new_academic_year_has_opened
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    then_i_can_see_the_grant_conditions_page_for(grant_conditons_accepted_school)
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

  def given_a_claim_window_for_a_future_academic_year_has_been_created
    grant_conditons_accepted_school
    create(:claim_window, :upcoming, academic_year: AcademicYear.current.next)
  end

  def given_a_claim_window_for_a_new_academic_year_has_opened
    grant_conditons_accepted_school
    create(:claim_window, :current, academic_year: AcademicYear.current)
  end

  def then_i_can_see_the_grant_conditions_page_for(school)
    expect(page).to have_current_path(claims_school_grant_conditions_path(school_id: school), ignore_query: true)
    expect(page).to have_content("Grant conditions")
  end

  def then_i_can_see_the_grant_conditions_page
    expect(page).to have_current_path(claims_school_grant_conditions_path(school_id: grant_conditons_not_accepted_school), ignore_query: true)
    expect(page).to have_content("Grant conditions")
  end

  def given_the_school_accepted_the_grant_conditions_last_academic_year
    create(
      :grant_conditions_acceptance,
      school: grant_conditons_not_accepted_school,
      academic_year: grant_conditons_not_accepted_school.grant_conditions_academic_year.previous,
      accepted_by: create(:claims_user, first_name: "George", last_name: "Barlow"),
      accepted_at: 1.year.ago,
    )
  end

  def then_i_see_i_agreed_to_the_grant_conditions_this_academic_year
    expect(page).to have_summary_list_row("Agreed for", "#{grant_conditons_not_accepted_school.grant_conditions_academic_year.name} academic year")
    expect(page).to have_summary_list_row("Agreed by", "Anne Wilson")
    expect(page).to have_summary_list_row("Agreed on", I18n.l(Date.current, format: :long))
  end

  def then_i_accept_the_grant_conditions
    click_on "Accept grant conditions"
    expect(page).to have_content("Claims")
  end
end
