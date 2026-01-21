require "rails_helper"

RSpec.describe Claims::Slack::DailyRoundupJob, type: :job do
  include MoneyRails::ActionViewExtension

  describe "#perform" do
    let(:slack_notifier) { instance_double(Claims::ClaimSlackNotifier) }
    let(:slack_message) { instance_double(SlackNotifier::Message, deliver_now: true) }

    before do
      allow(Claims::ClaimSlackNotifier).to receive(:new).and_return(slack_notifier)
      allow(slack_notifier).to receive(:claim_submitted_notification).and_return(slack_message)
    end

    context "when there is no current claim window" do
      before do
        allow(Claims::ClaimWindow).to receive(:current).and_return(nil)
      end

      it "does not send a notification" do
        described_class.perform_now

        expect(slack_notifier).not_to have_received(:claim_submitted_notification)
        expect(slack_message).not_to have_received(:deliver_now)
      end
    end

    context "when there are no claims" do
      it "sends the daily claims notification" do
        claim_window = create(:claim_window, :current)

        described_class.perform_now

        expect(slack_notifier).to have_received(:claim_submitted_notification).with(
          academic_year: claim_window.academic_year,
          claim_count: 0,
          school_count: 0,
          provider_count: 0,
          invalid_claim_count: 0,
          claim_amount: humanized_money_with_symbol(0),
          total_claims_count: 0,
          total_claims_amount: humanized_money_with_symbol(0),
          average_claim_amount: humanized_money_with_symbol(0),
        )

        expect(slack_message).to have_received(:deliver_now)
      end
    end

    context "when there are claims" do
      it "sends the daily claims notification" do
        claim_window = create(:claim_window, :current)
        _invalid_claim = create(:claim, claim_window:, status: :invalid_provider, created_at: 2.weeks.ago)
        _previous_claim = create(:claim, claim_window:,
                                         created_at: 2.weeks.ago,
                                         mentor_trainings: build_list(:mentor_training, 3, hours_completed: 15))
        yesterdays_claim = create(:claim, claim_window:,
                                          created_at: Time.current.yesterday.change(hour: 16),
                                          mentor_trainings: build_list(:mentor_training, 3, hours_completed: 15))

        described_class.perform_now

        total_claims_amount = Claims::Claim.all.map(&:amount).sum
        average_claim_amount = total_claims_amount / Claims::Claim.count.to_f

        expect(slack_notifier).to have_received(:claim_submitted_notification).with(
          academic_year: claim_window.academic_year,
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
end
