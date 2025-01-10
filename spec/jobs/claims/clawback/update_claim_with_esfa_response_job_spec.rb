require "rails_helper"

RSpec.describe Claims::Clawback::UpdateClaimWithESFAResponseJob, type: :job do
  let(:claim) { create(:claim, :submitted, status: :clawback_in_progress) }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim) }

    it "changes the status of the claim to sampling_provider_not_approved" do
      perform
      expect(claim.reload.status).to eq("clawback_complete")
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
