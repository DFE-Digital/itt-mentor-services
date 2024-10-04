require "rails_helper"

RSpec.describe Placements::Provider::PlacementPolicy do
  subject(:placement_policy) { described_class }

  describe "scope" do
    let(:scope) { Placement.all }

    before do
      create_list(:placement, 3)
    end

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all placements" do
        expect(placement_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a provider user" do
      let(:provider) { build(:placements_provider) }
      let(:user) { create(:placements_user, providers: [provider]) }

      it "returns the school's placements" do
        expect(placement_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end
  end
end
