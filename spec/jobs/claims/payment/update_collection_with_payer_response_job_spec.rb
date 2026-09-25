require "rails_helper"

RSpec.describe Claims::Payment::UpdateCollectionWithPayerResponseJob, type: :job do
  let(:claims) { create_list(:claim, 2, :payment_in_progress) }
  let(:claim_update_details) do
    [
      { id: claims[0].id, status: "unpaid", unpaid_reason: "Some reason" },
      { id: claims[1].id, status: "paid", unpaid_reason: nil },
    ]
  end

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    context "when the status in the update details are either paid or unpaid" do
      it "enqueues a Claims::Sampling::UpdateClaimWithProviderResponseJob per claim" do
        expect { described_class.perform_now(claim_update_details) }.to have_enqueued_job(
          Claims::Payment::UpdateClaimWithPayerResponseJob,
        ).exactly(:twice)
      end
    end

    context "when more than 100 school users will be notified of payment" do
      let(:claims) { create_list(:claim, 2, :payment_in_progress) }
      let(:claim_update_details) do
        [
          { id: claims[0].id, status: "paid", unpaid_reason: nil },
          { id: claims[1].id, status: "paid", unpaid_reason: nil },
        ]
      end

      before do
        create_list(:claims_user, 60, schools: [claims[0].school])
        create_list(:claims_user, 60, schools: [claims[1].school])
      end

      it "delays the notifications so no more than 100 emails are sent a minute" do
        expect { perform }.to have_enqueued_job(Claims::Payment::UpdateClaimWithPayerResponseJob)
          .with(anything, notification_wait_time: 0.minutes)
          .and have_enqueued_job(Claims::Payment::UpdateClaimWithPayerResponseJob)
          .with(anything, notification_wait_time: 1.minute)
      end
    end

    context "when the status in the update details is not paid or unpaid" do
      let(:claim_update_details) do
        [
          { id: claims[0].id, status: "clawback_complete", unpaid_reason: "Some reason" },
          { id: claims[1].id, status: "blah", unpaid_reason: nil },
        ]
      end

      it "does not enqueue a Claims::Sampling::UpdateClaimWithProviderResponseJob" do
        expect { described_class.perform_now(claim_update_details) }.not_to have_enqueued_job(
          Claims::Payment::UpdateClaimWithPayerResponseJob,
        )
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
