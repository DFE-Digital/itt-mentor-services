require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placements / Support User views placements",
               type: :system,
               service: :placements do
  let!(:subject1) { create(:subject, name: "English") }
  let!(:subject2) { create(:subject, name: "Science") }
  let!(:subject3) { create(:subject, name: "Maths") }
  let!(:mentor1) { create(:placements_mentor, first_name: "Bilbo", last_name: "Baggins") }
  let!(:mentor2) { create(:placements_mentor, first_name: "Bilbo", last_name: "Test") }
  let!(:mentor3) { create(:placements_mentor, trn: "1231233") }
  let!(:placement1) { create(:placement, mentors: [mentor1], subjects: [subject1], school:, start_date: nil, end_date: nil) }
  let!(:placement2) { create(:placement, mentors: [mentor2], subjects: [subject2], school:, start_date: nil, end_date: nil) }
  let!(:placement3) { create(:placement, mentors: [mentor3], subjects: [subject3], start_date: nil, end_date: nil) }
  let!(:school) { create(:placements_school, mentors: [mentor1, mentor2]) }
  let!(:another_school) { create(:placements_school) }
  let!(:colin) { create(:placements_support_user, :colin) }

  scenario "View a school's placements as a support user" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_support_school_placements_page(school)
    then_i_see_a_list_of_the_schools_placements
    and_i_dont_see_placements_from_another_school
  end

  scenario "View a school's empty placements list" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_support_school_placements_page(another_school)
    then_i_see_no_results
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_support_school_placements_page(school)
    visit placements_support_school_placements_path(school)
  end

  def then_i_see_a_list_of_the_schools_placements
    expect(page).to have_content("Subject")
    expect(page).to have_content("Mentor")
    expect(page).to have_content("Window")
    expect(page).to have_content("Status")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_link(placement1.subjects.map(&:name).to_sentence, href: placements_support_school_placement_path(school, placement1))
      expect(page).to have_content(placement1.mentors.map(&:full_name).to_sentence)
      expect(page).to have_content("Not known")
      expect(page).to have_content(placement1.status.titleize)
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_content(placement2.subjects.map(&:name).to_sentence)
      expect(page).to have_content(placement2.mentors.map(&:full_name).to_sentence)
      expect(page).to have_content("Not known")
      expect(page).to have_content(placement2.status.titleize)
    end
  end

  def and_i_dont_see_placements_from_another_school
    expect(page).not_to have_content(placement3.subjects.map(&:name).to_sentence)
    expect(page).not_to have_content(placement3.mentors.map(&:full_name).to_sentence)
  end

  def then_i_see_no_results
    expect(page).to have_content("There are no placements for #{another_school.name}.")
  end
end