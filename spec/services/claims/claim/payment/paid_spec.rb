require "rails_helper"

describe Claims::Claim::Payment::Paid do
  let(:school) { create(:claims_school) }
  let!(:school_user) { create(:claims_user, schools: [school]) }
  let!(:claim) { create(:claim, :payment_in_progress, school:) }

  before { allow(NotifyRateLimiter).to receive(:call).and_call_original }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to paid" do
      expect { call }.to change(claim, :status)
        .from("payment_in_progress")
        .to("paid")
    end

    it "notifies the school users that their claim payment is being processed" do
      call

      expect(NotifyRateLimiter).to have_received(:call).once.with(
        collection: [school_user],
        mailer: "Claims::UserMailer",
        mailer_method: :claim_payment_in_progress_notification,
        mailer_args: [claim],
        initial_wait_time: 0.minutes,
      )
    end

    context "when a notification wait time is given" do
      subject(:call) { described_class.call(claim:, notification_wait_time: 3.minutes) }

      it "delays the notifications by the wait time" do
        call

        expect(NotifyRateLimiter).to have_received(:call).once.with(
          hash_including(initial_wait_time: 3.minutes),
        )
      end
    end

    context "when payment details are given" do
      subject(:call) do
        described_class.call(claim:, paid_to_la: true, date_paid: "2026-09-21")
      end

      it "stores the payment details against the claim" do
        call

        expect(claim.reload).to have_attributes(
          status: "paid",
          paid_to_la: true,
          date_paid: Time.zone.parse("2026-09-21"),
        )
      end
    end
  end
end
