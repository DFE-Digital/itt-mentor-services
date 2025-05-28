require "rails_helper"

RSpec.describe "Support user views an empty list of mentors", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_i_am_signed_in

    when_i_navigate_to_mentors
    then_i_can_see_the_mentors_index_page
    and_i_see_no_results
  end

  private

  def given_a_school_exists
    @school = create(:placements_school, name: "The London School")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_navigate_to_mentors
    within(primary_navigation) do
      click_on "Mentors"
    end
  end

  def then_i_can_see_the_mentors_index_page
    expect(page).to have_title("Mentors at your school - Manage school placements")
    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_link(
      "Add mentor",
      href: new_add_mentor_placements_school_mentors_path(@school),
      class: "govuk-button",
    )
  end

  def and_i_see_no_results
    expect(page).to have_element(
      :p,
      text: "There are no mentors for The London School.",
      class: "govuk-body",
    )
  end
end
