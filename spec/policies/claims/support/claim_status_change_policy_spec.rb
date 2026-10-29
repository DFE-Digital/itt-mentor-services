require "rails_helper"

RSpec.describe Claims::Support::ClaimStatusChangePolicy do
  subject(:policy) { described_class }

  permissions :download? do
    it "allows support users" do
      expect(policy).to permit(build(:claims_support_user), Claims::ClaimStatusChange.new)
    end

    it "denies school users" do
      expect(policy).not_to permit(build(:claims_user), Claims::ClaimStatusChange.new)
    end

    it "denies provider users" do
      expect(policy).not_to permit(build(:claims_provider_user), Claims::ClaimStatusChange.new)
    end
  end

  describe "Scope" do
    it "allows support users to query all transitions" do
      expect(described_class::Scope.new(build(:claims_support_user), Claims::ClaimStatusChange).resolve.to_sql)
        .to eq(Claims::ClaimStatusChange.all.to_sql)
    end

    it "restricts non-support users to an empty relation" do
      expect(described_class::Scope.new(build(:claims_user), Claims::ClaimStatusChange).resolve).to be_none
    end
  end
end
