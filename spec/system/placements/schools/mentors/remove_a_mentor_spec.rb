require "rails_helper"

RSpec.describe "Placements / Schools / Mentors / Remove a mentor", service: :placements, type: :system do
  let(:school) { create(:placements_school, name: "School 1") }
  let(:mentor_1) do
    create(:placements_mentor,
           first_name: "John",
           last_name: "Doe")
  end
  let(:mentor_2) do
    create(:placements_mentor,
           first_name: "Agatha",
           last_name: "Christie")
  end

  before do
    given_the_school_has_mentors(school:, mentors: [mentor_1, mentor_2])
    given_i_sign_in_as_anne
  end

  context "when the mentor has no placements" do
    scenario "User deletes a mentor from a school" do
      when_i_visit_the_show_page_for(school, mentor_1)
      and_i_click_on("Delete mentor")
      then_i_am_asked_to_confirm(school, mentor_1)
      when_i_click_on("Cancel")
      then_i_return_to_mentor_page(school, mentor_1)
      when_i_click_on("Delete mentor")
      then_i_am_asked_to_confirm(school, mentor_1)
      when_i_click_on("Delete mentor")
      then_the_mentor_is_removed_from_the_school(school, mentor_1)
      and_a_school_mentor_remains_called("Agatha Christie")
    end
  end

  context "when the mentor has placements" do
    before { create(:placement, mentors: [mentor_1], school:) }

    scenario "User cannot remove the mentor from the school" do
      when_i_visit_the_show_page_for(school, mentor_1)
      and_i_click_on("Delete mentor")
      then_i_see_i_cannot_remove_the_mentor(mentor_1)
    end
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_school(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def and_user_has_one_school(user:)
    create(:user_membership, user:, organisation: school)
  end

  def given_the_school_has_mentors(school:, mentors:)
    mentors.each do |mentor|
      create(:placements_mentor_membership, school:, mentor:)
    end
  end

  def when_i_visit_the_show_page_for(school, mentor)
    visit placements_school_mentor_path(school, mentor)
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm(_school, mentor)
    mentors_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to delete this mentor? - #{mentor.full_name} - Manage school placements",
    )
    expect(page).to have_content mentor.full_name
    expect(page).to have_content "Are you sure you want to delete this mentor?"
  end

  def mentors_is_selected_in_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_return_to_mentor_page(school, mentor)
    mentors_is_selected_in_primary_nav
    expect(page).to have_current_path placements_school_mentor_path(school, mentor),
                                      ignore_query: true
  end

  def then_the_mentor_is_removed_from_the_school(school, mentor)
    mentors_is_selected_in_primary_nav
    expect(mentor.mentor_memberships.find_by(school:)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Mentor removed"
    end

    expect(page).not_to have_content mentor.full_name
  end

  def and_a_school_mentor_remains_called(mentor_name)
    expect(page).to have_content(mentor_name)
  end

  def then_i_see_i_cannot_remove_the_mentor(mentor)
    expect(page).to have_content(mentor.full_name)
    expect(page).to have_content("You cannot delete this mentor")

    mentor.placements.where(school:).find_each do |placement|
      expect(page).to have_link(placement.decorate.title, href: placements_school_placement_path(school, placement))
    end
  end
end
