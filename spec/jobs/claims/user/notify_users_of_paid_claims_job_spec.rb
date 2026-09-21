require "rails_helper"

RSpec.describe Claims::User::NotifyUsersOfPaidClaimsJob, type: :job do
  subject(:notify_users_job) { described_class.new }

  let(:school) { create(:claims_school) }
  let!(:school_user) { create(:claims_user, email: "example@example.com", schools: [school]) }

  before do
    allow(NotifyRateLimiter).to receive(:call).and_call_original
  end

  describe "#perform" do
    context "when a claim was paid today" do
      let!(:claim) { create(:claim, :paid, school:, date_paid: Time.current) }

      it "calls the notify rate limiter with the expected collection" do
        notify_users_job.perform

        expect(NotifyRateLimiter).to have_received(:call).once.with(
          batch_size: 1,
          collection: [school_user],
          mailer: "Claims::UserMailer",
          mailer_method: :claim_paid_notification,
          mailer_args: [claim],
        )
      end

      it "records that the claim has been notified" do
        expect { notify_users_job.perform }.to change { claim.reload.paid_notification_sent_at }.from(nil)
      end
    end

    context "when a claim was paid on an earlier day and has not been notified" do
      let!(:claim) { create(:claim, :paid, school:, date_paid: 3.days.ago) }

      it "calls the notify rate limiter" do
        notify_users_job.perform

        expect(NotifyRateLimiter).to have_received(:call).once.with(
          batch_size: 1,
          collection: [school_user],
          mailer: "Claims::UserMailer",
          mailer_method: :claim_paid_notification,
          mailer_args: [claim],
        )
      end
    end

    context "when a claim has already been notified" do
      before do
        create(:claim, :paid, school:, date_paid: Time.current, paid_notification_sent_at: 1.hour.ago)
      end

      it "does not call the notify rate limiter" do
        notify_users_job.perform

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when a claim has a date_paid in the future" do
      before { create(:claim, :paid, school:, date_paid: 1.day.from_now) }

      it "does not call the notify rate limiter" do
        notify_users_job.perform

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when a paid claim has no date_paid" do
      before { create(:claim, :paid, school:, date_paid: nil) }

      it "does not call the notify rate limiter" do
        notify_users_job.perform

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when a claim has a date_paid of today but is not paid" do
      before { create(:claim, :payment_in_progress, school:, date_paid: Time.current) }

      it "does not call the notify rate limiter" do
        notify_users_job.perform

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    it "enqueues the job in the default queue" do
      expect { described_class.perform_later }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
