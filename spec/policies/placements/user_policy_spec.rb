require "rails_helper"

RSpec.describe Placements::UserPolicy do
  subject(:user_policy) { described_class }

  describe "scope" do
    let(:scope) { Placements::User.all }

    before do
      create_list(:placements_user, 3)
    end

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all users" do
        expect(user_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a school user" do
      let(:school) { build(:placements_school) }
      let!(:user_1) { create(:placements_user, schools: [school]) }
      let(:user_2) { create(:placements_user) }

      before do
        user_2
      end

      it "returns the school's users" do
        expect(user_policy::Scope.new(user_1, scope).resolve).to eq([user_1])
      end
    end

    context "when the user is none of the above" do
      let(:user) { create(:placements_user) }

      it "returns the user's organisations" do
        expect(user_policy::Scope.new(user, scope).resolve).to be_empty
      end
    end
  end
end
