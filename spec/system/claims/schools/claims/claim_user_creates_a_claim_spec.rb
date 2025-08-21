require "rails_helper"

RSpec.describe "Claims user creates a claim", :js, service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_no_claims

    when_i_click_on_add_claim
    then_i_see_the_select_provider_step

    when_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    and_i_click_on_continue
    then_i_see_the_select_mentors_step

    when_i_select_both_mentors
    and_i_click_on_continue

    when_i_click_back
    then_i_see_the_select_mentors_step_with_persisted_details

    when_i_click_on_continue
    then_i_see_the_select_training_hours_step_for_barry_garlow

    when_i_enter_a_negative_value_for_training_hours
    then_i_see_the_select_training_hours_step_with_hint

    when_i_select_the_maximum_hours_for_barry_garlow
    and_i_click_on_continue
    then_i_see_the_select_training_hours_step_for_james_jameson

    when_i_click_back
    then_i_see_the_select_training_hours_step_for_barry_garlow_with_persisted_details

    when_i_click_on_continue
    then_i_see_the_select_training_hours_step_for_james_jameson

    when_i_enter_fifteen_for_training_hours_for_james_jameson
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_accept_and_submit
    then_i_see_the_claim_submitted_page

    when_i_navigate_back_to_the_claims_index_page
    then_i_see_the_claims_index_page_with_a_submitted_claim
  end

  private

  def given_an_eligible_school_exists
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james = build(:claims_mentor, first_name: "James", last_name: "Jameson", trn: "1111111")
    @mentor_barry = build(:claims_mentor, first_name: "Barry", last_name: "Garlow", trn: "8888888")
    @provider = create(:claims_provider, :best_practice_network, postcode: "BR20RL")
    @ineligible_provider = create(:claims_provider, :niot)
    @claim_window = create(:claim_window, :current)
    @eligibility = build(:eligibility, academic_year: @claim_window.academic_year)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor_james, @mentor_barry],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_no_claims
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text(
      "There are no claims for Shelbyville Elementary.",
    )
  end

  def when_i_click_on_add_claim
    click_on "Add claim"
  end

  def then_i_see_the_select_provider_step
    expect(page).to have_title("Enter the accredited provider for this claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("You must make a separate claim for each accredited provider you work with.")
    expect(page).to have_element(:input, class: "autocomplete__input autocomplete__input--default", id: "claims-add-claim-wizard-provider-step-id-field")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_select_provider_step_with_persisted_details
    expect(page).to have_title("Enter the accredited provider for this claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("You must make a separate claim for each accredited provider you work with.")
    expect(page).to have_element(:input, class: "autocomplete__input autocomplete__input--default", id: "claims-add-claim-wizard-provider-step-id-field")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_enter_a_provider_named_best_practice_network
    fill_in "Enter the accredited provider", with: "Best Practice Network"
  end

  def then_i_see_a_dropdown_item_for_best_practice_network
    expect(page).to have_css(".autocomplete__option", text: "Best Practice Network (BR20RL)", wait: 10)
  end

  def when_i_click_the_dropdown_item_for_best_practice_network
    page.find(".autocomplete__option", text: "Best Practice Network (BR20RL)").click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_select_mentors_step
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")
    expect(page).to have_element(:label, class: "govuk-label govuk-checkboxes__label", text: "Barry Garlow")
    expect(page).to have_element(:label, class: "govuk-label govuk-checkboxes__label", text: "James Jameson")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_select_mentors_step_with_persisted_details
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_select_both_mentors
    check "Barry Garlow"
    check "James Jameson"
  end

  def then_i_see_the_select_training_hours_step_for_barry_garlow
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_hint("Barry Garlow (TRN 8888888) is eligible for 20 hours of training.")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
    expect(page).to have_hint("The full amount of hours for standard training")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "Another amount")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_select_training_hours_step_for_barry_garlow_with_persisted_details
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_hint("Barry Garlow (TRN 8888888) is eligible for 20 hours of training.")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
    expect(page).to have_hint("The full amount of hours for standard training")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "Another amount")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_enter_a_negative_value_for_training_hours
    choose "Another amount"
    fill_in "Number of hours", with: -1
  end

  def then_i_see_the_select_training_hours_step_with_hint
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_hint("Barry Garlow (TRN 8888888) is eligible for 20 hours of training.")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
    expect(page).to have_hint("The full amount of hours for standard training")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "Another amount")
    expect(page).to have_element(:div, id: "claims-add-claim-wizard-mentor-training-step-custom-hours-hint", text: "Enter a whole number up to 20")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_select_the_maximum_hours_for_barry_garlow
    choose "20 hours"
  end

  def when_i_enter_fifteen_for_training_hours_for_james_jameson
    choose "Another amount"
    fill_in "Number of hours", with: 15
  end

  def then_i_see_the_select_training_hours_step_for_james_jameson
    expect(page).to have_title("How many hours of training did James Jameson complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did James Jameson complete?")
    expect(page).to have_hint("James Jameson (TRN 1111111) is eligible for 20 hours of training.")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "20 hours")
    expect(page).to have_hint("The full amount of hours for standard training")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "Another amount")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_button("Accept and submit")
    expect(page).to have_title("Check your answers before submitting your claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Check your answers before submitting your claim")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    row = find("dt.govuk-summary-list__key", text: "Mentors").ancestor(".govuk-summary-list__row")
    within(row) do
      expect(page).to have_selector("ul.govuk-list li", count: 2)
      expect(page).to have_text("Barry Garlow")
      expect(page).to have_text("James Jameson")
    end

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "15 hours")
    expect(page).to have_summary_list_row("Barry Garlow", "20 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "35 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", Money.new(@shelbyville_school.region.funding_available_per_hour * 35, "GBP").format)

    expect(page).to have_h2("Now submit your claim")
    expect(page).to have_text("I have only included hours for initial teacher training (ITT) mentors. I have not included hours for early career framework (ECF) mentors")
  end

  def when_i_click_back
    click_link "Back"
  end

  def when_i_click_on_accept_and_submit
    click_button "Accept and submit"
  end

  def then_i_see_the_claim_submitted_page
    expect(page).to have_title("Claim submitted - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-panel__title", text: "Claim submitted")
    expect(page).to have_text("Your reference number")

    expect(page).to have_element(:strong, text: @shelbyville_school.claims.first.reference)

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
      "Reference" => @shelbyville_school.claims.first.reference.to_s,
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "Barry Garlow\nJames Jameson",
      "Amount" => Money.new(@shelbyville_school.region.funding_available_per_hour * 35, "GBP").format,
      "Date submitted" => (@date_completed + 1.day).strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
  end
end
