require "rails_helper"

RSpec.describe "View claims activity log", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user, first_name: "Colin", last_name: "Chapman") }
  let(:created_at) { Time.zone.parse("20 December 2024 16:00") }

  let(:payment_request_delivered) { create(:claim_activity, :payment_request_delivered, user: support_user, created_at:) }
  let(:sampling_uploaded) { create(:claim_activity, :sampling_uploaded, user: support_user, created_at: created_at + 1.day) }

  scenario "Support user views the claims activity log" do
    given_i_sign_in_as(support_user)
    given_there_are_claim_activities
    when_i_visit_the_claims_activity_log
    then_i_can_see_the_claims_activities
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_are_claim_activities
    [payment_request_delivered, sampling_uploaded]
  end

  def when_i_visit_the_claims_activity_log
    click_on "Claims"
    click_on "Activity log"
  end

  def then_i_can_see_the_claims_activities
    within(".app-timeline__item:nth-child(1)") do
      expect(page).to have_content("Sampling data uploaded")
      expect(page).to have_content("Colin Chapman on 21 December 2024 at 4:00pm")
    end

    within(".app-timeline__item:nth-child(2)") do
      expect(page).to have_content("Claims sent to payer for payment")
      expect(page).to have_content("Colin Chapman on 20 December 2024 at 4:00pm")
    end
  end
end
