require "rails_helper"

RSpec.describe "School user does not enter any school contact details",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_i_am_signed_in

    when_i_visit_the_add_hosting_interest_page
    then_i_see_the_appetite_form

    when_i_select_not_open_to_hosting_placements
    and_i_click_on_continue
    then_i_see_the_reasons_for_not_hosting_form

    when_i_select_not_enough_trained_mentors
    and_i_select_number_of_pupils_with_send_needs
    and_i_click_on_continue
    then_i_see_the_school_contact_form

    when_i_click_on_continue
    then_i_see_a_validation_error_for_entering_a_school_contact_email_address
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_i_am_signed_in
    @school = create(:placements_school, with_school_contact: false)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_visit_the_add_hosting_interest_page
    visit new_add_hosting_interest_placements_school_hosting_interests_path(@school)
  end

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in this academic year (#{@next_academic_year_name})? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in this academic year (#{@next_academic_year_name})?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes - I can offer placements", type: :radio)
    expect(page).to have_field("Maybe - I’m not sure yet", type: :radio)
    expect(page).to have_field("No - I can’t offer placements", type: :radio)
  end

  def when_i_select_not_open_to_hosting_placements
    choose "No - I can’t offer placements"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_reasons_for_not_hosting_form
    expect(page).to have_title(
      "Tell us why you aren’t able to host this year - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Tell us why you aren’t able to host this year",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Concerns about trainee quality", type: :checkbox)
    expect(page).to have_field("High number of pupils with SEND needs", type: :checkbox)
    expect(page).to have_field("Low capacity to support trainees due to staff changes", type: :checkbox)
    expect(page).to have_field("No mentors available due to capacity", type: :checkbox)
    expect(page).to have_field("Not offered appropriate trainees", type: :checkbox)
    expect(page).to have_field("Unsure how to get involved", type: :checkbox)
    expect(page).to have_field("Working to improve our OFSTED rating", type: :checkbox)
    expect(page).to have_field("Other", type: :checkbox)
  end

  def when_i_select_not_enough_trained_mentors
    check "No mentors available due to capacity"
  end

  def and_i_select_number_of_pupils_with_send_needs
    check "High number of pupils with SEND needs"
  end

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who is the preferred contact for next year? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Who is the preferred contact for next year?")
    expect(page).to have_element(
      :p,
      text: "We will ask in the next academic year about placements. " \
        "The contact may be you, or someone at your school who coordinates ITT.",
      class: "govuk-body",
    )

    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def then_i_see_a_validation_error_for_entering_a_school_contact_email_address
    expect(page).to have_validation_error(
      "Enter an email address",
    )
  end
end
