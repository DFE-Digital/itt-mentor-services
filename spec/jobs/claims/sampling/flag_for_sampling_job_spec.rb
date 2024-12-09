require "rails_helper"

RSpec.describe Claims::Sampling::FlagForSamplingJob, type: :job do
  let(:claim) { create(:claim, :submitted, :paid) }

  describe "#perform" do
    it "enqueues a Claims::Sampling::FlagForSamplingJob per" do
      expect { described_class.perform_now(claim) }.to change(claim, :status)
        .from("paid").to("sampling_in_progress")
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
