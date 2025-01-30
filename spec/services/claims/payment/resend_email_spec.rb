require "rails_helper"

describe Claims::Payment::ResendEmail do
  subject(:resend_email) { described_class.call(payment:) }

  let(:payment) { create(:claims_payment) }

  describe "#call" do
    it "enqueues the delivery of an email" do
      expect { resend_email }.to enqueue_mail(Claims::PaymentMailer, :resend_payment_created_notification).once
    end
  end
end
