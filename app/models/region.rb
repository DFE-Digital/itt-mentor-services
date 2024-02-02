# == Schema Information
#
# Table name: regions
#
#  id                                         :uuid             not null, primary key
#  claims_funding_available_per_hour_currency :string           default("GBP"), not null
#  claims_funding_available_per_hour_pence    :integer          default(0), not null
#  name                                       :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
# Indexes
#
#  index_regions_on_name  (name) UNIQUE
#
class Region < ApplicationRecord
  monetize :claims_funding_available_per_hour_pence
  has_many :schools

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :claims_funding_available_per_hour_currency, presence: true
  validates :claims_funding_available_per_hour_pence, presence: true
end
