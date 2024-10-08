require "rails_helper"

RSpec.describe Placements::ProviderPolicy do
  subject(:provider_policy) { described_class }

  describe "scope" do
    let(:scope) { Placements::Provider.all }

    before do
      create_list(:placements_provider, 3)
    end

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all providers" do
        expect(provider_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is assigned with a provider" do
      let(:provider) { build(:placements_provider) }
      let(:user) { create(:placements_user, providers: [provider]) }

      it "returns the school's placements" do
        expect(provider_policy::Scope.new(user, scope).resolve).to contain_exactly(provider)
      end
    end
  end
end
