require "rails_helper"

RSpec.describe NotifyEmailDispatchJob, type: :job do
  describe "#perform" do
    it "schedules the email batches via NotifyEmailRateLimiter" do
      expect(NotifyEmailRateLimiter).to receive(:schedule!)

      described_class.perform_now
    end
  end
end
