require "rails_helper"

RSpec.describe Claims::Sampling::SendProviderRemindersJob, type: :job do
  subject(:send_reminders_job) { described_class.new }

  let(:provider) { create(:provider, email_addresses: %w[example@example.com example2@example.com]) }
  let(:claim) { build(:claim, status: :sampling_in_progress, provider:) }
  let(:provider_sampling) { build(:provider_sampling, provider:) }
  let(:provider_sampling_claim) { create(:claims_provider_sampling_claim, claim:, provider_sampling:) }
  let(:wait_time) { 0.minutes }
  let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

  before do
    allow(Claims::ProviderMailer).to receive(:sampling_checks_required).and_return(mail)
    provider_sampling_claim
  end

  describe "#perform" do
    it "sends emails to all provider email addresses with the correct wait time" do
      send_reminders_job.perform
      expect(Claims::ProviderMailer).to have_received(:sampling_checks_required).once.with(provider_sampling, "example@example.com")
      expect(Claims::ProviderMailer).to have_received(:sampling_checks_required).once.with(provider_sampling, "example2@example.com")
      expect(mail).to have_received(:deliver_later).twice.with(wait: wait_time)
    end

    context "when provider has no email addresses" do
      before do
        # Creating a provider via the factory always creates email addresses so we need to remove them
        provider.provider_email_addresses.destroy_all
      end

      it "does not send any emails" do
        send_reminders_job.perform
        expect(Claims::ProviderMailer).not_to have_received(:sampling_checks_required)
        expect(mail).not_to have_received(:deliver_later)
      end
    end
  end
end
