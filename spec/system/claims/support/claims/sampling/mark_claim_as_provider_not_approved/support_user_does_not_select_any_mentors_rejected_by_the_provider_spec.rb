require "rails_helper"

RSpec.describe "Support user does not select any mentors rejected by the provider", service: :claims, type: :system do
  scenario do
    given_a_claim_exists
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim

    when_i_click_on_confirm_provider_rejected_claim
    then_i_see_the_mentor_selection_page

    when_i_click_on_continue
    then_i_see_a_validation_error_select_a_mentor
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
    expect(page).to have_element(:strong, text: "Audit requested", class: "govuk-tag govuk-tag--yellow")
  end

  def when_i_click_on_confirm_provider_rejected_claim
    click_on "Confirm provider rejected claim"
  end

  def then_i_see_the_mentor_selection_page
    expect(page).to have_title(
      "Select a mentor - Rejected by provider - Claim #{@claim.reference} - Sampling - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:span, text: "Rejected by provider - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1("Rejection details from the provider")
    expect(page).to have_element(:legend, text: "Which mentors are being rejected?")
    expect(page).to have_element(:div, text: "Include mentors which need partial or whole clawback.", class: "govuk-hint")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_select_a_mentor
    expect(page).to have_validation_error("Select a mentor")
  end
end
