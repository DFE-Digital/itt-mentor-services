require "rails_helper"

describe Claims::Payment::CreateAndDeliver do
  subject(:create_and_deliver) { described_class.call(current_user:, claim_window:) }

  let(:claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }
  let(:current_user) { create(:claims_support_user) }

  describe "#call" do
    it "does nothing when there are no submitted claims" do
      expect { create_and_deliver }.to not_change(Claims::Payment, :count)
        .and not_change(Claims::ClaimActivity, :count)
        .and not_enqueue_mail(Claims::PaymentMailer, :payment_created_notification)
    end

    context "when there are submitted claims" do
      let(:historic_claim_window) { build(:claim_window, :historic) }
      let!(:current_claim) { create(:claim, :submitted, claim_window:) }
      let!(:historic_claim) { create(:claim, :submitted, claim_window: historic_claim_window) }

      it "creates a payment, activity, updates claims statuses to 'payment_in_progress',
        and enqueues the delivery of an email to the ESFA" do
        expect { create_and_deliver }.to change(Claims::Payment, :count).by(1)
          .and change(Claims::ClaimActivity, :count).by(1)
          .and change { current_claim.reload.status }.from("submitted").to("payment_in_progress")
          .and enqueue_mail(Claims::PaymentMailer, :payment_created_notification)
      end

      it "does not deliver claims from a different claim window" do
        expect { create_and_deliver }.not_to change { historic_claim.reload.status }.from("submitted")
      end
    end
  end
end
