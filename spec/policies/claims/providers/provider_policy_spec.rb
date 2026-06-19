require "rails_helper"

RSpec.describe Claims::Providers::ProviderPolicy do
  subject(:provider_policy) { described_class }

  let(:support_user) { create(:claims_support_user) }
  let(:assigned_provider) { create(:claims_provider) }
  let(:other_provider) { create(:claims_provider) }
  let(:provider_user) { create(:claims_provider_user, providers: [assigned_provider]) }
  let(:school_user) { create(:claims_user) }

  permissions :index? do
    it { is_expected.to permit(support_user, Claims::Provider) }
    it { is_expected.to permit(provider_user, Claims::Provider) }
    it { is_expected.not_to permit(school_user, Claims::Provider) }
  end

  permissions :show? do
    it { is_expected.to permit(support_user, other_provider) }
    it { is_expected.to permit(provider_user, assigned_provider) }
    it { is_expected.not_to permit(provider_user, other_provider) }
    it { is_expected.not_to permit(school_user, assigned_provider) }
  end

  permissions :create?, :destroy?, :update? do
    it { is_expected.to permit(support_user, assigned_provider) }
    it { is_expected.not_to permit(provider_user, assigned_provider) }
  end

  describe "scope" do
    let!(:provider_in_scope) { create(:claims_provider) }
    let!(:provider_out_of_scope) { create(:claims_provider) }
    let(:provider_user) { create(:claims_provider_user, providers: [provider_in_scope]) }

    context "when the user is a support user" do
      it "returns all providers" do
        scoped_providers = described_class::Scope.new(support_user, Claims::Provider.all).resolve

        expect(scoped_providers).to include(provider_in_scope, provider_out_of_scope)
      end
    end

    context "when the user is a provider user" do
      it "returns providers they belong to" do
        scoped_providers = described_class::Scope.new(provider_user, Claims::Provider.all).resolve

        expect(scoped_providers).to contain_exactly(provider_in_scope)
      end
    end

    context "when the user is not a provider or support user" do
      it "returns no providers" do
        scoped_providers = described_class::Scope.new(school_user, Claims::Provider.all).resolve

        expect(scoped_providers).to be_empty
      end
    end
  end
end
