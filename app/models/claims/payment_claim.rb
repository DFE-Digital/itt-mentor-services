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
class Claims::PaymentClaim < ApplicationRecord
  belongs_to :payment
  belongs_to :claim
end
