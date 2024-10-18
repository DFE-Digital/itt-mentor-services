require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Navigate placements",
               service: :placements, type: :system do
  let!(:academic_year) { Placements::AcademicYear.current }
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement_for_current_academic_year) { create(:placement, school:).decorate }
  let!(:placement_for_next_academic_year) { create(:placement, school:, academic_year: academic_year.next).decorate }

  before do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
  end

  context "when viewing placements from the current academic year" do
    scenario "User can view a placement and return to the placements page" do
      when_i_visit_the_placements_page
      then_i_see_the_placements_page_for(academic_year)
      when_i_view_a_placement(placement_for_current_academic_year)
      and_i_click_link("Back")
      then_i_see_the_placements_page_for(academic_year)
    end
  end

  context "when viewing placements from the next academic year" do
    scenario "User can view a placement and return to the placements page" do
      when_i_visit_the_placements_page
      then_i_see_the_placements_page_for(academic_year)
      and_i_click_link("Next year (#{academic_year.next.name})")
      then_i_see_the_placements_page_for(academic_year.next)
      when_i_view_a_placement(placement_for_next_academic_year)
      and_i_click_link("Back")
      then_i_see_the_placements_page_for(academic_year.next)
    end
  end

  private

  def when_i_visit_the_placements_page
    visit placements_school_placements_path(school)
  end

  def then_i_see_the_placements_page_for(academic_year)
    placement = academic_year.current? ? placement_for_current_academic_year : placement_for_next_academic_year
    navigation_text = academic_year.current? ? "This year (#{academic_year.name})" : "Next year (#{academic_year.name})"

    find("a[aria-current=page]", text: navigation_text)
    expect(page).to have_content("Placements")
    expect(page).to have_link("Add placement")
    expect(page).to have_link(placement.title)
  end

  def and_i_click_link(text)
    click_link text
  end

  def when_i_view_a_placement(placement)
    click_link placement.title
  end
end
