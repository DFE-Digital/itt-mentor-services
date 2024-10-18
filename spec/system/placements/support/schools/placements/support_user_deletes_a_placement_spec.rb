require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placement / Support User deletes a placement",
               service: :placements, type: :system do
  let(:school) { create(:placements_school, name: "School 1", phase: "Nursery") }
  let(:placement_1) do
    create(:placement, school:, mentors: [mentor], subject: subject_1)
  end

  let(:placement_2) do
    create(:placement, school:, mentors: [mentor], subject: subject_2)
  end
  let(:mentor) { create(:placements_mentor) }
  let(:subject_1) { create(:subject, name: "Maths", subject_area: :primary) }
  let(:subject_2) { create(:subject, name: "English", subject_area: :primary) }

  before do
    placement_2
    given_i_am_signed_in_as_a_support_user
    when_i_visit_the_support_show_page_for(school, placement_1)
  end

  scenario "Support User deletes a placement from a school" do
    and_i_click_on("Delete placement")
    then_i_am_asked_to_confirm(school, placement_1)
    when_i_click_on("Cancel")
    then_i_return_to_placement_page(school, placement_1)
    when_i_click_on("Delete placement")
    then_i_am_asked_to_confirm(school, placement_1)
    when_i_click_on("Delete placement")
    then_the_placement_is_deleted_from_the_school(school, placement_1)
    and_a_school_placement_remains_called(placement_2.decorate.title)
  end

  scenario "User can not delete a placement assigned to a provider" do
    given_the_placement_is_assigned_to_a_provider(placement_1)
    and_i_click_on("Delete placement")
    then_i_see_i_can_not_delete_the_placement(placement_1)
  end

  private

  def when_i_visit_the_support_show_page_for(school, placement)
    visit placements_support_school_placement_path(school, placement)
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm(school, placement)
    organisations_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to delete this placement? - #{placement.decorate.title} - #{school.name} - Manage school placements",
    )
    expect(page).to have_content "Are you sure you want to delete this placement?"
  end

  def organisations_is_selected_in_primary_nav
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def then_i_return_to_placement_page(school, placement)
    organisations_is_selected_in_primary_nav
    expect(page).to have_current_path placements_support_school_placement_path(school, placement),
                                      ignore_query: true
  end

  def then_the_placement_is_deleted_from_the_school(school, placement)
    organisations_is_selected_in_primary_nav
    placements_is_selected_in_secondary_nav
    expect(school.placements.find_by(id: placement.id)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Placement deleted"
    end

    expect(page).not_to have_content placement.subject.name
  end

  def placements_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Partner providers", current: "false"
    end
  end

  def and_a_school_placement_remains_called(placement_name)
    expect(page).to have_content(placement_name)
  end

  def given_the_placement_is_assigned_to_a_provider(placement)
    placement.update!(provider: create(:placements_provider))
  end

  def then_i_see_i_can_not_delete_the_placement(placement)
    expect(page).to have_content(placement.decorate.title)
    expect(page).to have_content("You cannot delete this placement")
  end
end
