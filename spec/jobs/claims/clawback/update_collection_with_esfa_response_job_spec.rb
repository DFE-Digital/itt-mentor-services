require "rails_helper"

RSpec.describe Claims::Clawback::UpdateCollectionWithESFAResponseJob, type: :job do
  let(:claims) { create_list(:claim, 2, :submitted, status: :clawback_in_progress) }
  let(:claim_update_details) do
    [
      { id: claims[0].id, status: :clawback_complete, not_assured_reason: nil },
      { id: claims[1].id, status: :clawback_complete, not_assured_reason: nil },
    ]
  end

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    it "enqueues a Claims::Clawback::UpdateClaimWithESFAResponseJob per claim" do
      expect { described_class.perform_now(claim_update_details) }.to have_enqueued_job(
        Claims::Clawback::UpdateClaimWithESFAResponseJob,
      ).exactly(:twice)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
