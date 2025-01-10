require "rails_helper"

describe Claims::Claim::Sampling::InProgress do
  let!(:claim) { create(:claim, :submitted, status: :paid) }
  let(:sampling_reason) { "ABCD" }

  describe "#call" do
    subject(:call) { described_class.call(claim:, sampling_reason:) }

    it "changes to status of the claim to provider not approved" do
      expect { call }.to change(claim, :status)
        .from("paid")
        .to("sampling_in_progress")
    end

    it "updates the sampling reason of the claim" do
      expect { call }.to change(claim, :sampling_reason)
        .from(nil)
        .to("ABCD")
    end
  end
end
