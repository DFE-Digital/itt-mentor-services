# == Schema Information
#
# Table name: clawback_claims
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  claim_id    :uuid             not null
#  clawback_id :uuid             not null
#
# Indexes
#
#  index_clawback_claims_on_claim_id     (claim_id)
#  index_clawback_claims_on_clawback_id  (clawback_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (clawback_id => clawbacks.id)
#
class Claims::ClawbackClaim < ApplicationRecord
  belongs_to :claim
  belongs_to :clawback
end
