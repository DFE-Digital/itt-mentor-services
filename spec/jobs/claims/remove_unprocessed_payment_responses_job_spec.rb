require "rails_helper"

RSpec.describe Claims::RemoveUnprocessedPaymentResponsesJob, type: :job do
  describe "queue name" do
    subject { described_class.new.queue_name }

    it { is_expected.to eq("default") }
  end

  describe "#perform" do
    subject(:perform) { described_class.perform_now }

    let!(:processed_payment_response) { create(:claims_payment_response, processed: true, created_at: 1.day.ago) }

    it "does nothing" do
      expect { perform }.not_to change(Claims::PaymentResponse, :count)

      expect { processed_payment_response.reload }.not_to raise_error
    end

    context "when there are old unprocessed claims payment responses" do
      let!(:old_unprocessed_payment_response) { create(:claims_payment_response, created_at: 1.day.ago) }
      let!(:recent_unprocessed_payment_response) { create(:claims_payment_response, created_at: Time.current) }

      it "deletes unprocessed claim payment responses over a day old" do
        expect { perform }.to change(Claims::PaymentResponse, :count).by(-1)

        expect { old_unprocessed_payment_response.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { recent_unprocessed_payment_response.reload }.not_to raise_error
        expect { processed_payment_response.reload }.not_to raise_error
      end
    end
  end
end
