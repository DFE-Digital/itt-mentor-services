require "rails_helper"

RSpec.describe Claims::Providers::UserPolicy do
  subject(:user_policy) { described_class }

  let(:support_user) { create(:claims_support_user) }
  let(:assigned_provider) { create(:claims_provider) }
  let(:other_provider) { create(:claims_provider) }
  let(:provider_user) { create(:claims_provider_user, providers: [assigned_provider]) }
  let(:school_user) { create(:claims_user) }

  let(:user_in_assigned_provider) { create(:claims_provider_user, providers: [assigned_provider]) }
  let(:user_in_other_provider) { create(:claims_provider_user, providers: [other_provider]) }

  permissions :index? do
    it { is_expected.to permit(support_user, User) }
    it { is_expected.to permit(provider_user, User) }
    it { is_expected.not_to permit(school_user, User) }
  end

  permissions :show? do
    it { is_expected.to permit(support_user, user_in_other_provider) }
    it { is_expected.to permit(provider_user, user_in_assigned_provider) }
    it { is_expected.not_to permit(provider_user, user_in_other_provider) }
    it { is_expected.not_to permit(school_user, user_in_assigned_provider) }
  end

  permissions :create?, :destroy?, :update? do
    it { is_expected.to permit(support_user, user_in_assigned_provider) }
    it { is_expected.not_to permit(provider_user, user_in_assigned_provider) }
  end

  describe "scope" do
    let!(:provider_user_in_scope) { create(:claims_provider_user, providers: [assigned_provider]) }
    let!(:provider_user_out_of_scope) { create(:claims_provider_user, providers: [other_provider]) }

    context "when the user is a support user" do
      it "returns all users" do
        scoped_users = described_class::Scope.new(support_user, User.all).resolve

        expect(scoped_users).to include(provider_user_in_scope, provider_user_out_of_scope)
      end
    end

    context "when the user is a provider user" do
      it "returns users assigned to the same provider" do
        scoped_users = described_class::Scope.new(provider_user, User.all).resolve

        expect(scoped_users).to contain_exactly(provider_user, provider_user_in_scope)
      end
    end

    context "when the user is not a provider or support user" do
      it "returns no users" do
        scoped_users = described_class::Scope.new(school_user, User.all).resolve

        expect(scoped_users).to be_empty
      end
    end
  end
end
