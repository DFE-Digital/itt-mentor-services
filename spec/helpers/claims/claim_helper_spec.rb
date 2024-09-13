require "rails_helper"

RSpec.describe Claims::ClaimHelper do
  describe "#claim_statuses_for_selection" do
    it "returns an array of claims statuses, except draft statuses" do
      expect(claim_statuses_for_selection).to contain_exactly("submitted", "sent_to_esfa")
    end
  end
end
