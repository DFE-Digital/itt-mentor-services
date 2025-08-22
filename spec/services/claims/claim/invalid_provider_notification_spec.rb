require "rails_helper"

RSpec.describe Claims::Claim::InvalidProviderNotification, type: :service do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "#call" do
    let(:user) { build(:claims_user) }
    let(:other_user) { build(:claims_user) }

    context "when there are no claims with invalid provider status" do
      let(:user) { build(:claims_user) }
      let(:claim_1) { create(:claim, created_by: user, status: :submitted) }

      before do
        claim_1
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)

        described_class.call
      end

      it "does not send notification" do
        expect(Claims::UserMailer).not_to have_received(:claims_assigned_to_invalid_provider)
      end
    end

    context "when there are claims with invalid provider status" do
      let(:claim1) { create(:claim, created_by: user, status: :invalid_provider) }
      let(:claim2) { create(:claim, created_by: user, status: :invalid_provider) }

      let(:other_claim) { create(:claim, created_by: other_user, status: :invalid_provider) }

      before do
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(user).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(other_user).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

        claim1
        claim2
        other_claim

        described_class.call
      end

      it "sends email notifications to users with invalid provider claims" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user)
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(other_user)
      end

      it "does not send duplicate notifications for the same user" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user).once
      end

      context "when there are over 100 emails to send" do
        let(:mailer_double) { instance_double(ActionMailer::MessageDelivery) }
        let(:users) { create_list(:claims_user, 150) }

        before do
          users.each do |user|
            create(:claim, created_by: user, status: :invalid_provider)
          end

          allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider).and_return(mailer_double)
          allow(mailer_double).to receive(:deliver_later)

          described_class.call
        end

        it "sends notifications in batches and delays them accordingly", :aggregate_failures do
          users[0..99].each do |user|
            expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user)
          end

          users[100..149].each do |user|
            expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user)
          end

          expect(mailer_double).to have_received(:deliver_later).with(wait: 0.minutes).exactly(100).times
          expect(mailer_double).to have_received(:deliver_later).with(wait: 1.minute).exactly(52).times
        end
      end
    end

    context "when there are invalid claims in previous academic years" do
      let(:current_academic_year) { create(:academic_year, :current) }
      let(:previous_academic_year) { create(:academic_year, :historic) }

      let(:current_claim_window) { create(:claim_window, :current) }
      let(:older_claim_window_in_current_academic_year) { create(:claim_window, starts_on: 4.months.ago, ends_on: 3.months.ago, academic_year: current_academic_year) }
      let(:historic_claim_window) { create(:claim_window, :historic) }

      before do
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(user).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(other_user).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
      end

      it "only notifies users with invalid-provider claims in claim windows for the current academic_year" do
        create(:claim, created_by: user, status: :invalid_provider, claim_window: current_claim_window)
        create(:claim, created_by: user, status: :invalid_provider, claim_window: historic_claim_window)

        create(:claim, created_by: other_user, status: :invalid_provider, claim_window: historic_claim_window)

        described_class.call

        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user)
        expect(Claims::UserMailer).not_to have_received(:claims_assigned_to_invalid_provider).with(other_user)
      end

      it "deduplicates notifications per user even when multiple claim windows exist in the same academic year" do
        create(:claim, created_by: user, status: :invalid_provider, claim_window: current_claim_window)
        create(:claim, created_by: user, status: :invalid_provider, claim_window: older_claim_window_in_current_academic_year)

        described_class.call

        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user).once
      end
    end
  end
end
