require "rails_helper"

RSpec.describe Claims::ClaimHelper do
  describe "#claim_statuses_for_selection" do
    it "returns an array of claims statuses, except draft statuses" do
      expect(claim_statuses_for_selection).to contain_exactly(
        "submitted",
        "payment_in_progress",
        "payment_information_requested",
        "payment_information_sent",
        "paid",
        "payment_not_approved",
        "sampling_in_progress",
        "sampling_provider_not_approved",
        "sampling_not_approved",
        "clawback_requested",
        "clawback_in_progress",
        "clawback_complete",
        "invalid_provider",
        "clawback_requires_approval",
        "clawback_rejected",
      )
    end
  end
end
