require "rails_helper"

RSpec.describe "Authentication", type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "School") }
  let(:anne) { create(:placements_user, :anne) }

  scenario "As a user who has not signed in" do
    when_i_visit_placements_schools_details_path
    then_i_am_unable_to_access_the_page
  end

  scenario "As a user who has signed in" do
    given_there_is_an_existing_placements_user_with_a_school_for(anne)
    when_i_visit_the_sign_in_path
    and_i_click_sign_in
    and_i_visit_placements_schools_details_path
    then_i_am_able_to_access_the_page
  end

  private

  def given_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    create(:user_membership, user:, organisation: school, email: user.email)
    user
  end

  def when_i_visit_placements_schools_details_path
    visit placements_school_path(school.id)
  end

  def then_i_am_unable_to_access_the_page
    expect(page).to have_content("Sign in to Manage school placements")
  end

  def then_i_am_able_to_access_the_page
    expect(page).to have_content("Organisation nameSchool")
  end

  def when_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_an_existing_placements_user_with_a_school_for(user)
    user_exists_in_dfe_sign_in(user:)
    create(
      :user_membership,
      user:,
      organisation: school,
    )
  end

  alias_method :and_i_click_sign_in, :when_i_click_sign_in
  alias_method :and_i_visit_placements_schools_details_path, :when_i_visit_placements_schools_details_path
end
