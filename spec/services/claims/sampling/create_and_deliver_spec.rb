require "rails_helper"

describe Claims::Sampling::CreateAndDeliver do
  subject(:create_and_deliver) { described_class.call(current_user:, claims:) }

  let(:current_user) { create(:claims_support_user) }
  let!(:claims) { [create(:claim, :paid)] }

  describe "#call" do
    context "when there are submitted claims" do
      it "does a thing" do
        expect { create_and_deliver }.to change(Claims::Sampling, :count).by(1)
        .and change(Claims::ClaimActivity, :count).by(1)
        .and change { Claims::Claim.pluck(:status).uniq }.from(%w[paid]).to(%w[sampling_in_progress])
        .and enqueue_mail(Claims::ProviderMailer, :sampling_checks_required)
      end
    end
  end
end
