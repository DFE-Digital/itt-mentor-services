require "rails_helper"

RSpec.describe Claims::User::NotifyUsersOfInvalidProviderClaimsJob, type: :job do
  describe "#perform" do
    before do
      allow(Claims::Claim::InvalidProviderNotification).to receive(:call).and_return(true)
    end

    it "does not call the Claims::Claim::InvalidProviderNotification service if there is no current claim window" do
      described_class.perform_now
      expect(Claims::Claim::InvalidProviderNotification).not_to have_received(:call)
    end

    it "calls the Claims::Claim::InvalidProviderNotification service when there is a current claim window" do
      create(:claim_window, :current)
      described_class.perform_now
      expect(Claims::Claim::InvalidProviderNotification).to have_received(:call)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
