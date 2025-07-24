require "rails_helper"

RSpec.describe Claims::Slack::DailyRoundupJob, type: :job do
  include MoneyRails::ActionViewExtension

  describe "#perform" do
    let!(:claim_window) { create(:claim_window, :current) }
    let(:claims) { create_list(:claim, 3, claim_window:, created_at: 2.weeks.ago) }
    let(:previous_claim_mentor_trainings) { build_list(:mentor_training, 3, hours_completed: 15) }
    let(:previous_claim) { create(:claim, claim_window:, created_at: 2.weeks.ago, mentor_trainings: previous_claim_mentor_trainings) }
    let(:invalid_claim) { create(:claim, claim_window:, status: :invalid_provider, created_at: 2.weeks.ago) }
    let(:yesterdays_claim_mentor_trainings) { build_list(:mentor_training, 3, hours_completed: 15) }
    let(:yesterdays_claim) { create(:claim, claim_window:, created_at: Time.current.yesterday.change(hour: 16), mentor_trainings: yesterdays_claim_mentor_trainings) }
    let(:slack_notifier) { instance_double(Claims::ClaimSlackNotifier) }

    let(:slack_message) { instance_double(SlackNotifier::Message, deliver_now: true) }

    before do
      previous_claim
      yesterdays_claim
      invalid_claim

      allow(Claims::ClaimSlackNotifier).to receive(:new).and_return(slack_notifier)
      allow(slack_notifier).to receive(:claim_submitted_notification).and_return(slack_message)
    end

    it "sends the daily claims notification" do
      described_class.perform_now

      total_claims_amount = Claims::Claim.all.map(&:amount).sum
      average_claim_amount = total_claims_amount / Claims::Claim.count.to_f

      expect(slack_notifier).to have_received(:claim_submitted_notification).with(
        claim_count: 1,
        school_count: 1,
        provider_count: 0,
        invalid_claim_count: 1,
        claim_amount: humanized_money_with_symbol(yesterdays_claim.amount),
        total_claims_count: 3,
        total_claims_amount: humanized_money_with_symbol(total_claims_amount),
        average_claim_amount: humanized_money_with_symbol(average_claim_amount),
      )

      expect(slack_message).to have_received(:deliver_now)
    end
  end
end
