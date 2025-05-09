require "rails_helper"

RSpec.describe "School user does not select any reasons not to host",
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

    when_i_select_other
    and_i_click_on_continue
    then_i_see_a_validation_error_not_entering_an_other_reason
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_i_am_signed_in
    @school = create(:placements_school)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_visit_the_add_hosting_interest_page
    visit new_add_hosting_interest_placements_school_hosting_interests_path(@school)
  end

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}?",
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
      "Tell us why you are not able to offer placements for trainee teachers - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Tell us why you are not able to offer placements for trainee teachers",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Trainees we were offered did not meet our expectations", type: :checkbox)
    expect(page).to have_field("High number of pupils with SEND needs", type: :checkbox)
    expect(page).to have_field("Low capacity to support trainees due to staff changes", type: :checkbox)
    expect(page).to have_field("No mentors available due to capacity", type: :checkbox)
    expect(page).to have_field("Unsure how to get involved", type: :checkbox)
    expect(page).to have_field("Working to improve our OFSTED rating", type: :checkbox)
    expect(page).to have_field("Other", type: :checkbox)
  end

  def when_i_select_other
    check "Other"
  end

  def then_i_see_a_validation_error_not_entering_an_other_reason
    expect(page).to have_validation_error(
      "Please enter a reason",
    )
  end
end
