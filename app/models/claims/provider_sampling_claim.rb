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
class Claims::ProviderSamplingClaim < ApplicationRecord
  belongs_to :provider_sampling
  belongs_to :claim
end
