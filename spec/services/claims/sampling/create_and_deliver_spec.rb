require "rails_helper"

describe Claims::Sampling::CreateAndDeliver do
  subject(:create_and_deliver) { described_class.call(current_user:, claims:, csv_data:) }

  let(:current_user) { create(:claims_support_user) }
  let!(:claims) { [create(:claim, :paid)] }
  let(:csv_data) { [{ id: claims.first.id, sample_reason: "ABCD" }] }

  describe "#call" do
    context "when there are submitted claims" do
      it "creates a new claim activity, changes the status of 'paid' claims to 'sampling_in_progress'
        and enqueues the delivery of an email to the providers" do
        expect { create_and_deliver }.to change(Claims::Sampling, :count).by(1)
        .and change(Claims::ClaimActivity, :count).by(1)
        .and change { Claims::Claim.pluck(:status).uniq }.from(%w[paid]).to(%w[sampling_in_progress])
        .and change { Claims::Claim.pluck(:sampling_reason).uniq }.from([nil]).to(%w[ABCD])
        .and enqueue_mail(Claims::ProviderMailer, :sampling_checks_required)
      end
    end
  end
end
