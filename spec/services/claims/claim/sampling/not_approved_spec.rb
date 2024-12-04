require "rails_helper"

describe Claims::Claim::Sampling::NotApproved do
  let!(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to provider not approved" do
      expect { call }.to change(claim, :status)
        .from("sampling_provider_not_approved")
        .to("sampling_not_approved")
    end
  end
end
