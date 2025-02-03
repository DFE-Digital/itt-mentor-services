require "rails_helper"

RSpec.describe Claims::Payment::UpdateClaimWithPayerResponseJob, type: :job do
  let(:claim) { create(:claim, :payment_in_progress) }
  let(:claim_update_details) { { id: claim.id, status:, unpaid_reason: } }
  let(:status) { "paid" }
  let(:unpaid_reason) { "Some reason" }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    context "when the updated status is paid" do
      it "changes the status of the claim to paid" do
        perform
        expect(claim.reload.status).to eq("paid")
      end
    end

    context "when the updated status is unpaid" do
      let(:status) { "unpaid" }

      it "changes the status of the claim to payment_information_requested" do
        perform
        expect(claim.reload.status).to eq("payment_information_requested")
      end
    end

    context "when the updated status is payment_in_progress" do
      let(:status) { "payment_in_progress" }

      it "does not change the claim status" do
        perform
        expect(claim.reload.status).to eq("payment_in_progress")
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
