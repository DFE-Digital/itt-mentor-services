require "rails_helper"

describe Claims::Support::Claims::ClaimActivityPolicy do
  subject { described_class }

  let(:support_user) { build(:claims_support_user) }

  permissions :resend_payer_email?, :resend_provider_email? do
    it { is_expected.to permit(support_user, Claims::ClaimActivity) }
  end
end
