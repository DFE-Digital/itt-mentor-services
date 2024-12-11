require "rails_helper"

describe Claims::Claim::Sampling::ProviderNotApproved do
  let!(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to provider not approved" do
      expect { call }.to change(claim, :status)
        .from("sampling_in_progress")
        .to("sampling_provider_not_approved")
    end
  end
end
