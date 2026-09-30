require "rails_helper"

RSpec.describe Claims::Sampling::SendProviderRemindersJob, type: :job do
  subject(:send_reminders_job) { described_class.new }

  let(:provider) { create(:claims_provider) }
  let(:provider_user) { create(:claims_provider_user, providers: [provider]) }
  let(:another_provider_user) { create(:claims_provider_user, providers: [provider]) }
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
    it "sends emails to all provider users with the correct wait time" do
      provider_user
      another_provider_user

      send_reminders_job.perform
      expect(Claims::ProviderMailer).to have_received(:sampling_checks_required).once.with(provider_sampling, provider_user)
      expect(Claims::ProviderMailer).to have_received(:sampling_checks_required).once.with(provider_sampling, another_provider_user)
      expect(mail).to have_received(:deliver_later).twice.with(wait: wait_time)
    end

    context "when provider has no users" do
      it "does not send any emails" do
        send_reminders_job.perform
        expect(Claims::ProviderMailer).not_to have_received(:sampling_checks_required)
        expect(mail).not_to have_received(:deliver_later)
      end
    end
  end
end
