require "rails_helper"

RSpec.describe Claims::Sampling::UpdateClaimWithProviderResponseJob, type: :job do
  let(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }
  let(:claim_update_details) { { id: claim.id, status:, not_assured_reason: nil } }
  let(:status) { :paid }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    context "when the updated status is paid" do
      it "changes the status of the claim to paid" do
        perform
        expect(claim.reload.status).to eq("paid")
      end
    end

    context "when the updated status is sampling_provider_not_approved" do
      let(:status) { :sampling_provider_not_approved }

      it "changes the status of the claim to sampling_provider_not_approved" do
        perform
        expect(claim.reload.status).to eq("sampling_provider_not_approved")
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
