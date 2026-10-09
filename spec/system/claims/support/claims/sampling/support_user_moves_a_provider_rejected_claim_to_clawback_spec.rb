require "rails_helper"

RSpec.describe "Support user moves a provider rejected claim to clawback", service: :claims, type: :system do
  scenario do
    given_a_provider_rejected_claim_exists
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_request_clawback
    then_the_claim_requires_clawback_approval
    and_the_clawback_amount_is_calculated_from_the_amended_hours

    when_i_click_on_review_clawback
    then_i_can_review_the_clawback_that_i_requested
  end

  private

  def given_a_provider_rejected_claim_exists
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved,
                    amendment_notification_sent_at: 60.days.ago)
    mentor = create(:claims_mentor, first_name: "Jane", last_name: "Smith")
    @mentor_training = create(:mentor_training,
                              claim: @claim,
                              mentor:,
                              hours_completed: 20,
                              hours_clawed_back: 8,
                              not_assured: true,
                              reason_not_assured: "Incorrect number of hours")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_view_the_claim
    visit claims_support_claims_sampling_path(@claim)
  end

  def and_i_click_on_request_clawback
    click_on "Request clawback"
  end

  def then_the_claim_requires_clawback_approval
    expect(page).to have_current_path(claims_support_claims_clawback_path(@claim))
    expect(page).to have_element(:strong, text: "Clawback requires approval", class: "govuk-tag")
    expect(@claim.reload.status).to eq("clawback_requires_approval")
  end

  def and_the_clawback_amount_is_calculated_from_the_amended_hours
    expect(page).to have_content(@mentor_training.reload.clawback_amount.format(symbol: true))
  end

  def when_i_click_on_review_clawback
    click_on "Review clawback"
  end

  def then_i_can_review_the_clawback_that_i_requested
    expect(page).to have_current_path(/approval/)
  end
end
