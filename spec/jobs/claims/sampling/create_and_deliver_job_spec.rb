require "rails_helper"

RSpec.describe Claims::Sampling::CreateAndDeliverJob, type: :job do
  let(:current_user) { create(:claims_user) }
  let(:claims) { create_list(:claim, 3) }

  describe "#perform" do
    before do
      allow(Claims::Sampling::CreateAndDeliver).to receive(:call).and_return(true)
    end

    it "calls the Claims::Sampling::CreateAndDeliver service" do
      described_class.perform_now(current_user_id: current_user.id, claim_ids: claims.map(&:id))
      expect(Claims::Sampling::CreateAndDeliver).to have_received(:call).with(current_user:, claims:).once
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(current_user_id: current_user.id, claim_ids: claims.map(&:id))
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
