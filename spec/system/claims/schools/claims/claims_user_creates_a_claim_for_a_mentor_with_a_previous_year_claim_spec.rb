require "rails_helper"

RSpec.describe "Claims user creates a claim for a mentor with a previous year claim", :js, service: :claims, type: :system do
  scenario do
    Timecop.travel(Time.zone.local(2025, 7, 3)) do
      given_a_school_exists_with_a_previous_year_claim
      and_i_am_signed_in
      then_i_see_the_claims_index_page_with_no_submitted_claims_for_this_year

      when_i_click_on_previous_academic_year
      then_i_see_the_claims_index_page_with_a_submitted_claim

      when_i_click_on_add_claim
      then_i_see_the_select_provider_step

      when_i_enter_a_provider_named_best_practice_network
      then_i_see_a_dropdown_item_for_best_practice_network

      when_i_click_the_dropdown_item_for_best_practice_network
      and_i_click_on_continue
      then_i_see_the_select_mentors_step

      when_i_select_barry_garlow
      and_i_click_on_continue
      then_i_see_the_select_training_hours_step_for_barry_garlow

      when_i_select_the_maximum_hours_for_barry_garlow
      and_i_click_on_continue
      then_i_see_the_check_your_answers_page

      when_i_click_on_accept_and_submit
      then_i_see_the_claim_submitted_page
    end
  end

  private

  def given_a_school_exists_with_a_previous_year_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor = build(:claims_mentor, first_name: "Barry", last_name: "Garlow", trn: "8888888")
    @provider = build(:claims_provider, :best_practice_network) do |provider|
      provider.provider_email_addresses.build(email_address: "best_practice_network@example.com", primary: true)
    end
    @current_claim_window = build(:claim_window, :current)
    @historic_claim_window = build(:claim_window, :historic)
    @date_submitted = @historic_claim_window.starts_on + 1.day
    @eligibility = build(:eligibility, claim_window: @current_claim_window)
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor],
    )
    @submitted_claim = build(:claim,
                             :submitted,
                             school: @shelbyville_school,
                             reference: "12345678",
                             submitted_at: @date_submitted,
                             provider: @provider,
                             submitted_by: @user_anne,
                             claim_window: @historic_claim_window)
    @mentor_training = create(:mentor_training,
                              claim: @submitted_claim,
                              mentor: @mentor,
                              hours_completed: 20,
                              date_completed: @date_submitted,
                              provider: @provider)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_no_submitted_claims_for_this_year
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_paragraph("There are no claims for Shelbyville Elementary in the 2024 to 2025 academic year.")
  end

  def when_i_click_on_previous_academic_year
    click_on("2022 to 2023")
  end

  def then_i_see_the_claims_index_page_with_a_submitted_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "12345678",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "Barry Garlow",
      "Amount" => Money.new(@shelbyville_school.region.funding_available_per_hour * 20, unit: "£").format,
      "Date submitted" => @date_submitted.strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
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
    expect(page).to have_css(".autocomplete__option", text: "Best Practice Network", wait: 10)
  end

  def when_i_click_the_dropdown_item_for_best_practice_network
    page.find(".autocomplete__option", text: "Best Practice Network").click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_select_mentors_step
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")
    expect(page).to have_element(:label, class: "govuk-label govuk-checkboxes__label", text: "Barry Garlow")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_select_mentors_step_with_persisted_details
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("Select all teachers that completed training to be initial teacher training (ITT) mentors.")
    expect(page).to have_element(:input, value: @mentor_barry.id, checked: "checked")
    expect(page).to have_element(:input, value: @mentor_james.id, checked: "checked")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_select_barry_garlow
    check "Barry Garlow"
  end

  def then_i_see_the_select_training_hours_step_for_barry_garlow
    expect(page).to have_title("How many hours of training did Barry Garlow complete? - Claim details - Best Practice Network - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-fieldset__heading", text: "How many hours of training did Barry Garlow complete?")
    expect(page).to have_hint("Barry Garlow (TRN 8888888) is eligible for 6 hours of refresher training as they have previously claimed up 20 hours of mentor training.")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "6 hours")
    expect(page).to have_element(:label, class: "govuk-label govuk-radios__label", text: "Another amount")

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_select_the_maximum_hours_for_barry_garlow
    choose "6 hours"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_button("Accept and submit")
    expect(page).to have_title("Check your answers before submitting your claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Check your answers before submitting your claim")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @current_claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    row = find("dt.govuk-summary-list__key", text: "Mentors").ancestor(".govuk-summary-list__row")
    within(row) do
      expect(page).to have_text("Barry Garlow")
    end

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("Barry Garlow", "6 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "6 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 6}")

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

    expect(page).to have_text("We have sent a copy of your claim to best_practice_network@example.com")

    expect(page).to have_h2("What happens next")
    expect(page).to have_text("If we need further information to process your claim we will email you.")

    expect(page).to have_h2("We may check your claim")
    expect(page).to have_text("After payment we may check your claim to ensure it is accurate.")

    expect(page).to have_text("Best Practice Network will contact you if your claim undergoes a check.")
  end
end
