require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placement / Support User removes a placement",
               type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "School 1", phase: "Nursery") }
  let(:placement_1) do
    create(:placement, school:, mentors: [mentor], subjects: [subject_1])
  end

  let(:placement_2) do
    create(:placement, school:, mentors: [mentor], subjects: [subject_2])
  end
  let(:mentor) { create(:placements_mentor) }
  let(:subject_1) { create(:subject, name: "Maths", subject_area: :primary) }
  let(:subject_2) { create(:subject, name: "English", subject_area: :primary) }

  before do
    placement_2
    given_i_sign_in_as_colin
  end

  scenario "Support User removes a placement from a school" do
    when_i_visit_the_support_show_page_for(school, placement_1)
    and_i_click_on("Remove placement")
    then_i_am_asked_to_confirm(placement_1)
    when_i_click_on("Cancel")
    then_i_return_to_placement_page(school, placement_1)
    when_i_click_on("Remove placement")
    then_i_am_asked_to_confirm(placement_1)
    when_i_click_on("Remove placement")
    then_the_placement_is_removed_from_the_school(school, placement_1)
    and_a_school_placement_remains_called(placement_2.decorate.subject_names)
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

  def when_i_visit_the_support_show_page_for(school, placement)
    visit placements_support_school_placement_path(school, placement)
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm(placement)
    organisations_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to remove this placement? - #{placement.decorate.subject_names} - Manage school placements",
    )
    expect(page).to have_content "Are you sure you want to remove this placement?"
  end

  def organisations_is_selected_in_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def then_i_return_to_placement_page(school, placement)
    organisations_is_selected_in_primary_nav
    expect(page).to have_current_path placements_support_school_placement_path(school, placement),
                                      ignore_query: true
  end

  def then_the_placement_is_removed_from_the_school(school, placement)
    organisations_is_selected_in_primary_nav
    placements_is_selected_in_secondary_nav
    expect(school.placements.find_by(id: placement.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Placement removed"
    end

    expect(page).not_to have_content placement.subjects.to_sentence
  end

  def placements_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Providers", current: "false"
    end
  end

  def and_a_school_placement_remains_called(placement_name)
    expect(page).to have_content(placement_name)
  end
end
