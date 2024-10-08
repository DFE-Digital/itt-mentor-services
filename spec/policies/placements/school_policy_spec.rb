require "rails_helper"

RSpec.describe Placements::SchoolPolicy do
  subject(:school_policy) { described_class }

  describe "scope" do
    let(:scope) { Placements::School.all }

    before do
      create_list(:placements_school, 3)
    end

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all schools" do
        expect(school_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is assigned with a provider" do
      let(:school) { build(:placements_school) }
      let(:user) { create(:placements_user, schools: [school]) }

      it "returns the school's placements" do
        expect(school_policy::Scope.new(user, scope).resolve).to contain_exactly(school)
      end
    end
  end
end
