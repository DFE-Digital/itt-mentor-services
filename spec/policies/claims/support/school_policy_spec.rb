require "rails_helper"

describe Claims::Support::SchoolPolicy do
  subject { described_class }

  let(:support_user) { build(:claims_support_user) }
  let(:non_support_user) { create(:claims_user) }

  permissions :search? do
    it { is_expected.to permit(support_user) }
    it { is_expected.not_to permit(non_support_user) }
  end
end
