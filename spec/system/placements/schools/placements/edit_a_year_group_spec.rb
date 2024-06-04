require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Edit a year group",
               type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:, year_group: :year_1) }

  before { given_i_sign_in_as_anne }

  context "when I edit the year group" do
    scenario "User edits the year group" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_year_group_in_the_placement_details(
        year_group_name: "Year 1",
      )
      when_i_click_link(
        text: "Change",
        href: edit_year_group_placements_school_placement_path(school, placement),
      )
      then_i_should_see_the_edit_year_group_page
      when_i_select "Year 4"
      and_i_click_on("Continue")
      then_i_should_see_the_year_group_in_the_placement_details(
        year_group_name: "Year 4",
      )
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

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def then_i_should_see_the_edit_year_group_page
    expect(page).to have_content("Manage a placement")
    expect(page).to have_content("Year group")
  end

  def when_i_select(text)
    choose text
  end

  def and_i_click_on(text)
    click_on text
  end

  def when_i_click_link(text:, href:)
    click_link text, href:
  end

  def then_i_should_see_the_year_group_in_the_placement_details(year_group_name:, change_link: "Change")
    within(".govuk-summary-list") do
      expect(page).to have_content(year_group_name)
      expect(page).to have_content(change_link)
    end
  end
end
