require "rails_helper"

describe GrantConditions::Claims::SchoolPolicy do
  subject(:school_policy) { described_class }

  let!(:school) { build(:claims_school) }

  let!(:user) do
    create(:claims_user) { |user| school.users << user }
  end
  let(:not_permitted_user) { build(:claims_user) }

  permissions :show? do
    context "when user is a member of the school" do
      it "grants access" do
        expect(school_policy).to permit(user, school)
      end
    end

    context "when the user is NOT a member of the school" do
      it "does NOT grant access" do
        expect(school_policy).not_to permit(not_permitted_user, school)
      end
    end
  end

  permissions :update? do
    context "when user is a member of the school" do
      it "grants access" do
        expect(school_policy).to permit(user, school)
      end
    end

    context "when the user is NOT a member of the school" do
      it "does NOT grant access" do
        expect(school_policy).not_to permit(not_permitted_user, school)
      end
    end
  end
end
