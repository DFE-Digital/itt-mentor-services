require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Edit mentors",
               type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:, provider:) }
  let!(:mentor_1) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let!(:mentor_2) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let!(:provider) { create(:provider) }

  before do
    given_i_sign_in_as_anne
  end

  context "with no mentors" do
    scenario "User edits the mentors" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      when_i_select_mentor_2
      and_i_click_on("Continue")
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_2.full_name)
    end

    scenario "User does not select a mentor" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      and_i_click_on("Continue")
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
    end

    scenario "User edits the mentor and cancels" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      when_i_select_mentor_2
      and_i_click_on("Cancel")
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
    end

    scenario "User clicks on back" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      and_i_click_on("Back")
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
    end
  end

  context "with mentors" do
    let(:placement) { create(:placement, school:, provider:, mentors: [mentor_1]) }

    scenario "User edits the mentors" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      when_i_select_mentor_2
      and_i_click_on("Continue")
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_2.full_name)
    end

    scenario "User does not select a mentor" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      when_i_select_not_yet_known
      and_i_click_on("Continue")
      then_i_should_see_the_mentor_name_in_the_placement_details("Not yet known")
    end

    scenario "User edits the mentor and cancels" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      when_i_select_mentor_2
      and_i_click_on("Cancel")
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
    end

    scenario "User clicks on back" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
      when_i_click_on_change
      then_i_should_see_the_edit_mentors_page
      and_i_click_on("Back")
      then_i_should_see_the_mentor_name_in_the_placement_details(mentor_1.full_name)
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

  def then_i_should_see_the_mentor_name_in_the_placement_details(mentor_name)
    within(".govuk-summary-list") do
      expect(page).to have_content(mentor_name)
      expect(page).to have_content("Change")
    end
  end

  def then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
    within(".govuk-summary-list") do
      expect(page).to have_content("Not yet known")
      expect(page).to have_content("Change")
    end
  end

  def when_i_select_not_yet_known
    uncheck mentor_1.full_name
    check "Not yet known"
  end

  def when_i_click_on(text)
    click_on(text)
  end

  def when_i_click_on_change
    click_link "Change", href: edit_mentors_placements_school_placement_path(school, placement)
  end

  def then_i_should_see_the_edit_mentors_page
    expect(page).to have_content("Edit placement")
  end

  def when_i_select_mentor_2
    check mentor_2.full_name
  end

  alias_method :and_i_click_on, :when_i_click_on
end
