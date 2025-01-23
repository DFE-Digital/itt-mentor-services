require "rails_helper"

RSpec.describe "View a claims activity", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user, first_name: "Colin", last_name: "Chapman") }
  let(:created_at) { Time.zone.parse("20 December 2024 16:00") }

  let(:payment_request_delivered) { create(:claim_activity, :payment_request_delivered, user: support_user, created_at:) }
  let(:sampling_uploaded) { create(:claim_activity, :sampling_uploaded, user: support_user, created_at: created_at + 1.day) }

  scenario "Support user visits a 'payment_request_delivered' activity" do
    given_i_sign_in_as(support_user)
    and_there_are_claim_activities(payment_request_delivered)
    when_i_visit_the_claims_activity_by_url(payment_request_delivered)
    then_i_can_see_the_claims_activity_payment_request_delivered_details
  end

  scenario "Support user views a 'sampling_uploaded' activity" do
    given_i_sign_in_as(support_user)
    and_there_are_claim_activities(sampling_uploaded)
    when_i_visit_the_claims_activity_log
    and_i_click_on_view_all_files_of_a_claim_activity
    then_i_can_see_the_claims_activity_sampling_uploaded_details
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def and_there_are_claim_activities(*activities)
    [*activities]
  end

  def when_i_visit_the_claims_activity_by_url(activity)
    visit claims_support_claims_claim_activity_path(activity)
  end

  def when_i_visit_the_claims_activity_log
    click_on "Claims"
    click_on "Activity log"
  end

  def and_i_click_on_view_all_files_of_a_claim_activity
    click_on "View all files"
  end

  def then_i_can_see_the_claims_activity_payment_request_delivered_details
    expect(page).to have_css("h1.govuk-heading-l", text: "Claims sent to payer")
    expect(page).to have_content("Colin Chapman on 20 December 2024 at 4:00pm")
  end

  def then_i_can_see_the_claims_activity_sampling_uploaded_details
    expect(page).to have_css("h1.govuk-heading-l", text: "Audit data uploaded")
    expect(page).to have_content("Colin Chapman on 21 December 2024 at 4:00pm")
  end
end
