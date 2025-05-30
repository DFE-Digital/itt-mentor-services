require "rails_helper"

RSpec.describe "Support user adds an existing mentor", service: :placements, type: :system do
  before do
    stub_valid_teaching_record_response
  end

  scenario do
    given_the_mentor_and_school_exist
    and_i_am_signed_in
    when_i_click_on_springfield_elementary
    and_i_navigate_to_mentors
    then_i_am_on_the_mentors_index_page

    when_i_click_on_add_mentor
    then_i_see_the_find_mentor_page

    when_i_enter_the_trn_and_date_of_birth_for_an_existing_placements_mentor
    and_i_click_on_continue
    then_i_see_a_validation_error_for_an_existing_mentor
  end

  private

  def given_the_mentor_and_school_exist
    @school = build(:school, :placements, name: "Springfield Elementary")
    @placements_mentor = build(:placements_mentor, trn: "7777777", first_name: "Elizabeth", last_name: "Hoover")
    create(:placements_mentor_membership, school: @school, mentor: @placements_mentor)
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_springfield_elementary
    click_on "Springfield Elementary"
  end

  def and_i_navigate_to_mentors
    within(primary_navigation) do
      click_on "Mentors"
    end
  end

  def then_i_am_on_the_mentors_index_page
    expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_paragraph("Add mentors to be able to assign them to your placements.")
    expect(page).to have_link("Add mentor", href: "/schools/#{@school.id}/mentors/new")
  end

  def when_i_click_on_add_mentor
    click_on "Add mentor"
  end

  def then_i_see_the_find_mentor_page
    expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_span_caption("Mentor details")
    expect(page).to have_h1("Find teacher")
  end

  def when_i_enter_the_trn_and_date_of_birth_for_an_existing_placements_mentor
    fill_in "TRN", with: "7777777"

    within_fieldset("Date of birth") do
      fill_in("Day", with: "01")
      fill_in("Month", with: "1")
      fill_in("Year", with: "1990")
    end
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_an_existing_mentor
    expect(page).to have_validation_error("The mentor has already been added")
  end

  def stub_valid_teaching_record_response
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "7777777", date_of_birth: "1990-01-01")
      .and_return(teaching_record_valid_response)
  end

  def teaching_record_valid_response
    {
      "trn" => "7777777",
      "firstName" => "Elizabeth",
      "middleName" => "",
      "lastName" => "Hoover",
      "dateOfBirth" => "1990-01-01",
    }
  end
end
