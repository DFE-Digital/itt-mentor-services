require "rails_helper"

RSpec.describe "When removing a mentor", service: :claims, type: :system do
  let!(:mentor1) { create(:claims_mentor, first_name: "Bilbo", last_name: "Baggins") }
  let!(:mentor2) { create(:claims_mentor, first_name: "Bilbo", last_name: "Testa") }

  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2], region: regions(:inner_london)) }

  let!(:colin) { create(:claims_support_user, :colin) }

  scenario "When I try and remove a mentor who is already part of a submitted claim" do
    mentor_trainings = [build(:mentor_training, mentor: mentor1)]
    create(:claim, school_id: school.id, reference: "12345678", status: :submitted, mentor_trainings:)

    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_support_school_mentors_page(school)
    click_on mentor1.full_name
    click_on "Remove mentor"
    then_i_cant_remove_this_mentor
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_support_school_mentors_page(school)
    click_on school.name
    within(primary_navigation) do
      click_on "Mentors"
    end
  end

  def then_i_cant_remove_this_mentor
    expect(page).to have_content("You cannot remove this mentor")
  end
end
