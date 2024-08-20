require "rails_helper"

RSpec.describe Claims::ClaimHelper do
  describe "#claim_statuses_for_selection" do
    it "returns an array of claims statuses, except draft statuses" do
      expect(claim_statuses_for_selection).to contain_exactly("paid", "payment_not_approved", "payment_information_sent", "payment_information_requested", "payment_in_progress", "submitted")
    end
  end
end
