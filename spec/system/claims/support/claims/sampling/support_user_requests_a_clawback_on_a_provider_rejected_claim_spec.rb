require "rails_helper"

RSpec.describe "Support user requests a clawback on a provider rejected claim", service: :claims, type: :system do
  scenario "before the evidence deadline" do
    given_a_provider_rejected_claim_exists(notified_at: 1.day.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    then_i_see_the_approve_button_but_not_the_request_clawback_button

    when_i_visit_the_request_clawback_page_directly
    then_i_am_returned_to_the_claim
  end

  scenario "after the evidence deadline" do
    given_a_provider_rejected_claim_exists(notified_at: 60.days.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_request_clawback
    then_i_see_the_clawback_details_page
  end

  private

  def given_a_provider_rejected_claim_exists(notified_at:)
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved,
                    amendment_notification_sent_at: notified_at)
    @mentor = create(:claims_mentor, first_name: "Jane", last_name: "Smith")
    create(:mentor_training,
           claim: @claim,
           mentor: @mentor,
           hours_completed: 20,
           not_assured: true,
           reason_not_assured: "Incorrect number of hours")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_view_the_claim
    visit claims_support_claims_sampling_path(@claim)
  end

  def then_i_see_the_approve_button_but_not_the_request_clawback_button
    expect(page).to have_link("Approve claim")
    expect(page).not_to have_link("Request clawback")
  end

  def when_i_visit_the_request_clawback_page_directly
    visit new_request_clawback_claims_support_claims_clawbacks_path(@claim)
  end

  def then_i_am_returned_to_the_claim
    expect(page).to have_current_path(claims_support_claims_sampling_path(@claim))
    expect(page).to have_element(:strong, text: "Rejected by provider", class: "govuk-tag govuk-tag--teal")
  end

  def and_i_click_on_request_clawback
    click_on "Request clawback"
  end

  def then_i_see_the_clawback_details_page
    expect(page).to have_h1("Clawback details")
    expect(page).to have_content("Incorrect number of hours")
    expect(page).not_to have_content("School comments")
  end
end
