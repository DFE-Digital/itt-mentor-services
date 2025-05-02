require "rails_helper"

RSpec.describe "School user enters another reason why they are not hosting",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_a_school_exists_with_a_hosting_interest
    and_i_am_signed_in

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
    and_i_see_the_hosting_interest_for_the_next_academic_year

    when_i_click_on_change_hosting_status
    then_i_see_the_appetite_form

    when_i_select_not_open_to_hosting_placements
    and_i_click_on_continue
    then_i_see_the_reasons_for_not_hosting_form

    when_i_select_other
    and_i_enter_another_reason
    and_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered

    when_i_click_on_continue
    then_i_see_my_responses_with_successfully_updated
    and_i_see_the_whats_next_page
    and_the_schools_hosting_interest_for_the_next_year_is_updated
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_a_school_exists_with_a_hosting_interest
    @school = create(:placements_school)
    @hosting_interest = create(
      :hosting_interest,
      school: @school,
      academic_year: @next_academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_navigate_to_organisation_details
    within(primary_navigation) do
      click_on "Organisation details"
    end
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_title(
      "Organisation details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1(@school.name)
    expect(page).to have_h2("Hosting status")
    expect(page).to have_element(
      :p,
      text: "This status indicates to providers whether you intend to host placements.",
      class: "govuk-body",
    )
  end

  def and_i_see_the_hosting_interest_for_the_next_academic_year
    expect(page).to have_summary_list_row(
      "Status", "Open to hosting"
    )
  end

  def when_i_click_on_change_hosting_status
    click_on "Change Hosting status"
  end

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in this academic year (#{@next_academic_year_name})? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_element(
      :span,
      text: "Not offering placements this year",
      class: "govuk-caption-l",
    )
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

  def when_i_select_other
    check "Other"
  end

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who is the preferred contact for next year? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_element(
      :span,
      text: "Not offering placements this year",
      class: "govuk-caption-l",
    )
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

  def then_i_see_the_school_contact_form_prefilled_with_my_inputs
    expect(page).to have_title(
      "Who is the preferred contact for next year? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_element(
      :span,
      text: "Not offering placements this year",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Who is the preferred contact for next year?")
    expect(page).to have_element(
      :p,
      text: "We will ask in the next academic year about placements. " \
        "The contact may be you, or someone at your school who coordinates ITT.",
      class: "govuk-body",
    )

    expect(page).to have_field("First name", with: "Joe")
    expect(page).to have_field("Last name", with: "Bloggs")
    expect(page).to have_field("Email address", with: "joe_bloggs@example.com")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner(
      "Your profile has been updated",
      "You can change your profile in settings if your circumstances change.",
    )
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("not_open")
    expect(hosting_interest.reasons_not_hosting).to contain_exactly("Other")
    expect(hosting_interest.other_reason_not_hosting).to eq("Some other reason")
  end

  def then_i_see_the_are_you_sure_page
    expect(page).to have_title(
      "Confirm and let providers know you are not offering placements - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_element(
      :span,
      text: "Not offering placements this year",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Confirm and let providers know you are not offering placements")
    expect(page).to have_element(
      :p,
      text: "Your contact details and reason will not be shared with providers.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "We will ask you again in the spring term of the next year to check whether you would like to offer placements.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Your reason for not offering placements be shared with the Department for Education for reporting purposes.",
      class: "govuk-body",
    )
  end

  def and_i_see_the_reason_not_hosting_i_entered
    expect(page).to have_summary_list_row(
      "Reason for not offering",
      "Other - Some other reason",
    )
  end

  def and_i_enter_another_reason
    fill_in "Tell us your reason", with: "Some other reason"
  end

  def and_i_see_the_whats_next_page
    expect(page).to have_panel(
      "Confirmed.You are not offering placements",
      "Your contact details will not be shown to providers",
    )
    expect(page).to have_h1("What happens next?", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "We will ask you again in the spring term of the next year to check whether you would like to offer placements.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "If you would like to host placements this year, update your placement preferences to let providers know you’re interested.",
      class: "govuk-body",
    )
    expect(page).to have_link("update your placement preferences", href: placements_school_path(@school))
  end
end
