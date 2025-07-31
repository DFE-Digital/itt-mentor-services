require "rails_helper"

RSpec.describe NotifyRateLimiterJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let(:wait_time) { 1.minute }
    let(:batch) { create_list(:claims_user, 5) }
    let(:mailer) { "Claims::UserMailer" }
    let(:mailer_method) { :claims_have_not_been_submitted }
    let(:mailer_args) { %w[arg1] }
    let(:mailer_kwargs) { { name: "Bob" } }

    before do
      create(:claim_window, :current)
      create(:claim_window, :upcoming)
    end

    it "enqueues a mailer job for each record with wait time", :aggregate_failures do
      expect {
        described_class.perform_now(wait_time, batch, mailer, mailer_method)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(batch.size).times
    end

    context "when the mailer method has additional arguments" do
      let(:batch) { create_list(:claims_user, 1) }

      it "enqueues a mailer job with the correct arguments", :aggregate_failures do
        described_class.perform_now(wait_time, batch, mailer, mailer_method, mailer_args, mailer_kwargs)

        batch.each do |item|
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.with(
            mailer.to_s,
            mailer_method.to_s,
            "deliver_now",
            { args: [item, mailer_args, mailer_kwargs] },
          )
        end
      end
    end
  end
end
