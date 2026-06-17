require "rails_helper"

describe Claims::Support::ProviderUserPolicy do
  subject(:provider_user_policy) { described_class }

  let(:support_user_1) { create(:claims_support_user) }
  let(:support_user_2) { create(:claims_support_user) }
  let(:non_support_user) { create(:claims_user) }

  %i[update? download?].each do |permission|
    permissions permission do
      it { is_expected.to permit(support_user_1, support_user_2) }
      it { is_expected.to permit(non_support_user, support_user_2) }
    end
  end

  permissions :destroy? do
    it "denies access when current user is the provider user" do
      expect(provider_user_policy).not_to permit(support_user_1, support_user_1)
    end

    it "grants access when current user is not the provider user" do
      expect(provider_user_policy).to permit(support_user_1, support_user_2)
    end
  end
end
