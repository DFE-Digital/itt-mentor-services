require "rails_helper"

RSpec.describe "Claim activities", type: :request do
  describe "GET /resend_payer_email" do
    context "when the action is unknown", service: :claims do
      it "raises an error" do
        claim_activity = create(:claim_activity, action: :sampling_uploaded, record: create(:claims_sampling))

        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        expect {
          get resend_payer_email_claims_support_claims_claim_activity_path(claim_activity)
        }.to raise_error("Unknown action: sampling_uploaded")
      end
    end
  end
end
