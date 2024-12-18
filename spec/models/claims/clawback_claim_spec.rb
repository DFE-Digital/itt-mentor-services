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
require "rails_helper"

RSpec.describe Claims::ClawbackClaim, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:claim) }
    it { is_expected.to belong_to(:clawback) }
  end
end
