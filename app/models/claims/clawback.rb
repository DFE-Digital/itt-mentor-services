# == Schema Information
#
# Table name: clawbacks
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Claims::Clawback < ApplicationRecord
  has_many :clawback_claims
  has_many :claims, through: :clawback_claims

  has_one_attached :csv_file
  has_many :status_changes, as: :source, class_name: "Claims::ClaimStatusChange", dependent: :restrict_with_exception

  def downloaded?
    downloaded_at.present?
  end
end
