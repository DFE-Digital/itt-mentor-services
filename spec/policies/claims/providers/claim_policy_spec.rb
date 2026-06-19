require "rails_helper"

RSpec.describe Claims::Providers::ClaimPolicy do
  subject(:claim_policy) { described_class }

  let(:support_user) { create(:claims_support_user) }
  let(:provider_user) { create(:claims_provider_user, providers: [assigned_provider]) }
  let(:school_user) { create(:claims_user) }
  let(:assigned_provider) { create(:claims_provider) }
  let(:other_provider) { create(:claims_provider) }

  let(:assigned_claim) { create(:claim, provider: assigned_provider) }
  let(:unassigned_claim) { create(:claim, provider: other_provider) }

  permissions :index? do
    it { is_expected.to permit(support_user, Claims::Claim) }
    it { is_expected.to permit(provider_user, Claims::Claim) }
    it { is_expected.not_to permit(school_user, Claims::Claim) }
  end

  permissions :show? do
    it { is_expected.to permit(support_user, unassigned_claim) }
    it { is_expected.to permit(provider_user, assigned_claim) }
    it { is_expected.not_to permit(provider_user, unassigned_claim) }
    it { is_expected.not_to permit(school_user, assigned_claim) }
  end

  permissions :create?, :destroy?, :update? do
    it { is_expected.to permit(support_user, assigned_claim) }
    it { is_expected.not_to permit(provider_user, assigned_claim) }
  end

  describe "scope" do
    let!(:claim_for_assigned_provider) { create(:claim, provider: assigned_provider) }
    let!(:claim_for_other_provider) { create(:claim, provider: other_provider) }

    context "when the user is a support user" do
      it "returns all claims" do
        scoped_claims = described_class::Scope.new(support_user, Claims::Claim.all).resolve

        expect(scoped_claims).to contain_exactly(claim_for_assigned_provider, claim_for_other_provider)
      end
    end

    context "when the user is a provider user" do
      it "returns claims for their providers" do
        scoped_claims = described_class::Scope.new(provider_user, Claims::Claim.all).resolve

        expect(scoped_claims).to contain_exactly(claim_for_assigned_provider)
      end
    end

    context "when the user is not a provider or support user" do
      it "returns no claims" do
        scoped_claims = described_class::Scope.new(school_user, Claims::Claim.all).resolve

        expect(scoped_claims).to be_empty
      end
    end
  end
end
