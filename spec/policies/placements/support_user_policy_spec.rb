require "rails_helper"

describe Placements::SupportUserPolicy do
  subject(:support_user_policy) { described_class }

  let(:support_user_1) { create(:placements_support_user) }
  let(:support_user_2) { create(:placements_support_user) }

  permissions :destroy? do
    it "denies access current_user is the support_user" do
      expect(support_user_policy).not_to permit(support_user_1, support_user_1)
    end

    it "grants access current_user is not the support_user" do
      expect(support_user_policy).to permit(support_user_1, support_user_2)
    end
  end

  describe "scope" do
    let(:support_user) { create(:placements_support_user) }
    let(:scope) { Placements::SupportUser.all }

    before { support_user }

    context "when the user is a support user" do
      it "returns all support users" do
        expect(support_user_policy::Scope.new(support_user_1, scope).resolve).to eq(scope)
      end
    end

    context "when the user is not a support user" do
      let(:user) { create(:placements_user) }

      it "returns no support users" do
        expect(support_user_policy::Scope.new(user, scope).resolve).to eq(scope.none)
      end
    end
  end
end
