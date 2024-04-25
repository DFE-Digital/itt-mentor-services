require "rails_helper"

RSpec.describe "Placement school user views a list of placements", type: :system, service: :placements do
  let!(:school) { create(:placements_school) }
  let!(:another_school) { create(:placements_school) }

  scenario "View school placements page where school has no placements" do
    given_i_sign_in_as_anne
    then_i_see_the_placements_page
    then_i_see_the_empty_state
  end

  scenario "where placements for another school exists" do
    given_placement_exists_for_another_school
    given_i_sign_in_as_anne
    then_i_see_the_empty_state
  end

  context "with placements" do
    scenario "where placement has multiple mentors and multiple subjects" do
      given_a_draft_placement_exists_with_multiple_mentors_and_subjects
      given_i_sign_in_as_anne
      then_i_see_mentor_names("Bart Simpson and Lisa Simpson")
      and_i_see_subject_names("Biology and Maths")
      and_i_see_draft_status_tag
    end

    scenario "placement has status of published" do
      given_a_published_placement_exists
      given_i_sign_in_as_anne
      then_i_see_published_status_tag
    end

    scenario "where placement has no mentors attached" do
      given_a_published_placement_exists
      given_i_sign_in_as_anne
      then_i_see_mentor_names("Not known yet")
    end
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_a_published_placement_exists
    create(:placement, status: :published, school:)
  end

  def then_i_see_published_status_tag
    within("tbody tr:nth-child(1) td:nth-child(3)") do
      within(".govuk-tag--blue") do
        expect(page).to have_content "Published"
      end
    end
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

  def and_i_see_draft_status_tag
    within("tbody tr:nth-child(1) td:nth-child(3)") do
      within(".govuk-tag--grey") do
        expect(page).to have_content "Draft"
      end
    end
  end

  def given_a_draft_placement_exists_with_multiple_mentors_and_subjects
    mentor_lisa = create(:placements_mentor, first_name: "Lisa", last_name: "Simpson")
    mentor_bart = create(:placements_mentor, first_name: "Bart", last_name: "Simpson")
    mentors = [mentor_lisa, mentor_bart]

    biology = create(:subject, name: "Biology")
    maths = create(:subject, name: "Maths")
    subjects = [maths, biology]
    create(:placement, status: :draft, school:, mentors:, subjects:)
  end

  def given_placement_exists_for_another_school
    create(:placement, school: another_school)
  end

  def and_i_see_published_status_tag
    within(".gov-tag--blue") do
      expect(page).to have_content "Published"
    end
  end

  def expect_to_see_table_headings
    within(".govuk-table__head") do
      expect(page).to have_content "Subject"
      expect(page).to have_content "Mentor"
      expect(page).to have_content "Start date"
      expect(page).to have_content "Status"
    end
  end
end
