require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placements / Support User views placements",
               service: :placements, type: :system do
  let!(:subject1) { create(:subject, name: "English") }
  let!(:subject2) { create(:subject, name: "Science") }
  let!(:subject3) { create(:subject, name: "Maths") }
  let!(:mentor1) { create(:placements_mentor, first_name: "Bilbo", last_name: "Baggins") }
  let!(:mentor2) { create(:placements_mentor, first_name: "Bilbo", last_name: "Test") }
  let!(:mentor3) { create(:placements_mentor, trn: "1231233") }
  let!(:provider) { create(:placements_provider, name: "Springfield University") }
  let!(:placement1) { create(:placement, mentors: [mentor1], subject: subject1, provider:, school:) }
  let!(:placement2) { create(:placement, mentors: [mentor2], subject: subject2, school:) }
  let!(:placement3) { create(:placement, mentors: [mentor3], subject: subject3) }
  let!(:school) { create(:placements_school, mentors: [mentor1, mentor2]) }
  let!(:another_school) { create(:placements_school) }
  let(:term) { create(:placements_term, :autumn) }

  before { given_i_am_signed_in_as_a_placements_support_user }

  scenario "view a school's empty placements list" do
    when_i_visit_the_school_placements_page(another_school)
    then_i_see_no_results
  end

  context "with placements" do
    scenario "view a school's placements as a support user" do
      when_i_visit_the_school_placements_page(school)
      then_i_see_a_list_of_the_schools_placements
      and_i_dont_see_placements_from_another_school
    end

    scenario "where the placement has a provider" do
      when_i_visit_the_school_placements_page(school)
      then_i_see_a_list_of_the_schools_placements
      and_i_dont_see_placements_from_another_school
      then_i_see_the_provider_name("Springfield University")
    end

    scenario "where the placement has no provider" do
      when_i_visit_the_school_placements_page(school)
      then_i_see_a_list_of_the_schools_placements
      and_i_dont_see_placements_from_another_school
      then_i_see_the_provider_is_not_assigned
    end

    scenario "when the placement has no terms" do
      when_i_visit_the_school_placements_page(school)
      then_i_see_a_list_of_the_schools_placements
      then_i_see_the_term_name("Any time in the academic year")
    end

    scenario "when the placement has terms" do
      and_the_placement_has_terms(placement1, term)
      when_i_visit_the_school_placements_page(school)
      then_i_see_the_term_name("Autumn term")
    end
  end

  private

  def when_i_visit_the_school_placements_page(school)
    visit placements_school_placements_path(school)
  end

  def then_i_see_a_list_of_the_schools_placements
    expect(page).to have_content("Subject")
    expect(page).to have_content("Mentor")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_link(placement1.subject.name, href: placements_school_placement_path(school, placement1))
      expect(page).to have_content(placement1.mentors.map(&:full_name).to_sentence)
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_content(placement2.subject.name)
      expect(page).to have_content(placement2.mentors.map(&:full_name).to_sentence)
    end

    within("tbody tr:nth-child(1) td:nth-child(3)") do
      expect(page).to have_content("Any time in the academic year")
    end

    within("tbody tr:nth-child(1) td:nth-child(4)") do
      expect(page).to have_content(placement1.provider.name)
    end
  end

  def and_i_dont_see_placements_from_another_school
    expect(page).not_to have_content(placement3.subject.name)
    expect(page).not_to have_content(placement3.mentors.map(&:full_name).to_sentence)
  end

  def and_the_placement_has_terms(placement, term)
    placement.terms << term
  end

  def then_i_see_no_results
    expect(page).to have_content("There are no placements for #{another_school.name}.")
  end

  def then_i_see_the_term_name(name)
    within("tbody tr:nth-child(1) td:nth-child(3)") do
      expect(page).to have_content name
    end
  end

  def then_i_see_the_provider_name(name)
    within("tbody tr:nth-child(1) td:nth-child(4)") do
      expect(page).to have_content name
    end
  end

  def then_i_see_the_provider_is_not_assigned
    within("tbody tr:nth-child(2) td:nth-child(4)") do
      expect(page).to have_content "Not yet known"
    end
  end
end
