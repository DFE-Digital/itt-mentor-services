# == Schema Information
#
# Table name: payment_claims
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  claim_id   :uuid             not null
#  payment_id :uuid             not null
#
# Indexes
#
#  index_payment_claims_on_claim_id    (claim_id)
#  index_payment_claims_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (payment_id => payments.id)
#
require "rails_helper"

RSpec.describe Claims::PaymentClaim, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:payment) }
    it { is_expected.to belong_to(:claim) }
  end
end
