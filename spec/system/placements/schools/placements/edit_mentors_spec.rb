require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Edit mentors",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:, provider:) }
  let(:mentor_1) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let(:mentor_2) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let!(:provider) { create(:provider) }

  before do
    given_i_sign_in_as_anne
  end

  context "when the school has no mentors" do
    scenario "User is redirected to add a mentor" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details(
        change_link: "Add a mentor",
      )
      when_i_click_link(
        text: "Add a mentor",
        href: placements_school_mentors_path(school),
      )
      then_i_am_redirected_to_add_a_mentor
    end
  end

  context "when the school has mentors" do
    before do
      mentor_1
      mentor_2
    end

    context "with no mentors" do
      scenario "User edits the mentors" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_uncheck("Not yet known")
        when_i_select_mentor_2
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_name_in_the_placement_details(mentor_name: mentor_2.full_name)
        and_i_see_success_message("Mentors updated")
      end

      scenario "User does not select a mentor" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        when_i_uncheck("Not yet known")
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Continue")
        then_i_should_see_an_error_message
      end

      scenario "User edits the mentor and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Cancel")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      end

      scenario "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Back")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      end
    end

    context "with mentors" do
      let(:placement) { create(:placement, school:, provider:, mentors: [mentor_1]) }

      scenario "User edits the mentors" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_2.full_name,
        )
        and_i_see_success_message("Mentors updated")
      end

      scenario "User does not select a mentor" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_uncheck(mentor_1.full_name)
        and_i_uncheck("Not yet known")
        and_i_click_on("Continue")
        then_i_should_see_an_error_message
      end

      scenario "User edits the mentor and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Cancel")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
      end

      scenario "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Back")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
      end

      scenario "User selects not yet known" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_not_yet_known
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        and_i_see_success_message("Mentors updated")
      end
    end
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    create(:user_membership, user:, organisation: school)
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

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  def then_i_should_see_the_mentor_name_in_the_placement_details(
    mentor_name:, change_link: "Change"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(mentor_name)
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details(
    change_link: "Select a mentor"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_an_error_message
    within(".govuk-error-summary__title") do
      expect(page).to have_content("There is a problem")
    end

    within(".govuk-error-summary__body") do
      expect(page).to have_content("Select a mentor or not yet known")
    end
  end

  def when_i_select_not_yet_known
    uncheck mentor_1.full_name
    check "Not yet known"
  end

  def when_i_click_on(text)
    click_on(text)
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_click_link(text:, href:)
    click_link text, href:
  end

  def then_i_should_see_the_edit_mentors_page
    expect(page).to have_content("Manage a placement")
    expect(page).to have_content("Mentor")
  end

  def when_i_select_mentor_2
    check mentor_2.full_name
  end

  def then_i_am_redirected_to_add_a_mentor
    expect(page).to have_current_path(
      placements_school_mentors_path(school), ignore_query: true
    )
  end

  def then_i_see_link(text:, href:)
    expect(page).to have_link(text, href:)
  end

  def when_i_uncheck(text)
    uncheck(text)
  end

  def and_i_see_success_message(message)
    within(".govuk-notification-banner") do
      expect(page).to have_content message
    end
  end

  alias_method :and_i_click_on, :when_i_click_on
  alias_method :and_i_uncheck, :when_i_uncheck
end
