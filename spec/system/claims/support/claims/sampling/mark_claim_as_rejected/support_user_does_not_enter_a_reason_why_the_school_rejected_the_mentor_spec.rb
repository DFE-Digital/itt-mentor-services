require "rails_helper"

RSpec.describe "Support user does not enter a reason why the school rejected the mentor",
               service: :claims,
               type: :system do
  scenario do
    given_a_claim_exists
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim

    when_i_click_on_reject_claim
    then_i_see_the_confirmation_page

    when_i_click_on_continue
    then_i_see_the_rejection_reason_page_for_john_smith

    when_i_click_on_continue
    then_i_see_a_validation_error_for_entering_a_reason_with_john_smith_was_rejected_by_the_provider
  end

  private

  def given_a_claim_exists
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved)
    @mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    @john_smith_mentor_training = create(:mentor_training,
                                         mentor: @mentor_john_smith,
                                         claim: @claim,
                                         hours_completed: 20,
                                         not_assured: true,
                                         reason_not_assured: "Invalid claim")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Sampling"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Sampling (1)")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Sampling")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def when_i_click_to_view_the_claim
    click_on "#{@claim.reference} - #{@claim.school.name}"
  end

  def then_i_see_the_details_of_the_claim
    expect(page).to have_title(
      "#{@claim.school.name} - Sampling - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Sampling - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@claim.school.name)
    expect(page).to have_element(:strong, text: "Rejected by provider", class: "govuk-tag govuk-tag--turquoise")
  end

  def when_i_click_on_reject_claim
    click_on "Reject claim"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_rejection_reason_page_for_john_smith
    expect(page).to have_title(
      "What is the schools response to the claim about John Smith? - Reject - Claim #{@claim.reference} - Sampling - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Reject - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("What is the schools response to the claim about John Smith?")
    expect(page).to have_element(:p, text: "Provider response", class: "govuk-heading-s")
    expect(page).to have_element(:p, text: "Invalid claim", class: "govuk-body")
    expect(page).to have_element(
      :div,
      text: "The school originally claimed John Smith has completed 20 hours.",
      class: "govuk-inset-text",
    )
    expect(page).to have_element(:label, text: "Only include details related to John Smith", class: "govuk-label")
  end

  def then_i_see_a_validation_error_for_entering_a_reason_with_john_smith_was_rejected_by_the_provider
    expect(page).to have_validation_error("Enter the response the school has given for rejecting this mentor.")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Are you sure you want to reject the claim? - Reject - Claim #{@claim.reference} - Sampling - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Reject - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Are you sure you want to reject the claim?")
    expect(page).to have_element(:p, text: "To reject this claim, you must have:")
    expect(page).to have_element(
      :li,
      text: "reviewed any evidence sent by the school and deemed it insufficient to prove the claim is legitimate",
    )
    expect(page).to have_element(
      :li,
      text: "received second approval from within the support team or policy team",
    )
    expect(page).to have_element(
      :li,
      text: "contacted the school to let them know their evidence has been rejected",
    )
    expect(page).to have_element(
      :li,
      text: "told the school which claims you are rejecting and how much will be clawed back",
    )
  end
end
