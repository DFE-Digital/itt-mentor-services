require "rails_helper"

RSpec.describe Claims::ClaimActivityDecorator do
  describe "#title" do
    let(:decorated_claim_activity) { claim_activity.decorate }

    context "when the claim activity action is payment_request_delivered" do
      let(:claim_activity) { create(:claim_activity, :payment_request_delivered, record:) }

      context "when the claim activity has one claim" do
        let(:record) { build(:claims_payment, claims: [build(:claim, :submitted)]) }

        it "returns the translation for payment_request_delivered" do
          expect(decorated_claim_activity.title).to eq("1 claim sent to payer for payment")
        end
      end

      context "when the claim activity has more than one claim" do
        let(:record) { build(:claims_payment, claims: build_list(:claim, 3, :submitted)) }

        it "returns the translation for payment_request_delivered" do
          expect(decorated_claim_activity.title).to eq("3 claims sent to payer for payment")
        end
      end

      context "when the claim activity has no claims" do
        let(:record) { build(:claims_payment, claims: []) }

        it "returns the translation for payment_request_delivered" do
          expect(decorated_claim_activity.title).to eq("0 claims sent to payer for payment")
        end
      end
    end

    context "when the claim activity action is payment_response_uploaded" do
      let(:claim_activity) { create(:claim_activity, :payment_response_uploaded, record: create(:claims_payment)) }

      it "returns the translation for payment_response_uploaded" do
        expect(decorated_claim_activity.title).to eq("Payer payment response uploaded")
      end
    end

    context "when the claim activity action is sampling_uploaded" do
      let(:claim_activity) { create(:claim_activity, :sampling_uploaded, record:) }

      context "when the claim activity has one claim" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: [build(:claims_provider_sampling_claim)]) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_uploaded" do
          expect(decorated_claim_activity.title).to eq("Audit data uploaded for 1 claim")
        end
      end

      context "when the claim activity has more than one claim" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: build_list(:claims_provider_sampling_claim, 3)) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_uploaded" do
          expect(decorated_claim_activity.title).to eq("Audit data uploaded for 3 claims")
        end
      end

      context "when the claim activity has no claims" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: []) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_uploaded" do
          expect(decorated_claim_activity.title).to eq("Audit data uploaded for 0 claims")
        end
      end
    end

    context "when the claim activity action is sampling_response_uploaded" do
      let(:claim_activity) { create(:claim_activity, :sampling_response_uploaded, record:) }

      context "when the claim activity has one claim" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: [build(:claims_provider_sampling_claim)]) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Provider audit response uploaded for 1 claim")
        end
      end

      context "when the claim activity has more than one claim" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: build_list(:claims_provider_sampling_claim, 3)) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Provider audit response uploaded for 3 claims")
        end
      end

      context "when the claim activity has no claims" do
        let(:provider_sampling) { build(:provider_sampling, provider_sampling_claims: []) }
        let(:record) { build(:claims_sampling, provider_samplings: [provider_sampling]) }

        it "returns the translation for sampling_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Provider audit response uploaded for 0 claims")
        end
      end
    end

    context "when the claim activity action is clawback_request_delivered" do
      let(:claim_activity) { create(:claim_activity, :clawback_request_delivered, record:) }

      context "when the claim activity has one claim" do
        let(:record) { build(:claims_clawback, claims: [build(:claim, :submitted)]) }

        it "returns the translation for clawback_request_delivered" do
          expect(decorated_claim_activity.title).to eq("1 claim sent to payer for clawback")
        end
      end

      context "when the claim activity has more than one claim" do
        let(:record) { build(:claims_clawback, claims: build_list(:claim, 3, :submitted)) }

        it "returns the translation for clawback_request_delivered" do
          expect(decorated_claim_activity.title).to eq("3 claims sent to payer for clawback")
        end
      end

      context "when the claim activity has no claims" do
        let(:record) { build(:claims_clawback, claims: []) }

        it "returns the translation for clawback_request_delivered" do
          expect(decorated_claim_activity.title).to eq("0 claims sent to payer for clawback")
        end
      end
    end

    context "when the claim activity action is clawback_response_uploaded" do
      let(:claim_activity) { create(:claim_activity, :clawback_response_uploaded, record:) }

      context "when the claim activity has one claim" do
        let(:record) { build(:claims_clawback, claims: [build(:claim, :submitted)]) }

        it "returns the translation for clawback_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Payer clawback response uploaded for 1 claim")
        end
      end

      context "when the claim activity has more than one claim" do
        let(:record) { build(:claims_clawback, claims: build_list(:claim, 3, :submitted)) }

        it "returns the translation for clawback_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Payer clawback response uploaded for 3 claims")
        end
      end

      context "when the claim activity has no claims" do
        let(:record) { build(:claims_clawback, claims: []) }

        it "returns the translation for clawback_response_uploaded" do
          expect(decorated_claim_activity.title).to eq("Payer clawback response uploaded for 0 claims")
        end
      end
    end

    context "when the claim activity action is provider_approved_audit" do
      let(:record) { create(:claim, reference: "12345678") }
      let(:claim_activity) { create(:claim_activity, :provider_approved_audit, record:) }

      it "returns the translation for provider_approved_audit" do
        expect(decorated_claim_activity.title).to eq("Provider #{record.provider_name} approved audit for claim 12345678")
      end
    end

    context "when the claim activity action is rejected_by_provider" do
      let(:record) { create(:claim, reference: "12345678") }
      let(:claim_activity) { create(:claim_activity, :rejected_by_provider, record:) }

      it "returns the translation for rejected_by_provider" do
        expect(decorated_claim_activity.title).to eq("Provider #{record.provider_name} rejected audit for claim 12345678")
      end
    end

    context "when the claim activity action is rejected_by_school" do
      let(:record) { create(:claim, reference: "12345678") }
      let(:claim_activity) { create(:claim_activity, :rejected_by_school, record:) }

      it "returns the translation for rejected_by_school" do
        expect(decorated_claim_activity.title).to eq("School #{record.school_name} rejected audit for claim 12345678")
      end
    end

    context "when the claim activity action is approved_by_school" do
      let(:record) { create(:claim, reference: "12345678") }
      let(:claim_activity) { create(:claim_activity, :approved_by_school, record:) }

      it "returns the translation for approved_by_school" do
        expect(decorated_claim_activity.title).to eq("School #{record.school_name} approved audit for claim 12345678")
      end
    end

    context "when the claim activity action is clawback_requested" do
      let(:claim_activity) { create(:claim_activity, :clawback_requested, record: build(:claim, reference: "12345678")) }

      it "returns the translation for clawback_requested" do
        expect(decorated_claim_activity.title).to eq("Clawback requested for claim 12345678")
      end
    end

    context "when the claim activity action is rejected_by_payer" do
      let(:claim_activity) { create(:claim_activity, :rejected_by_payer, record: build(:claim, reference: "12345678")) }

      it "returns the translation for rejected_by_payer" do
        expect(decorated_claim_activity.title).to eq("Payer rejected payment for claim 12345678")
      end
    end

    context "when the claim activity action is paid_by_payer" do
      let(:claim_activity) { create(:claim_activity, :paid_by_payer, record: build(:claim, reference: "12345678")) }

      it "returns the translation for paid_by_payer" do
        expect(decorated_claim_activity.title).to eq("Payer paid claim 12345678")
      end
    end

    context "when the claim activity action is information_sent_to_payer" do
      let(:claim_activity) { create(:claim_activity, :information_sent_to_payer, record: build(:claim, reference: "12345678")) }

      it "returns the translation for information_sent_to_payer" do
        expect(decorated_claim_activity.title).to eq("Information sent to payer for claim 12345678")
      end
    end

    context "when the action is not recognised" do
      let(:claim_activity) { build(:claim_activity, action: "not_a_real_action") }

      it "raises an error" do
        expect { decorated_claim_activity.title }.to raise_error("Unknown action: not_a_real_action")
      end
    end
  end
end
