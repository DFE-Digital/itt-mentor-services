require "rails_helper"

RSpec.describe ProviderPolicy do
  subject(:provider_policy) { described_class }

  describe "scope" do
    let(:placements_provider) { create(:placements_provider) }
    let(:scope) { Provider.all }

    before { placements_provider }

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all providers" do
        expect(provider_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a school user" do
      let(:school) { build(:placements_school) }
      let(:user) { create(:placements_user, schools: [school]) }
      let!(:provider_1) { create(:placements_provider, partner_schools: [school]) }
      let(:provider_2) { create(:placements_provider) }

      before do
        provider_2
      end

      it "returns the school's partner providers" do
        # Scope returns Providers, but partner schools association is only on Placements::Provider
        expect(provider_policy::Scope.new(user, scope).resolve).to eq([provider_1.becomes(Provider)])
      end
    end
  end
end
