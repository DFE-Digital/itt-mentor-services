require "rails_helper"

RSpec.describe Claims::Claim::InvalidProviderNotification, type: :service do
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
      let!(:claim1) { create(:claim, created_by: user, status: :invalid_provider) }
      let!(:claim2) { create(:claim, created_by: user, status: :invalid_provider) }

      let!(:other_claim) { create(:claim, created_by: other_user, status: :invalid_provider) }

      before do
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(user.id, [claim1.id, claim2.id]).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(other_user.id, [other_claim.id]).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

        described_class.call
      end

      it "sends email notifications to users with invalid provider claims" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user.id, [claim1.id, claim2.id])
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(other_user.id, [other_claim.id])
      end

      it "does not send duplicate notifications for the same user" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user.id, [claim1.id, claim2.id]).once
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
            claims = Claims::Claim.where(created_by: user, status: :invalid_provider)
            expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user.id, claims.ids)
            expect(mailer_double).to have_received(:deliver_later).with(wait: 0.minutes)
          end

          users[100..149].each do |user|
            claims = Claims::Claim.where(created_by: user, status: :invalid_provider)
            expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user.id, claims.ids)
            expect(mailer_double).to have_received(:deliver_later).with(wait: 1.minute)
          end
        end
      end
    end
  end
end
