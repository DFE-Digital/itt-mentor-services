require "rails_helper"

describe Claims::Payment::CreateAndDeliver do
  subject(:create_and_deliver) { described_class.call(current_user:) }

  let(:current_user) { create(:claims_support_user) }

  describe "#call" do
    it "does nothing when there are no submitted claims" do
      expect { create_and_deliver }.to not_change(Claims::Payment, :count)
        .and not_change(Claims::ClaimActivity, :count)
        .and not_enqueue_mail(Claims::PaymentMailer, :payment_created_notification)
    end

    context "when there are submitted claims" do
      before do
        create(:claim, :submitted)
      end

      it "creates a payment, activity, updates claims statuses to 'payment_in_progress', and enqueues the deliver of an email to the ESFA" do
        expect { create_and_deliver }.to change(Claims::Payment, :count).by(1)
          .and change(Claims::ClaimActivity, :count).by(1)
          .and change { Claims::Claim.pluck(:status).uniq }.from(%w[submitted]).to(%w[payment_in_progress])
          .and enqueue_mail(Claims::PaymentMailer, :payment_created_notification)
      end
    end
  end
end
