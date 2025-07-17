require "rails_helper"

describe Claims::ClaimActivitiesForClaimQuery do
  subject(:result) { described_class.call(claim:) }

  let(:claim) { create(:claim, :submitted) }
  let(:user) { create(:claims_support_user) }
  let(:other_claim) { create(:claim, :submitted) }

  describe "#call" do
    context "when activities exist across all related record types" do
      let!(:direct_activity_for_claim) do
        create(:claim_activity, record_type: "Claims::Claim", record_id: claim.id, user: user, action: "sampling_uploaded")
      end

      let!(:activity_for_sampling) do
        sampling = create(:claims_sampling).tap do |s|
          ps = create(:provider_sampling, sampling: s)
          create(:claims_provider_sampling_claim, provider_sampling: ps, claim: claim)
        end
        create(:claim_activity, record_type: "Claims::Sampling", record_id: sampling.id, user: user, action: "sampling_uploaded")
      end

      let!(:activity_for_clawback) do
        clawback = create(:clawback).tap do |c|
          create(:clawback_claim, clawback: c, claim: claim)
        end
        create(:claim_activity, record_type: "Claims::Clawback", record_id: clawback.id, user: user, action: "sampling_uploaded")
      end

      let!(:activity_for_payment) do
        payment = create(:claims_payment).tap do |p|
          create(:claims_payment_claim, payment: p, claim: claim)
        end
        create(:claim_activity, record_type: "Claims::Payment", record_id: payment.id, user: user, action: "payment_request_delivered")
      end

      it "returns only activities related to the given claim" do
        create(:claim_activity, record_type: "Claims::Claim", record_id: other_claim.id, user: user, action: "sampling_uploaded")
        expect(result).to contain_exactly(
          direct_activity_for_claim,
          activity_for_sampling,
          activity_for_clawback,
          activity_for_payment,
        )
      end
    end

    context "when only direct claim activities exist" do
      let!(:direct_activity_for_claim) do
        create(:claim_activity, record_type: "Claims::Claim", record_id: claim.id, user: user, action: "sampling_uploaded")
      end

      it "returns just the direct activity for the given claim" do
        expect(result).to contain_exactly(direct_activity_for_claim)
      end
    end

    context "when there are multiple activities for the claim" do
      let!(:older_activity) do
        create(:claim_activity, record_type: "Claims::Claim", record_id: claim.id, user: user, action: "sampling_uploaded", created_at: 3.days.ago)
      end

      let!(:newer_activity) do
        create(:claim_activity, record_type: "Claims::Claim", record_id: claim.id, user: user, action: "sampling_uploaded", created_at: 1.day.ago)
      end

      it "orders them by created_at ascending" do
        expect(result).to eq([older_activity, newer_activity])
      end
    end
  end
end
