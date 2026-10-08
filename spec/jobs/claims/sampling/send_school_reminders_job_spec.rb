require "rails_helper"

RSpec.describe Claims::Sampling::SendSchoolRemindersJob, type: :job do
  subject(:send_reminders_job) { described_class.new }

  let(:school) { build(:claims_school) }
  let(:amendment_notification_sent_at) { 1.week.ago }
  let!(:claim) do
    create(:claim, status: :sampling_provider_not_approved, school:, amendment_notification_sent_at:)
  end
  let!(:school_user) { create(:claims_user, email: "example@example.com", schools: [school]) }

  before do
    allow(NotifyRateLimiter).to receive(:call).and_call_original
  end

  describe "#perform" do
    it "calls the notify rate limiter with the expected collection" do
      send_reminders_job.perform
      expect(NotifyRateLimiter).to have_received(:call).once.with(
        batch_size: 1,
        collection: [school_user],
        mailer: "Claims::UserMailer",
        mailer_method: :claim_rejected_by_provider_reminder,
        mailer_args: [claim.decorate],
      )
    end

    context "when there are no outstanding claims" do
      let(:claim) { build(:claim, status: :approved, school:) }

      it "does not call the notify rate limiter" do
        send_reminders_job.perform
        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when the school has not been recorded as notified" do
      let(:amendment_notification_sent_at) { nil }

      it "does not call the notify rate limiter" do
        send_reminders_job.perform
        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when the evidence deadline has passed" do
      let(:amendment_notification_sent_at) { 45.days.ago }

      it "does not call the notify rate limiter" do
        send_reminders_job.perform
        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when today is the evidence deadline" do
      let(:amendment_notification_sent_at) { Time.zone.local(2026, 10, 5, 9) }

      it "calls the notify rate limiter" do
        Timecop.freeze(Time.zone.local(2026, 11, 4, 10)) do
          send_reminders_job.perform
          expect(NotifyRateLimiter).to have_received(:call).once
        end
      end
    end
  end
end
