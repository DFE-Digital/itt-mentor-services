require "rails_helper"

RSpec.describe Claims::Slack::DailyRoundupJob, type: :job do
  describe "#perform" do
    let!(:claim_window) { create(:claim_window, :current) }
    let(:claims) { create_list(:claim, 3, claim_window:, created_at: 2.weeks.ago) }
    let(:yesterday_claims) { create_list(:claim, 2, claim_window:, created_at: Time.current.yesterday.change(hour: 16)) }
    let(:slack_notifier) { instance_double(Claims::ClaimSlackNotifier) }

    before do
      claims
      yesterday_claims
      allow(Claims::ClaimSlackNotifier).to receive(:new).and_return(slack_notifier)
      allow(slack_notifier).to receive(:daily_submitted_claims_notification)
    end

    it "sends the daily claims notification" do
      described_class.perform_now

      expect(slack_notifier).to have_received(:daily_submitted_claims_notification).with(
        claim_count: 2,
        school_count: 2,
        provider_count: 0,
        total_claims_count: 5,
      )
    end
  end
end
