require "rails_helper"

RSpec.describe "Support user changes the mentor who is being rejected by the provider",
               service: :claims,
               type: :system do
  scenario do
    given_a_claim_exists
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim

    when_i_click_on_confirm_provider_rejected_claim
    then_i_see_the_mentor_selection_page

    when_i_select_john_smith
    and_i_click_on_continue
    then_i_see_the_rejection_reason_page_for_john_smith

    when_i_enter_a_reason_why_the_provider_rejected_john_smith
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_rejection_details_for_john_smith

    when_i_click_to_change_mentor
    then_i_see_the_mentor_selection_page
    and_john_smith_is_preselected

    when_i_unselect_john_smith
    and_i_select_jane_doe
    and_i_click_on_continue
    then_i_see_the_rejection_reason_page_for_jane_doe

    when_i_enter_a_reason_why_the_provider_rejected_jane_doe
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_rejection_details_for_jane_doe
    and_i_do_not_see_the_rejection_details_for_john_smith

    when_i_click_on_confirm_and_reject_claim
    then_i_see_that_the_claim_has_been_updated_to_provider_not_approved
  end

  private

  def given_a_claim_exists
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_in_progress)
    @mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    @mentor_jane_doe = create(:claims_mentor, first_name: "Jane", last_name: "Doe")
    @john_smith_mentor_training = create(:mentor_training, mentor: @mentor_john_smith, claim: @claim, hours_completed: 20)
    @jane_doe_mentor_training = create(:mentor_training, mentor: @mentor_jane_doe, claim: @claim, hours_completed: 15)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Auditing"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Auditing (1)")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Auditing")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def when_i_click_to_view_the_claim
    click_on "#{@claim.reference} - #{@claim.school.name}"
  end

  def then_i_see_the_details_of_the_claim
    expect(page).to have_title(
      "#{@claim.school.name} - Auditing - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Auditing - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@claim.school.name)
    expect(page).to have_element(:strong, text: "Audit requested", class: "govuk-tag govuk-tag--yellow")
  end

  def when_i_click_on_confirm_provider_rejected_claim
    click_on "Confirm provider rejected claim"
  end

  def then_i_see_that_the_claim_has_been_updated_to_provider_not_approved
    expect(page).to have_current_path(claims_support_claims_sampling_path(@claim), ignore_query: true)
    expect(page).to have_title(
      "#{@claim.school.name} - Auditing - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :p,
      text: "Auditing - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1(@claim.school.name)

    expect(page).to have_element(:strong, text: "Rejected by provider", class: "govuk-tag govuk-tag--turquoise")
    expect(page).to have_success_banner("Claim updated")
  end

  def then_i_see_the_mentor_selection_page
    expect(page).to have_title(
      "Select a mentor - Provider rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:span, text: "Provider rejection - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1("Rejection details from the provider")
    expect(page).to have_element(:legend, text: "Which mentors are being rejected?")
    expect(page).to have_element(:div, text: "Include mentors which need partial or whole clawback.", class: "govuk-hint")
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def when_i_select_john_smith
    check "John Smith"
  end

  def then_i_see_the_rejection_reason_page_for_john_smith
    expect(page).to have_title(
      "What reason has the provider given for rejecting John Smith? - Provider rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Provider rejection - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("What reason has the provider given for rejecting John Smith?")
    expect(page).to have_element(
      :div,
      text: "The school originally claimed John Smith has completed 20 hours.",
      class: "govuk-inset-text",
    )
    expect(page).to have_element(:label, text: "Only include details related to John Smith", class: "govuk-label")
  end

  def when_i_enter_a_reason_why_the_provider_rejected_john_smith
    fill_in "Only include details related to John Smith", with: "Provider rejected John Smith"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Provider rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Provider rejection - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Check your answers")
    expect(page).to have_element(
      :div,
      text: "Rejecting these mentors will update the claim status to ‘rejected by provider’.",
      class: "govuk-warning-text",
    )
  end

  def and_i_see_the_rejection_details_for_john_smith
    expect(page).to have_summary_list_row("Mentor", "John Smith")
    expect(page).to have_summary_list_row("Original number of hours claimed", "20")
    expect(page).to have_summary_list_row("Reason for rejection", "Provider rejected John Smith")
  end

  def and_john_smith_is_preselected
    expect(page).to have_checked_field("John Smith")
  end

  def when_i_click_on_confirm_and_reject_claim
    click_on "Confirm and reject claim"
  end

  def when_i_click_to_change_mentor
    click_on "Change Mentor"
  end

  def when_i_unselect_john_smith
    uncheck "John Smith"
  end

  def and_i_select_jane_doe
    check "Jane Doe"
  end

  def then_i_see_the_rejection_reason_page_for_jane_doe
    expect(page).to have_title(
      "What reason has the provider given for rejecting Jane Doe? - Provider rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Provider rejection - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("What reason has the provider given for rejecting Jane Doe?")
    expect(page).to have_element(
      :div,
      text: "The school originally claimed Jane Doe has completed 15 hours.",
      class: "govuk-inset-text",
    )
    expect(page).to have_element(:label, text: "Only include details related to Jane Doe", class: "govuk-label")
  end

  def when_i_enter_a_reason_why_the_provider_rejected_jane_doe
    fill_in "Only include details related to Jane Doe", with: "Provider rejected Jane Doe"
  end

  def and_i_see_the_rejection_details_for_jane_doe
    expect(page).to have_summary_list_row("Mentor", "Jane Doe")
    expect(page).to have_summary_list_row("Original number of hours claimed", "15")
    expect(page).to have_summary_list_row("Reason for rejection", "Provider rejected Jane Doe")
  end

  def and_i_do_not_see_the_rejection_details_for_john_smith
    expect(page).not_to have_summary_list_row("Mentor", "John Smith")
    expect(page).not_to have_summary_list_row("Original number of hours claimed", "20")
    expect(page).not_to have_summary_list_row("Reason for rejection", "Provider rejected John Smith")
  end
end
