require "rails_helper"

RSpec.describe "Claims Reminders", type: :request do
  describe "POST /claims/support/claims_reminders/send_schools_not_submitted_claims" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:next_claim_window) { create(:claim_window, :upcoming) }
    let(:claims_school) { build(:claims_school, eligible_claim_windows: [claim_window]) }
    let!(:claims_user) { create(:claims_user, schools: [claims_school]) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      next_claim_window
      sign_in_as support_user
      mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(Claims::UserMailer).to receive(:claims_have_not_been_submitted).and_return(mailer_double)
    end

    it "sends reminders to users and redirects with a flash message" do
      post send_schools_not_submitted_claims_claims_support_claims_reminders_path

      expect(Claims::UserMailer).to have_received(:claims_have_not_been_submitted).at_least(:once).with(claims_user)
    end
  end
end
