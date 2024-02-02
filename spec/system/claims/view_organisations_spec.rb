require "rails_helper"

RSpec.describe "View schools", type: :system, service: :claims do
  scenario "I sign in as Mary with multiple schools" do
    user = given_the_claims_user("Mary")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_multiple_schools(user)
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    and_i_see_marys_schools
  end

  scenario "I sign in as Anne with one school" do
    user = given_the_claims_user("Anne")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_school(user)
    when_i_visit_the_sign_in_page
    when_i_click_sign_in
    and_i_see_annes_schools
  end

  private

  def given_the_claims_user(user_name)
    create(:claims_user, user_name.downcase.to_sym)
  end

  def and_user_has_multiple_schools(user)
    @school1 = create(:claims_school)
    @school2 = create(:claims_school)
    create(:membership, user:, organisation: @school1)
    create(:membership, user:, organisation: @school2)
  end

  def and_i_see_marys_schools
    expect(page).to have_content "Organisations"
    expect(page).to have_content @school1.name
    expect(page).to have_content @school2.name
  end

  def and_user_has_one_school(user)
    create(
      :membership,
      user:,
      organisation: create(:school, :claims, name: "Hogwarts"),
    )
  end

  def and_i_see_annes_schools
    expect(page).to have_content "Organisation details"
    expect(page).to have_content "Hogwarts"
  end

  def when_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def i_am_redirected_to_the_root_path
    expect(page).to have_content("Claim Funding for General Mentors")
  end
end
