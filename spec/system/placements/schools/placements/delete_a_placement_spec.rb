require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Delete a placement",
               type: :system, service: :placements do
  let!(:placement_1) { create(:placement, school:, subjects: [subject_1]) }
  let(:placement_2) { create(:placement, school:, subjects: [subject_2]) }
  let(:school) { build(:placements_school, name: "School 1", phase: "Primary") }
  let(:subject_1) { build(:subject, name: "Subject 1", subject_area: :primary) }
  let(:subject_2) { build(:subject, name: "Subject 2", subject_area: :primary) }

  before do
    given_i_sign_in_as_anne
    placement_2
    when_i_visit_the_placement_show_page(placement_1)
  end

  scenario "User delete a placement from a school" do
    and_i_click_on("Delete placement")
    then_i_am_asked_to_confirm(school, placement_1, subject_1)
    when_i_click_on("Cancel")
    then_i_return_to_placement_page(school, placement_1)
    when_i_click_on("Delete placement")
    then_i_am_asked_to_confirm(school, placement_1, subject_1)
    when_i_click_on("Delete placement")
    then_the_placement_is_removed_from_the_school(school, placement_1, "Subject 1")
    and_a_school_placement_remains_for_subject("Subject 2")
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

  def when_i_visit_the_placement_show_page(placement)
    visit placements_school_placement_path(school, placement)
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm(_school, _placement, subject)
    placements_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to delete this placement? - #{subject.name} - Manage school placements",
    )
    expect(page).to have_content subject.name
    expect(page).to have_content "Are you sure you want to delete this placement?"
  end

  def placements_is_selected_in_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_return_to_placement_page(school, placement)
    placements_is_selected_in_primary_nav
    expect(page).to have_current_path placements_school_placement_path(school, placement),
                                      ignore_query: true
  end

  def then_the_placement_is_removed_from_the_school(school, placement, subject_name)
    placements_is_selected_in_primary_nav
    expect(school.placements.find_by(id: placement.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Placement deleted"
    end

    expect(page).not_to have_content(subject_name)
  end

  def and_a_school_placement_remains_for_subject(placement_name)
    expect(page).to have_content(placement_name)
  end
end
