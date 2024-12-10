# == Schema Information
#
# Table name: provider_sampling_claims
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  claim_id             :uuid             not null
#  provider_sampling_id :uuid             not null
#
# Indexes
#
#  index_provider_sampling_claims_on_claim_id              (claim_id)
#  index_provider_sampling_claims_on_provider_sampling_id  (provider_sampling_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (provider_sampling_id => provider_samplings.id)
#
require "rails_helper"

RSpec.describe Claims::ProviderSamplingClaim, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:claim) }
    it { is_expected.to belong_to(:provider_sampling) }
  end
end
