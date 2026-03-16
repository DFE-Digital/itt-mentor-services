require "rails_helper"

class TestClaimsApplicationMailer < Claims::ApplicationMailer
  def sample_email
    notify_email to: "test@example.com", subject: "Test subject", body: "Test body"
  end
end

RSpec.describe Claims::ApplicationMailer, type: :mailer do
  include ActiveJob::TestHelper

  describe "#service_name" do
    it "returns the claims service name" do
      expect(described_class.new.send(:service_name)).to eq("Claim funding for mentor training")
    end
  end

  describe "#support_email" do
    it "returns the claims support email" do
      expect(described_class.new.send(:support_email)).to eq("ittmentor.funding@education.gov.uk")
    end
  end

  describe "#host" do
    it "returns the CLAIMS_HOST" do
      expect(described_class.new.send(:host)).to eq("claims.localhost")
    end
  end

  describe "delivery scheduling" do
    subject(:message_delivery) { TestClaimsApplicationMailer.sample_email }

    let(:next_working_day) { Date.parse("2026-03-17") }

    before do
      allow(BankHoliday).to receive(:is_bank_holiday?).with(Date.current).and_return(is_bank_holiday)
      allow(BankHoliday).to receive(:next_working_day).with(Date.current).and_return(next_working_day)
      clear_enqueued_jobs
    end

    context "when today is not a bank holiday" do
      let(:is_bank_holiday) { false }

      it "enqueues immediately with no wait_until override" do
        expect {
          message_delivery.deliver_later
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "TestClaimsApplicationMailer",
          "sample_email",
          "deliver_now",
          args: [],
        )
      end
    end

    context "when today is a bank holiday" do
      let(:is_bank_holiday) { true }

      it "reschedules the email to the next working day" do
        expect {
          message_delivery.deliver_later
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "TestClaimsApplicationMailer",
          "sample_email",
          "deliver_now",
          args: [],
        ).at(next_working_day.beginning_of_day)
      end
    end
  end
end
