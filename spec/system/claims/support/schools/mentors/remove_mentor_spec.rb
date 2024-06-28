require "rails_helper"

RSpec.describe "Remove a mentor from a school", service: :claims, type: :system do
  let!(:mentor1) { create(:mentor, first_name: "Bilbo", last_name: "Baggins") }
  let!(:mentor2) { create(:mentor, first_name: "Bilbo", last_name: "Test") }
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2]) }
  let!(:colin) { create(:claims_support_user, :colin) }

  scenario "View a school's mentors as a support user" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_support_school_mentors_page(school)
    when_i_see_a_list_of_the_schools_mentors
    when_i_select_a_mentor_to_remove
    when_i_click_on_remove_mentor
    when_i_confirm_removal
    then_i_expect_to_see_the_mentor_has_been_removed
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def then_i_expect_to_see_the_mentor_has_been_removed
    expect(page).not_to have_content("Bilbo Baggins\n1")
  end

  def when_i_confirm_removal
    expect(page).to have_content("Are you sure you want to remove this mentor?")
    click_on "Remove mentor"
    expect(page).to have_content("Mentor removed")
  end

  def when_i_click_on_remove_mentor
    click_on "Remove mentor"
  end

  def when_i_select_a_mentor_to_remove
    click_on "Bilbo Baggins"
  end

  def when_i_visit_the_support_school_mentors_page(school)
    visit claims_support_school_mentors_path(school)
  end

  def when_i_see_a_list_of_the_schools_mentors
    expect(page).to have_content("Name")
    expect(page).to have_content("Teacher reference number (TRN)")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_content(mentor1.full_name)
      expect(page).to have_content(mentor1.trn)
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_content(mentor2.full_name)
      expect(page).to have_content(mentor2.trn)
    end
  end
end
