# == Schema Information
#
# Table name: payments
#
#  id         :uuid             not null, primary key
#  claim_ids  :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sent_by_id :uuid             not null
#
# Indexes
#
#  index_payments_on_sent_by_id  (sent_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (sent_by_id => users.id)
#
class Claims::Payment < ApplicationRecord
  belongs_to :sent_by, class_name: "Claims::SupportUser"

  has_one_attached :csv_file

  def claims
    @claims ||= Claims::Claim.where(id: claim_ids)
  end

  def self.policy_class
    "PaymentPolicy"
  end
end
