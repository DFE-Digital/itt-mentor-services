require "rails_helper"

RSpec.describe "Support user does not enter a reason why the provider rejected the mentor",
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

    when_i_click_on_continue
    then_i_see_a_validation_error_for_entering_a_reason_with_john_smith_was_rejected_by_the_provider
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

  def then_i_see_the_mentor_selection_page
    expect(page).to have_title(
      "Select a mentor - Provider rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:span, text: "Provider rejection - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1("Rejection details from the provider")
    expect(page).to have_element(:legend, text: "Which mentors are being rejected?")
    expect(page).to have_element(:div, text: "Include mentors which need partial or whole clawback.", class: "govuk-hint")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

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

  def then_i_see_a_validation_error_for_entering_a_reason_with_john_smith_was_rejected_by_the_provider
    expect(page).to have_validation_error("Enter the reason the provider has given for rejecting this mentor.")
  end
end
