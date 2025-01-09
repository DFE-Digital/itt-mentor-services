# == Schema Information
#
# Table name: payments
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sent_by_id    :uuid             not null
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

  has_many :payment_claims, dependent: :destroy
  has_many :claims, through: :payment_claims, class_name: "Claims::Claim"

  has_one_attached :csv_file

  def downloaded?
    downloaded_at.present?
  end
end
