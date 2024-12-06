require "rails_helper"

describe Claims::Claim::Sampling::InProgress do
  let!(:claim) { create(:claim, :submitted, status: :paid) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to provider not approved" do
      expect { call }.to change(claim, :status)
        .from("paid")
        .to("sampling_in_progress")
    end
  end
end
