require "rails_helper"

RSpec.describe "Support user changes the reason the school rejected the mentor", service: :claims, type: :system do
  scenario do
    given_a_claim_exists
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim

    when_i_click_on_reject_claim
    then_i_see_the_rejection_reason_page_for_john_smith

    when_i_enter_a_reason_why_the_school_rejected_john_smith
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_rejection_details_for_john_smith

    when_i_click_on_change_reason_for_rejection_for_john_smith
    then_i_see_the_rejection_reason_page_for_john_smith
    and_the_reason_why_the_school_rejected_john_smith_is_prefilled

    when_i_enter_a_new_reason_why_the_school_rejected_john_smith
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_new_rejection_details_for_john_smith

    when_i_click_on_confirm_and_reject_claim
    then_i_see_that_the_claim_has_been_updated_to_not_approved
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
                                         reason_not_assured: "Invalid claim.")
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
    expect(page).to have_element(:strong, text: "Rejected by provider", class: "govuk-tag govuk-tag--turquoise")
  end

  def when_i_click_on_reject_claim
    click_on "Reject claim"
  end

  def then_i_see_that_the_claim_has_been_updated_to_not_approved
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

    expect(page).to have_element(:strong, text: "Rejected by school", class: "govuk-tag govuk-tag--turquoise")
    expect(page).to have_success_banner("Claim updated")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def when_i_enter_a_new_reason_why_the_school_rejected_john_smith
    fill_in "Only include details related to John Smith", with: "New reason school rejected John Smith"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - School rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "School rejection - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Check your answers")
    expect(page).to have_element(
      :div,
      text: "This will update the claim status to ‘rejected by school’ and move it to the clawback queue.",
      class: "govuk-warning-text",
    )
  end

  def and_i_see_the_rejection_details_for_john_smith
    within("#school_rejection_details_#{@john_smith_mentor_training.id}") do
      expect(page).to have_summary_list_row("Original hours claimed", "20")
      expect(page).to have_summary_list_row("Provider comments", "Invalid claim")
      expect(page).to have_summary_list_row("Reason for rejection", "School rejected John Smith")
    end
  end

  def and_i_see_the_new_rejection_details_for_john_smith
    within("#school_rejection_details_#{@john_smith_mentor_training.id}") do
      expect(page).to have_summary_list_row("Original hours claimed", "20")
      expect(page).to have_summary_list_row("Provider comments", "Invalid claim")
      expect(page).to have_summary_list_row("Reason for rejection", "New reason school rejected John Smith")
    end
  end

  def and_the_reason_why_the_school_rejected_john_smith_is_prefilled
    find_field "Only include details related to John Smith", with: "School rejected John Smith"
  end

  def when_i_click_on_confirm_and_reject_claim
    click_on "Confirm and reject claim"
  end

  def then_i_see_the_rejection_reason_page_for_jane_doe
    expect(page).to have_title(
      "What is the schools response to the claim about Jane Doe? - School rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "School rejection - Claim #{@claim.reference}",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("What is the schools response to the claim about Jane Doe?")
    expect(page).to have_element(:p, text: "Provider response", class: "govuk-heading-s")
    expect(page).to have_element(:p, text: "Incorrect number of training hours", class: "govuk-body")
    expect(page).to have_element(
      :div,
      text: "The school originally claimed Jane Doe has completed 15 hours.",
      class: "govuk-inset-text",
    )
    expect(page).to have_element(:label, text: "Only include details related to Jane Doe", class: "govuk-label")
  end

  def then_i_see_the_rejection_reason_page_for_john_smith
    expect(page).to have_title(
      "What is the schools response to the claim about John Smith? - School rejection - Claim #{@claim.reference} - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "School rejection - Claim #{@claim.reference}",
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

  def when_i_enter_a_reason_why_the_school_rejected_john_smith
    fill_in "Only include details related to John Smith", with: "School rejected John Smith"
  end

  def when_i_click_on_change_reason_for_rejection_for_john_smith
    click_on "Change Reason for rejection for John Smith"
  end
end
