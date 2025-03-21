require "rails_helper"

RSpec.describe Claims::Clawback::UpdateCollectionWithESFAResponseJob, type: :job do
  let(:claims) { create_list(:claim, 2, :submitted, status: :clawback_in_progress) }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claims.pluck(:id)) }

    it "enqueues a Claims::Clawback::UpdateClaimWithESFAResponseJob per claim" do
      expect { perform }.to have_enqueued_job(
        Claims::Clawback::UpdateClaimWithESFAResponseJob,
      ).exactly(:twice)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claims.pluck(:id))
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
