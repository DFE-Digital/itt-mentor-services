require "rails_helper"

RSpec.describe Claims::Providers::ApplicationPolicy do
  subject(:policy) { described_class }

  let(:support_user) { create(:claims_support_user) }
  let(:provider_user) { create(:claims_provider_user) }
  let(:school_user) { create(:claims_user) }

  permissions :read? do
    it { is_expected.to permit(support_user, Claims::Provider) }
    it { is_expected.to permit(provider_user, Claims::Provider) }
    it { is_expected.not_to permit(school_user, Claims::Provider) }
  end
end
