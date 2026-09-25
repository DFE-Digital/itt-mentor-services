require "rails_helper"

describe Claims::PaymentResponse::Process do
  subject(:process) { described_class.call(payment_response:, current_user:) }

  let(:payment_response) { create(:claims_payment_response, csv_file: file_fixture("example-payments-response.csv")) }
  let(:current_user) { create(:claims_support_user) }

  describe "#call" do
    it "does nothing when there are no claims with payment in progress" do
      expect { process }.to not_change(Claims::ClaimActivity, :count)
    end

    context "when there are claims with payment in progress" do
      let(:approved_claim) { create(:claim, :payment_in_progress, reference: "12345678") }
      let(:rejected_claim) { create(:claim, :payment_in_progress, reference: "23456789") }
      let(:paid_claim) { create(:claim, :paid, reference: "34567890") }
      let(:ignored_claim) { create(:claim, :payment_in_progress, reference: "45678901") }

      it "creates a payment, activity, updates claims statuses to 'payment_in_progress', and enqueues the deliver of an email to the ESFA" do
        expect { process }.to change(Claims::ClaimActivity, :count).by(1)
          .and change { approved_claim.reload.status }.from("payment_in_progress").to("paid")
          .and change { rejected_claim.reload.status }.from("payment_in_progress").to("payment_information_requested")
          .and change { rejected_claim.reload.unpaid_reason }.from(nil).to("A reason")
          .and(not_change { paid_claim.reload.status })
          .and(not_change { ignored_claim.reload.status })
      end
    end
  end
end
