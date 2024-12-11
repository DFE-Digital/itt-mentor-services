require "rails_helper"

RSpec.describe Claims::Sampling::UpdateCollectionWithProviderResponseJob, type: :job do
  let(:claims) { create_list(:claim, 2, :submitted, status: :sampling_in_progress) }
  let(:claim_update_details) do
    [
      { id: claims[0].id, status: :sampling_provider_not_approved, not_assured_reason: nil },
      { id: claims[1].id, status: :paid, not_assured_reason: nil },
    ]
  end

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    it "enqueues a Claims::Sampling::UpdateClaimWithProviderResponseJob per claim" do
      expect { described_class.perform_now(claim_update_details) }.to have_enqueued_job(
        Claims::Sampling::UpdateClaimWithProviderResponseJob,
      ).exactly(:twice)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
