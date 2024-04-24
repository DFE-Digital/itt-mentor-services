require "rails_helper"

RSpec.describe "Placements / Support / Schools / Mentor / Support User removes a mentor",
               type: :system, service: :placements do
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
    given_i_sign_in_as_colin
  end

  scenario "Support User removes a mentor from a school" do
    when_i_visit_the_support_show_page_for(school, mentor_1)
    and_i_click_on("Remove mentor")
    then_i_am_asked_to_confirm(school, mentor_1)
    when_i_click_on("Cancel")
    then_i_return_to_mentor_page(school, mentor_1)
    when_i_click_on("Remove mentor")
    then_i_am_asked_to_confirm(school, mentor_1)
    when_i_click_on("Remove mentor")
    then_the_mentor_is_removed_from_the_school(school, mentor_1)
    and_a_school_mentor_remains_called("Agatha Christie")
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def given_the_school_has_mentors(school:, mentors:)
    mentors.each do |mentor|
      create(:placements_mentor_membership, school:, mentor:)
    end
  end

  def when_i_visit_the_support_show_page_for(school, mentor)
    visit placements_support_school_mentor_path(school, mentor)
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm(school, mentor)
    organisations_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to remove this mentor? - #{mentor.full_name} - #{school.name} - Manage school placements",
    )
    expect(page).to have_content "#{mentor.full_name} - #{school.name}"
    expect(page).to have_content "Are you sure you want to remove this mentor?"
  end

  def organisations_is_selected_in_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def then_i_return_to_mentor_page(school, mentor)
    organisations_is_selected_in_primary_nav
    expect(page).to have_current_path placements_support_school_mentor_path(school, mentor),
                                      ignore_query: true
  end

  def then_the_mentor_is_removed_from_the_school(school, mentor)
    organisations_is_selected_in_primary_nav
    mentors_is_selected_in_secondary_nav
    expect(mentor.mentor_memberships.find_by(school:)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Mentor removed"
    end

    expect(page).not_to have_content mentor.full_name
  end

  def mentors_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Mentors", current: "page"
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Partner providers", current: "false"
    end
  end

  def and_a_school_mentor_remains_called(mentor_name)
    expect(page).to have_content(mentor_name)
  end
end
