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
          .with(user, [claim1, claim2]).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
        allow(Claims::UserMailer).to receive(:claims_assigned_to_invalid_provider)
          .with(other_user, [other_claim]).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

        described_class.call
      end

      it "sends email notifications to users with invalid provider claims" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user, [claim1, claim2])
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(other_user, [other_claim])
      end

      it "does not send duplicate notifications for the same user" do
        expect(Claims::UserMailer).to have_received(:claims_assigned_to_invalid_provider).with(user, [claim1, claim2]).once
      end
    end
  end
end
