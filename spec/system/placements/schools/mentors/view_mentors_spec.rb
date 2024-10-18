require "rails_helper"

RSpec.describe "Placements / Schools / Mentors / View mentors", service: :placements, type: :system do
  let!(:mentor1) { create(:mentor, first_name: "Bilbo", last_name: "Baggins") }
  let!(:mentor2) { create(:mentor, first_name: "Bilbo", last_name: "Test") }
  let!(:mentor3) { create(:mentor, trn: "1231233") }
  let!(:school) { create(:placements_school, mentors: [mentor1, mentor2]) }
  let!(:another_school) { create(:placements_school) }

  scenario "View a school's mentors as a user" do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    when_i_visit_the_school_mentors_page(school)
    then_i_see_a_list_of_the_schools_mentors
    and_i_dont_see_mentors_from_another_school
  end

  scenario "View a school's empty mentors list" do
    given_i_am_signed_in_as_a_placements_user(organisations: [another_school])
    when_i_visit_the_school_mentors_page(another_school)
    then_i_see_no_results
  end

  private

  def when_i_visit_the_school_mentors_page(school)
    visit placements_school_mentors_path(school)
  end

  def then_i_see_a_list_of_the_schools_mentors
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

  def and_i_dont_see_mentors_from_another_school
    expect(page).not_to have_content(mentor3.full_name)
    expect(page).not_to have_content(mentor3.trn)
  end

  def then_i_see_no_results
    expect(page).to have_content("There are no mentors for #{another_school.name}.")
  end
end
