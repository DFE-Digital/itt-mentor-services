require "rails_helper"

describe Claims::ClaimActivitiesForClaimQuery do
  subject(:query_result) { described_class.call(claim:) }

  let(:claim) { create(:claim, :submitted) }
  let(:other_claim) { create(:claim, :submitted) }
  let(:user) { create(:claims_support_user) }

  describe "#call" do
    context "with activities on the claim and all related records" do
      let(:direct_claim_four_days_ago) { create(:claim_activity, :sampling_uploaded, user:, record: claim, created_at: 4.days.ago) }
      let(:sampling_activity_three_days_ago) do
        sampling = build(:claims_sampling, claims_for_link: [claim])
        create(:claim_activity, :sampling_uploaded, user:, record: sampling, created_at: 3.days.ago)
      end
      let(:clawback_activity_two_days_ago) do
        clawback = build(:clawback, claims_for_link: [claim])
        create(:claim_activity, :clawback_request_delivered, user:, record: clawback, created_at: 2.days.ago)
      end
      let(:payment_activity_one_day_ago) do
        payment = build(:claims_payment, claims_for_link: [claim])
        create(:claim_activity, :payment_request_delivered, user:, record: payment, created_at: 1.day.ago)
      end
      let(:unused_claim_activity) { create(:claim_activity, :sampling_uploaded, user:, record: other_claim, created_at: 5.days.ago) }

      it "returns only the claim's activities in ascending order" do
        unused_claim_activity
        expect(query_result).to eq([
          direct_claim_four_days_ago,
          sampling_activity_three_days_ago,
          clawback_activity_two_days_ago,
          payment_activity_one_day_ago,
        ])
      end
    end

    context "with only direct activities on the claim" do
      let(:older_direct_activity) { create(:claim_activity, :sampling_uploaded, user:, record: claim, created_at: 3.days.ago) }
      let(:newer_direct_activity) { create(:claim_activity, :sampling_uploaded, user:, record: claim, created_at: 1.day.ago) }
      let(:unrelated_direct_activity) { create(:claim_activity, :sampling_uploaded, user:, record: other_claim, created_at: 2.days.ago) }

      it "returns only direct activities in ascending order" do
        unrelated_direct_activity
        expect(query_result).to eq([older_direct_activity, newer_direct_activity])
      end
    end

    context "with only sampling activities for the claim" do
      let(:older_sampling_activity) do
        sampling = build(:claims_sampling, claims_for_link: [claim])
        create(:claim_activity, :sampling_uploaded, user:, record: sampling, created_at: 2.days.ago)
      end
      let(:newer_sampling_activity) do
        sampling = build(:claims_sampling, claims_for_link: [claim])
        create(:claim_activity, :sampling_uploaded, user:, record: sampling, created_at: 1.day.ago)
      end
      let(:other_claim_sampling_activity) do
        other_sampling = build(:claims_sampling, claims_for_link: [other_claim])
        create(:claim_activity, :sampling_uploaded, user:, record: other_sampling, created_at: 3.days.ago)
      end

      it "returns only sampling activities in ascending order" do
        other_claim_sampling_activity
        expect(query_result).to eq([older_sampling_activity, newer_sampling_activity])
      end
    end

    context "with only clawback activities for the claim" do
      let(:older_clawback_activity) do
        clawback = build(:clawback, claims_for_link: [claim])
        create(:claim_activity, :clawback_request_delivered, user:, record: clawback, created_at: 2.days.ago)
      end
      let(:newer_clawback_activity) do
        clawback = build(:clawback, claims_for_link: [claim])
        create(:claim_activity, :clawback_request_delivered, user:, record: clawback, created_at: 1.day.ago)
      end
      let(:other_claim_clawback_activity) do
        other_clawback = build(:clawback, claims_for_link: [other_claim])
        create(:claim_activity, :clawback_request_delivered, user:, record: other_clawback, created_at: 3.days.ago)
      end

      it "returns only clawback activities in ascending order" do
        other_claim_clawback_activity
        expect(query_result).to eq([older_clawback_activity, newer_clawback_activity])
      end
    end

    context "with only payment activities for the claim" do
      let(:older_payment_activity) do
        payment = build(:claims_payment, claims_for_link: [claim])
        create(:claim_activity, :payment_request_delivered, user:, record: payment, created_at: 2.days.ago)
      end
      let(:newer_payment_activity) do
        payment = build(:claims_payment, claims_for_link: [claim])
        create(:claim_activity, :payment_request_delivered, user:, record: payment, created_at: 1.day.ago)
      end
      let(:other_claim_payment_activity) do
        other_payment = build(:claims_payment, claims_for_link: [other_claim])
        create(:claim_activity, :payment_request_delivered, user:, record: other_payment, created_at: 3.days.ago)
      end

      it "returns only payment activities in ascending order" do
        other_claim_payment_activity
        expect(query_result).to eq([older_payment_activity, newer_payment_activity])
      end
    end

    context "with activities across multiple related records of the same type" do
      let(:sampling_two_days_ago) do
        sampling = build(:claims_sampling, claims_for_link: [claim])
        create(:claim_activity, :sampling_uploaded, user:, record: sampling, created_at: 2.days.ago)
      end
      let(:sampling_one_day_ago) do
        sampling = build(:claims_sampling, claims_for_link: [claim])
        create(:claim_activity, :sampling_uploaded, user:, record: sampling, created_at: 1.day.ago)
      end

      it "returns all matching activities in ascending order" do
        expect(query_result).to eq([sampling_two_days_ago, sampling_one_day_ago])
      end
    end

    context "with no activities for the claim" do
      let(:unrelated_only) { create(:claim_activity, :sampling_uploaded, user:, record: other_claim, created_at: 1.day.ago) }

      it "returns an empty collection" do
        unrelated_only
        expect(query_result).to eq([])
      end
    end
  end
end
