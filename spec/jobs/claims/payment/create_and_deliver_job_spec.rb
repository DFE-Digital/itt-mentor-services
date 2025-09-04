require "rails_helper"

RSpec.describe Claims::Payment::CreateAndDeliverJob, type: :job do
  let(:current_user) { create(:claims_user) }
  let(:claim_window) { create(:claim_window, :historic) }

  describe "#perform" do
    before do
      allow(Claims::Payment::CreateAndDeliver).to receive(:call).and_return(true)
    end

    it "calls the Claims::Payment::CreateAndDeliver service" do
      described_class.perform_now(current_user_id: current_user.id, claim_window_id: claim_window.id)
      expect(Claims::Payment::CreateAndDeliver).to have_received(:call).with(current_user:, claim_window:).once
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(current_user_id: current_user.id, claim_window_id: claim_window.id)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
