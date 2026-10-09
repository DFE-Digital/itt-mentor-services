require "rails_helper"

RSpec.describe "Move a provider rejected claim to clawback", service: :claims, type: :request do
  let(:support_user) { create(:claims_support_user) }
  let(:amendment_notification_sent_at) { 60.days.ago }
  let(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved, amendment_notification_sent_at:) }

  before do
    create(:mentor_training, claim:, hours_completed: 20, hours_clawed_back: 5, not_assured: true, reason_not_assured: "Reason")
    sign_in_as support_user
  end

  it "moves the claim to clawback requires approval" do
    post "/support/claims/clawbacks/claims/move_to_clawback/#{claim.id}"

    expect(response).to redirect_to("/support/claims/clawbacks/claims/#{claim.id}")
    expect(claim.reload).to have_attributes(status: "clawback_requires_approval", clawback_requested_by: support_user)
  end

  context "when the evidence deadline has not passed" do
    let(:amendment_notification_sent_at) { 1.day.ago }

    it "does not move the claim" do
      post "/support/claims/clawbacks/claims/move_to_clawback/#{claim.id}"

      expect(claim.reload.status).to eq("sampling_provider_not_approved")
    end
  end

  context "when the claim has not been rejected by the provider" do
    let(:claim) { create(:claim, :submitted, status: :sampling_not_approved) }

    it "does not move the claim" do
      post "/support/claims/clawbacks/claims/move_to_clawback/#{claim.id}"

      expect(claim.reload.status).to eq("sampling_not_approved")
    end
  end

  context "when the user is not a support user" do
    let(:support_user) { create(:claims_user) }

    it "does not move the claim" do
      post "/support/claims/clawbacks/claims/move_to_clawback/#{claim.id}"

      expect(claim.reload.status).to eq("sampling_provider_not_approved")
    end
  end
end
