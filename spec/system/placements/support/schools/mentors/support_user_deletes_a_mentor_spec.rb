require "rails_helper"

RSpec.describe "Support user deletes a mentor", service: :placements, type: :system do
  scenario do
    given_a_school_with_mentors
    and_i_am_signed_in

    when_i_click_on_the_london_school
    and_i_navigate_to_mentors
    then_i_can_see_the_mentors_index_page

    when_i_click_on_joe_bloggs
    then_i_see_the_mentor_details_for_joe_bloggs

    when_i_click_on_delete_mentor
    then_i_see_the_are_you_sure_page

    when_i_click_on_delete_mentor
    then_i_see_the_mentor_was_successfully_deleted
    and_i_see_joe_bloggs_is_no_longer_in_the_mentors_index_page
  end

  private

  def given_a_school_with_mentors
    @school = create(:placements_school, name: "The London School")
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
      trn: 3_333_333,
      schools: [@school],
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_the_london_school
    click_on "The London School"
  end

  def and_i_navigate_to_mentors
    within(primary_navigation) do
      click_on "Mentors"
    end
  end

  def then_i_can_see_the_mentors_index_page
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_title("Mentors at your school - Manage school placements")
    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Teacher reference number (TRN)" => "1111111",
    })
    expect(page).to have_table_row({
      "Name" => "Jane Doe",
      "Teacher reference number (TRN)" => "2222222",
    })
    expect(page).to have_table_row({
      "Name" => "John Smith",
      "Teacher reference number (TRN)" => "3333333",
    })
    expect(page).to have_link(
      "Add mentor",
      href: new_add_mentor_placements_school_mentors_path(@school),
      class: "govuk-button",
    )
  end

  def when_i_click_on_joe_bloggs
    click_on "Joe Bloggs"
  end

  def then_i_see_the_mentor_details_for_joe_bloggs
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_title("Joe Bloggs - Manage school placements")
    expect(page).to have_h1("Joe Bloggs")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", "1111111")
    expect(page).to have_link(
      "Delete mentor",
      href: remove_placements_school_mentor_path(@school, @joe_bloggs_mentor),
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def when_i_click_on_delete_mentor
    click_on "Delete mentor"
  end

  def then_i_see_the_are_you_sure_page
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_title(
      "Are you sure you want to delete this mentor? - Joe Bloggs - Manage school placements",
    )
    expect(page).to have_span_caption("Joe Bloggs")
    expect(page).to have_h1("Are you sure you want to delete this mentor?")
    expect(page).to have_paragraph("You will no longer be able to assign Joe Bloggs to placements.")
    expect(page).to have_button(
      "Delete mentor",
      class: "govuk-button govuk-button--warning",
    )
  end

  def then_i_see_the_mentor_was_successfully_deleted
    expect(page).to have_success_banner("Mentor deleted")
  end

  def and_i_see_joe_bloggs_is_no_longer_in_the_mentors_index_page
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_title("Mentors at your school - Manage school placements")
    expect(page).to have_h1("Mentors at your school")
    expect(page).not_to have_table_row({
      "Name" => "Joe Bloggs",
      "Teacher reference number (TRN)" => "1111111",
    })
    expect(page).to have_table_row({
      "Name" => "Jane Doe",
      "Teacher reference number (TRN)" => "2222222",
    })
    expect(page).to have_table_row({
      "Name" => "John Smith",
      "Teacher reference number (TRN)" => "3333333",
    })
    expect(page).to have_link(
      "Add mentor",
      href: new_add_mentor_placements_school_mentors_path(@school),
      class: "govuk-button",
    )
  end
end
