require "rails_helper"

describe Claims::Clawback::CreateAndDeliver do
  subject(:create_and_deliver) { described_class.call(current_user:) }

  let(:current_user) { create(:claims_support_user) }
  let(:claims) { [create(:claim, :submitted, status: :clawback_requested)] }

  describe "#call" do
    context "when there are claims with the status 'clawback_requested'" do
      before { claims }

      it "creates a new claim activity, changes the status of 'clawback_requested' claims to 'clawback_in_progress'
        and enqueues the delivery of an email to the ESFA" do
        expect { create_and_deliver }.to change(Claims::Clawback, :count).by(1)
        .and change(Claims::ClaimActivity, :count).by(1)
        .and change { Claims::Claim.pluck(:status).uniq }.from(%w[clawback_requested]).to(%w[clawback_in_progress])
        .and enqueue_mail(Claims::ESFAMailer, :claims_require_clawback)
      end
    end

    context "when there are no claims with the status 'clawback_requested'" do
      it "returns nil" do
        expect(create_and_deliver).to be_nil
      end
    end
  end
end
