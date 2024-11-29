require "rails_helper"

RSpec.describe "School user adds an existing claims mentor", service: :placements, type: :system do
  before do
    stub_valid_teaching_record_response
  end

  scenario do
    given_the_mentor_and_school_exist
    and_i_am_signed_in

    when_i_am_on_the_mentors_index_page
    and_i_click_on_add_mentor
    then_i_see_the_find_mentor_page

    when_i_enter_the_trn_and_date_of_birth_for_an_existing_claims_mentor
    and_i_click_on_continue
    then_i_see_the_confirm_mentor_details_page

    when_i_click_on_change
    then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled_for_edna_krabappel

    when_i_click_on_continue
    then_i_see_the_confirm_mentor_details_page

    when_i_click_on_confirm_and_add_mentor
    then_i_see_a_success_message_for_edna_krapabbel
    and_i_see_the_mentors_index_page_with_edna_krabappel_listed
  end

  private

  def given_the_mentor_and_school_exist
    @school = build(:school, :placements, name: "Springfield Elementary")
    @claims_mentor = build(:claims_mentor, trn: "6666666", first_name: "Edna", last_name: "Krabappel")
    create(:claims_mentor_membership, school: @school, mentor: @claims_mentor)
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_mentors_index_page
    page.find(".app-primary-navigation__nav").click_on("Mentors")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_element(:p, text: "Add mentors to be able to assign them to your placements.", class: "govuk-body")
    expect(page).to have_link("Add mentor", href: "/schools/#{@school.id}/mentors/new")
  end

  def and_i_click_on_add_mentor
    click_on "Add mentor"
  end

  def then_i_see_the_find_mentor_page
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Mentor details", class: "govuk-caption-l")
    expect(page).to have_h1("Find teacher")
  end

  def when_i_enter_the_trn_and_date_of_birth_for_an_existing_claims_mentor
    fill_in "TRN", with: "6666666"

    within_fieldset("Date of birth") do
      fill_in("Day", with: "14")
      fill_in("Month", with: "9")
      fill_in("Year", with: "1991")
    end
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def stub_valid_teaching_record_response
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "6666666", date_of_birth: "1991-09-14")
      .and_return(teaching_record_valid_response)
  end

  def teaching_record_valid_response
    {
      "trn" => "6666666",
      "firstName" => "Edna",
      "middleName" => "",
      "lastName" => "Krabappel",
      "dateOfBirth" => "1991-09-14",
    }
  end

  def then_i_see_the_confirm_mentor_details_page
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_title("Confirm mentor details - Manage school placements - GOV.UK")
    expect(page).to have_h1("Confirm mentor details")
    expect(page).to have_element(:p, text: "Once added, you will be able to assign them to placements.", class: "govuk-body")
    expect(page).to have_h2("Mentor")
    expect(page).to have_element(:p, text: "Mentor data is stored in line with the Department for Education's (DfE) privacy notice (opens in new tab). I confirm that I have read, understood and accept how DfE uses mentor information as part of the Manage school placements service.", class: "govuk-inset-text")
    expect(page).to have_link("Department for Education's (DfE) privacy notice (opens in new tab)", href: "/privacy")
    expect(page).to have_button("Confirm and add mentor")
  end

  def when_i_click_on_change
    first(:link, "Change").click
  end

  def then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled_for_edna_krabappel
    find_field "TRN", with: "6666666"

    find_field "Day", with: "14"
    find_field "Month", with: "9"
    find_field "Year", with: "1991"
  end

  def when_i_click_on_confirm_and_add_mentor
    click_on "Confirm and add mentor"
  end

  def then_i_see_a_success_message_for_edna_krapabbel
    expect(page).to have_success_banner("Mentor added", "You can now assign Edna Krabappel to placements.")
  end

  def and_i_see_the_mentors_index_page_with_edna_krabappel_listed
    expect(page).to have_element(:a, text: "Edna Krabappel", class: "govuk-link")
    expect(page).to have_element(:td, text: "6666666", class: "govuk-table__cell")
  end
end
