require "rails_helper"

describe Claims::Claim::Sampling::Paid do
  include_context "with an attributed claim operation"
  let!(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to paid" do
      expect { call }.to change(claim, :status)
        .from("sampling_in_progress")
        .to("paid")
    end
  end
end
