require "rails_helper"

RSpec.describe "Claims user edits a draft claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_draft_claim
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_a_draft_claim

    when_i_click_on_the_claim_reference
    then_i_see_the_claim_show_page_with_draft_details

    when_i_click_on_change_mentors
    then_i_see_the_claim_details_page_with_james_jameson_selected

    when_i_deselect_james_jameson
    and_i_click_on_continue
    then_i_see_the_claim_details_page_with_james_jameson_deselected_and_a_validation_error

    when_i_select_barry_garlow
    and_i_click_on_continue
    then_i_see_the_edit_training_hours_page

    when_i_choose_twenty_two_hours
    and_i_click_on_continue
    then_i_see_the_edit_training_hours_page_with_a_validation_error

    when_i_choose_fifteen_hours
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page_with_barry_garlow_as_a_mentor_and_fifteen_hours_of_training

    when_i_click_on_accept_and_submit
    then_i_see_the_claim_submitted_page

    when_i_navigate_back_to_the_claims_index_page
    then_i_see_the_claims_index_page_with_a_submitted_claim
  end

  private

  def given_an_eligible_school_exists_with_a_draft_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james = build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @mentor_barry = build(:claims_mentor, first_name: "Barry", last_name: "Garlow", trn: "8888888")
    @provider = build(:claims_provider, :best_practice_network) do |provider|
      provider.provider_email_addresses.build(email_address: "best_practice_network@example.com", primary: true)
    end
    @claim_window = build(:claim_window, :current)
    @eligibility = build(:eligibility, claim_window: @claim_window)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor_james, @mentor_barry],
    )
    @draft_claim = build(:claim,
                         :draft,
                         school: @shelbyville_school,
                         reference: "88888888",
                         provider: @provider,
                         claim_window: @claim_window)
    @draft_mentor_training = create(:mentor_training,
                                    claim: @draft_claim,
                                    mentor: @mentor_james,
                                    hours_completed: 8,
                                    provider: @provider,
                                    date_completed: @date_completed)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_a_draft_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => "-",
      "Status" => "Draft",
    })
  end

  def when_i_click_on_the_claim_reference
    click_on "88888888"
  end

  def then_i_see_the_claim_show_page_with_draft_details
    expect(page).to have_link("Accept and submit", href: "/schools/#{@shelbyville_school.id}/claims/#{@draft_claim.id}/edit?step=declaration")
    expect(page).to have_title("Claim - 88888888 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "James Jameson")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "8 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "8 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 8}")

    expect(page).to have_link("Remove claim")
  end

  def when_i_click_on_change_mentors
    click_on "Change Mentors"
  end

  def then_i_see_the_claim_details_page_with_james_jameson_selected
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")
    expect(page).to have_checked_field("James Jameson")
    expect(page).not_to have_checked_field("Barry Garlow")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_deselect_james_jameson
    uncheck "James Jameson"
  end

  def when_i_select_barry_garlow
    check "Barry Garlow"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_claim_details_page_with_james_jameson_deselected_and_a_validation_error
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")
    expect(page).not_to have_checked_field("James Jameson")
    expect(page).not_to have_checked_field("Barry Garlow")
    expect(page).to have_validation_error("Select a mentor")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def the_i_see_the_claim_declaration_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Declaration")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "James Jameson")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "8 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "8 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 8}")

    expect(page).to have_warning_text("You will not be able to change any of the claim details once you have submitted the claim.")
    expect(page).to have_button("Accept and submit")
  end

  def then_i_see_the_claim_show_page_with_draft_details_and_barry_garlow_as_a_mentor
    expect(page).to have_link("Accept and submit", href: "/schools/#{@shelbyville_school.id}/claims/#{@draft_claim.id}/edit?step=declaration")
    expect(page).to have_title("Claim - 88888888 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "Barry Garlow")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("Barry Garlow", "8 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "8 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 8}")

    expect(page).to have_link("Remove claim")
  end

  def then_i_see_the_edit_training_hours_page
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_text("Barry Garlow (TRN 8888888) is eligible for 20 hours of training.")
    within(".govuk-radios") do
      expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
      expect(page).to have_hint("The full amount of hours for standard training")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-hours-to-claim-custom-field",
                                   class: "govuk-radios__input",
                                   value: "custom")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-hours-to-claim-maximum-field",
                                   class: "govuk-radios__input",
                                   value: "maximum")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-custom-hours-field",
                                   class: "govuk-input")
    end

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_choose_twenty_two_hours
    page.choose("Another amount")
    fill_in "Number of hours", with: "22"
  end

  def then_i_see_the_edit_training_hours_page_with_a_validation_error
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_text("Barry Garlow (TRN 8888888) is eligible for 20 hours of training.")
    within(".govuk-radios") do
      expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
      expect(page).to have_hint("The full amount of hours for standard training")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-hours-to-claim-custom-field",
                                   class: "govuk-radios__input",
                                   value: "custom")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-hours-to-claim-maximum-field",
                                   class: "govuk-radios__input",
                                   value: "maximum")
      expect(page).to have_element(:input,
                                   id: "claims-add-claim-wizard-mentor-training-step-custom-hours-field-error",
                                   class: "govuk-input")
    end

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")

    expect(page).to have_validation_error("Enter the number of hours between 1 and 20")
  end

  def when_i_choose_fifteen_hours
    page.choose("Another amount")
    fill_in "Number of hours", with: "15"
  end

  def then_i_see_the_check_your_answers_page_with_barry_garlow_as_a_mentor_and_fifteen_hours_of_training
    expect(page).to have_button("Accept and submit")
    expect(page).to have_title("Check your answers before submitting your claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Check your answers before submitting your claim")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "Barry Garlow")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("Barry Garlow", "15 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "15 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 15}")

    expect(page).to have_h2("Now submit your claim")
    expect(page).to have_text("I have only included hours for initial teacher training (ITT) mentors. I have not included hours for early career framework (ECF) mentors")
  end

  def when_i_click_on_accept_and_submit
    click_button "Accept and submit"
  end

  def then_i_see_the_claim_submitted_page
    expect(page).to have_title("Claim submitted - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-panel__title", text: "Claim submitted")
    expect(page).to have_text("Your reference number")

    expect(page).to have_text("88888888")
    expect(page).to have_text("We have sent a copy of your claim to best_practice_network@example.com")

    expect(page).to have_h2("What happens next")
    expect(page).to have_text("If we need further information to process your claim we will email you.")

    expect(page).to have_h2("We may check your claim")
    expect(page).to have_text("After payment we may check your claim to ensure it is accurate.")

    expect(page).to have_text("Best Practice Network will contact you if your claim undergoes a check.")
  end

  def when_i_navigate_back_to_the_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end
  end

  def then_i_see_the_claims_index_page_with_a_submitted_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "Barry Garlow",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 15}",
      "Date submitted" => (@date_completed + 1.day).strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
  end
end
