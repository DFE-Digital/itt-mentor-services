require "rails_helper"

describe Claims::Payment::CreateAndDeliver do
  describe "#call" do
    let(:current_user) { create(:claims_support_user) }

    context "when there are no submitted claims" do
      it "does not create a payment" do
        expect { described_class.call(current_user:) }.not_to change(Claims::Payment, :count)
      end
    end

    context "when there are submitted claims" do
      let!(:submitted_claims) { create_list(:claim, 3, :submitted) }

      it "creates a payment" do
        expect { described_class.call(current_user:) }.to change(Claims::Payment, :count)
          .and change { submitted_claims.map(&:reload).map(&:status).uniq }.to(%w[sent_to_esfa])
          .and enqueue_mail(Claims::PaymentMailer, :payment_created_notification)
      end
    end
  end
end
