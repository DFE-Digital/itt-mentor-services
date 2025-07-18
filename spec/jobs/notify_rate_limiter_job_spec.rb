require "rails_helper"

RSpec.describe NotifyRateLimiterJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let(:wait_time) { 1.minute }
    let(:batch) { create_list(:claims_user, 5) }
    let(:mailer) { Claims::UserMailer }
    let(:mailer_method) { :claims_have_not_been_submitted }

    before do
      create(:claim_window, :current)
      create(:claim_window, :upcoming)
    end

    it "enqueues a mailer job for each record with wait time", :aggregate_failures do
      expect {
        described_class.perform_now(wait_time, batch, mailer:, mailer_method:)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(batch.size).times
    end
  end
end
