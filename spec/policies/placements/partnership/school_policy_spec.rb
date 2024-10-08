require "rails_helper"

RSpec.describe Placements::Partnership::SchoolPolicy do
  subject(:school_policy) { described_class }

  describe "scope" do
    let(:scope) { School.all }

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all schools" do
        expect(school_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a school user" do
      let(:user) { create(:placements_user, schools: [school]) }
      let(:school) { create(:placements_school) }

      it "returns the school's partner providers" do
        expect(school_policy::Scope.new(user, scope).resolve).to eq(school.partner_providers)
      end
    end

    context "when the user is a provider user" do
      let(:user) { create(:placements_user, providers: [provider]) }
      let(:provider) { create(:placements_provider) }

      it "returns the provider's partner schools" do
        expect(school_policy::Scope.new(user, scope).resolve).to eq(provider.partner_schools)
      end
    end
  end
end
