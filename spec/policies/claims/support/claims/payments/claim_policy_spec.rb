require "rails_helper"

describe Claims::Support::Claims::Payments::ClaimPolicy do
  subject { described_class }

  let(:support_user) { build(:claims_support_user) }
  let(:claim) { build(:claim) }

  permissions :show? do
    it { is_expected.to permit(support_user, claim) }
  end

  permissions :edit?, :update? do
    it { is_expected.not_to permit(support_user, claim) }
  end
end
