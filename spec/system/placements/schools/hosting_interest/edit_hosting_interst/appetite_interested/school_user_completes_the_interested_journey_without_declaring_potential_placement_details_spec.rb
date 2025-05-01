require "rails_helper"

RSpec.describe "School user completes the interested journey without declaring potential placement details",
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

    when_i_select_interested_in_hosting_placements
    and_i_click_on_continue
    then_i_see_the_phase_known_page

    when_i_select_i_dont_know
    and_i_click_on_continue
    then_i_see_the_provider_note_page

    when_i_click_on_continue
    then_i_see_the_confirmation_page
    and_i_see_the_education_phase_is_not_known
    and_i_see_the_message_to_provider_is_empty

    when_i_click_on_confirm
    then_i_see_my_responses_with_successfully_updated
    and_i_see_the_whats_next_page
    and_the_schools_hosting_interest_for_the_next_year_is_updated
    and_the_schools_potential_placement_details_have_been_updated
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

  def when_i_select_interested_in_hosting_placements
    choose "Maybe - I’m not sure yet"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Confirm and share your approximate information with providers - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Confirm and share your approximate information with providers", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Potential placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :p,
      text: "Providers will be able to see that you may be able to offer placements for trainee teachers.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "They will be able to see your approximate information and will be able to use your email to contact you.",
      class: "govuk-body",
    )
  end

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner(
      "Your status has been updated to ‘interesed in hosting placements’",
      "This means providers can see that you’re looking to host placements.",
    )
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("interested")
  end

  def and_i_see_the_whats_next_page
    expect(page).to have_panel(
      "Approximate information added",
      "Providers can see that you may offer placements",
    )
    expect(page).to have_h1("What happens next?", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Providers who are looking for schools to work with can contact you on #{@school.school_contact_email_address}.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Once you know which placements you can offer, you can add placements to help providers know what trainees you need.",
      class: "govuk-body",
    )
    expect(page).to have_link("add placements", href: placements_school_placements_path(@school))
  end

  def then_i_see_the_phase_known_page
    expect(page).to have_title(
      "Do you know what phase of education your placements will be? - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :legend,
      text: "Do you know what phase of education your placements will be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def when_i_select_i_dont_know
    check "I don’t know"
  end

  def then_i_see_the_provider_note_page
    expect(page).to have_title(
      "Is there anything about your school you would like providers to know? (optional) - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :label,
      text: "Is there anything about your school you would like providers to know? (optional)",
    )
    expect(page).to have_element(
      :span,
      text: "Expression of interest",
      class: "govuk-caption-l",
    )
  end

  def and_i_see_the_education_phase_is_not_known
    expect(page).to have_h2("Education phase", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Phase", "I don’t know")
  end

  def and_i_see_the_message_to_provider_is_empty
    expect(page).to have_h2("Additional information", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Message to providers", "")
  end

  def when_i_click_on_confirm
    click_on "Confirm"
  end

  def and_the_schools_potential_placement_details_have_been_updated
    potential_placement_details = @school.reload.potential_placement_details
    expect(potential_placement_details["phase"]).to eq({ "phases" => %w[unknown] })
    expect(potential_placement_details["note_to_providers"]).to eq(
      { "note" => "" },
    )
  end
end
