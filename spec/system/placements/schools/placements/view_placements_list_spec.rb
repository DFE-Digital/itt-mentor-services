require "rails_helper"

RSpec.describe "Placement school user views a list of placements", service: :placements, type: :system do
  let!(:school) { create(:placements_school) }
  let!(:another_school) { create(:placements_school) }

  scenario "View school placements page where school has no placements" do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    then_i_see_the_placements_page
    then_i_see_the_empty_state
  end

  scenario "where placements for another school exists" do
    given_placement_exists_for_another_school
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    then_i_see_the_empty_state
  end

  context "with placements" do
    scenario "where placement has multiple mentors" do
      given_a_placement_exists_with_multiple_mentors
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_mentor_names("Bart Simpson and Lisa Simpson")
      and_i_see_subject_names("Biology")
    end

    scenario "where placement has no mentors attached" do
      given_a_placement_exists
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_mentor_names("Not yet known")
    end

    scenario "when the placement has a provider" do
      given_a_placement_exists_with_a_provider
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_the_provider_name("Springfield University")
    end

    scenario "when the placement does not have a provider" do
      given_a_placement_exists
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_the_provider_name("Not yet known")
    end

    scenario "when the placement has no terms" do
      given_a_placement_exists
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_term_name("Any time in the academic year")
    end

    scenario "when the placement has terms" do
      given_a_placement_exists(with_term: true)
      given_i_am_signed_in_as_a_placements_user(organisations: [school])
      then_i_see_term_name("Autumn term")
    end

    context "when using the academic year navigation" do
      let(:current_academic_year) { Placements::AcademicYear.current }
      let(:next_academic_year) { current_academic_year.next }
      # Subjects were added to make sure tha placement titles are always unique.
      let(:current_subject) { create(:subject, name: "Current academic year studies") }
      let(:next_subject) { create(:subject, name: "Next academic year studies") }
      let!(:current_academic_year_placement) { create(:placement, school:, academic_year: current_academic_year, subject: current_subject) }
      let!(:next_academic_year_placement) { create(:placement, school:, academic_year: next_academic_year, subject: next_subject) }

      scenario "when I view placements for the current academic year" do
        given_i_am_signed_in_as_a_placements_user(organisations: [school])
        then_i_see_placement(current_academic_year_placement)
        and_i_do_not_see_placement(next_academic_year_placement)
      end

      scenario "when I view placements for the next academic year" do
        given_i_am_signed_in_as_a_placements_user(organisations: [school])
        when_i_click_on("Next year (#{next_academic_year.name})")
        then_i_see_placement(next_academic_year_placement)
        and_i_do_not_see_placement(current_academic_year_placement)
      end

      scenario "I can switch between academic years" do
        given_i_am_signed_in_as_a_placements_user(organisations: [school])
        then_i_see_placement(current_academic_year_placement)
        and_i_do_not_see_placement(next_academic_year_placement)

        when_i_click_on("Next year (#{next_academic_year.name})")
        then_i_see_placement(next_academic_year_placement)
        and_i_do_not_see_placement(current_academic_year_placement)

        when_i_click_on("This year (#{current_academic_year.name})")
        then_i_see_placement(current_academic_year_placement)
        and_i_do_not_see_placement(next_academic_year_placement)
      end
    end
  end

  private

  def given_a_placement_exists(with_term: false)
    with_term ? create(:placement, school:, terms: [create(:placements_term, :autumn)]) : create(:placement, school:)
  end

  def then_i_see_placement(placement)
    expect(page).to have_content placement.decorate.title
  end

  def and_i_do_not_see_placement(placement)
    expect(page).not_to have_content placement.decorate.title
  end

  def then_i_see_the_placements_page
    expect_placements_is_selected_in_the_primary_navigation
    expect(page).to have_title "Placements"
    expect(page).to have_current_path placements_school_placements_path(school)
    within(".govuk-heading-l") do
      expect(page).to have_content "Placements"
    end
  end

  def expect_placements_is_selected_in_the_primary_navigation
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_see_the_empty_state
    expect(page).to have_content "There are no placements for #{school.name}"
  end

  def then_i_see_subject_names(names)
    within("tbody tr:nth-child(1) td:nth-child(1)") do
      expect(page).to have_content names
    end
  end

  alias_method :and_i_see_subject_names, :then_i_see_subject_names

  def then_i_see_mentor_names(names)
    within("tbody tr:nth-child(1) td:nth-child(2)") do
      expect(page).to have_content names
    end
  end

  def then_i_see_term_name(name)
    within("tbody tr:nth-child(1) td:nth-child(3)") do
      expect(page).to have_content name
    end
  end

  def then_i_see_the_provider_name(name)
    within("tbody tr:nth-child(1) td:nth-child(4)") do
      expect(page).to have_content name
    end
  end

  def given_a_placement_exists_with_a_provider
    provider = build(:placements_provider, name: "Springfield University")
    create(:placement, school:, provider:, subject: create(:subject, name: "Biology"))
  end

  def given_a_placement_exists_with_multiple_mentors
    mentor_lisa = create(:placements_mentor, first_name: "Lisa", last_name: "Simpson")
    mentor_bart = create(:placements_mentor, first_name: "Bart", last_name: "Simpson")
    mentors = [mentor_lisa, mentor_bart]

    create(:placement, school:, mentors:, subject: create(:subject, name: "Biology"))
  end

  def given_placement_exists_for_another_school
    create(:placement, school: another_school)
  end

  def expect_to_see_table_headings
    within(".govuk-table__head") do
      expect(page).to have_content "Subject"
      expect(page).to have_content "Mentor"
      expect(page).to have_content "Start date"
    end
  end

  def when_i_click_on(link_text)
    click_on link_text
  end
end
