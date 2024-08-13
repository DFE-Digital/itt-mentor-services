require "rails_helper"

RSpec.describe ProviderPolicy do
  subject(:provider_policy) { described_class }

  describe "scope" do
    let!(:placements_provider) { create(:placements_provider) }
    let(:scope) { Provider.all }

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all providers" do
        expect(provider_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a school user" do
      let(:user) { create(:placements_user, schools: [school]) }
      let(:school) { create(:placements_school) }

      before do
        user.current_organisation = school
        school.partner_providers << placements_provider
      end

      it "returns the school's partner providers" do
        expect(provider_policy::Scope.new(user, scope).resolve).to eq(school.partner_providers)
      end
    end
  end
end
