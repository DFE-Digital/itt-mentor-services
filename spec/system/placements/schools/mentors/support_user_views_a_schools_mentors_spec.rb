require "rails_helper"

RSpec.describe "Support user views a schools mentors", service: :placements, type: :system do
  scenario do
    given_a_school_with_mentors
    and_i_am_signed_in

    when_i_navigate_to_mentors
    then_i_can_see_the_mentors_index_page
    and_i_can_see_joe_bloggs
    and_i_can_see_jane_doe
    and_i_can_not_see_john_smith
  end

  private

  def given_a_school_with_mentors
    @school = create(:placements_school)
    @joe_bloggs_mentor = create(
      :placements_mentor,
      first_name: "Joe",
      last_name: "Bloggs",
      trn: 1_111_111,
      schools: [@school],
    )
    @jane_doe_mentor = create(
      :placements_mentor,
      first_name: "Jane",
      last_name: "Doe",
      trn: 2_222_222,
      schools: [@school],
    )
    @john_smith_mentor = create(
      :placements_mentor,
      first_name: "John",
      last_name: "Smith",
    )
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

  def and_i_can_see_joe_bloggs
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Teacher reference number (TRN)" => "1111111",
    })
  end

  def and_i_can_see_jane_doe
    expect(page).to have_table_row({
      "Name" => "Jane Doe",
      "Teacher reference number (TRN)" => "2222222",
    })
  end

  def and_i_can_not_see_john_smith
    expect(page).not_to have_table_row({
      "Name" => "John Smith",
    })
  end
end
