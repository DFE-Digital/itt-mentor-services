require "rails_helper"

RSpec.describe "Support user requests a clawback on a claim", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_one
    then_i_see_the_show_page_for_claim_one

    when_i_click_on_request_clawback
    then_i_see_the_clawback_details_page

    when_i_enter_fifty_hours
    and_i_click_on_continue
    # TODO: then_i_see_a_validation_error_for_entering_too_many_hours

    when_i_leave_all_fields_blank
    and_i_click_on_continue
    # TODO: then_i_see_validation_errors_for_not_providing_required_data

    when_i_enter_valid_data
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change
    then_i_see_the_clawback_details_page

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_request_clawback
    then_i_see_a_success_message
    and_i_see_the_clawbacks_index_page
    and_i_see_the_claim_status_is_clawback_requested
  end

  private

  def given_claims_exist
    @claim_not_approved_claim = create(:claim,
                                       :submitted,
                                       status: :sampling_not_approved,
                                       reference: 11_111_111)
    @claim_two = create(:claim,
                        :submitted,
                        status: :sampling_not_approved,
                        reference: 22_222_222)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawbacks_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def and_i_click_on_claim_one
    click_on "11111111 - #{@claim_not_approved_claim.school_name}"
  end

  def then_i_see_the_show_page_for_claim_one
    expect(page).to have_title("Clawbacks - #{@claim_not_approved_claim.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
  end

  def when_i_click_on_request_clawback
    click_on "Request clawback"
  end

  def then_i_see_the_clawback_details_page
    expect(page).to have_title("Clawback details - #{@claim_not_approved_claim.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours to clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Enter whole numbers up to a maximum of 40 hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Reason for clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Explain why the clawback is being requested. For example, include details of which mentor has received a deduction.", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def when_i_enter_fifty_hours
    fill_in "claims_request_clawback_wizard_clawback_step[number_of_hours]", with: 50
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  # TODO: def then_i_see_a_validation_error_for_entering_too_many_hours; end

  def when_i_leave_all_fields_blank
    fill_in "claims_request_clawback_wizard_clawback_step[number_of_hours]", with: ""
  end

  # TODO: def then_i_see_validation_errors_for_not_providing_required_data; end

  def when_i_enter_valid_data
    fill_in "claims_request_clawback_wizard_clawback_step[number_of_hours]", with: "8"
    fill_in "claims_request_clawback_wizard_clawback_step[reason_for_clawback]", with: "Mismatch in hours recorded compared with hours claimed."
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - #{@claim_not_approved_claim.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("Number of hours", "")
    expect(page).to have_summary_list_row("Hourly rate", @claim_not_approved_claim.school.region.funding_available_per_hour)
    expect(page).to have_summary_list_row("Clawback amount", "")
    expect(page).to have_summary_list_row("Reason for clawback", "")
    expect(page).to have_element(:strong, text: "We will show clawback details to the school.", class: "govuk-warning-text__text")
    expect(page).to have_button("Request clawback")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def when_i_click_on_change
    first("a", text: "Change").click
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner("Clawback requested")
  end

  def and_i_see_the_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
  end

  def and_i_see_the_claim_status_is_clawback_requested
    expect(page).to have_claim_card({
      "title" => "#{@claim_not_approved_claim.reference} - #{@claim_not_approved_claim.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@claim_not_approved_claim.id}",
      "status" => "Clawback requested",
      "academic_year" => @claim_not_approved_claim.academic_year.name,
      "provider_name" => @claim_not_approved_claim.provider.name,
      "submitted_at" => I18n.l(@claim_not_approved_claim.submitted_at.to_date, format: :long),
      "amount" => @claim_not_approved_claim.amount,
    })
  end
end
