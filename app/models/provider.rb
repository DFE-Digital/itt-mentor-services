# == Schema Information
#
# Table name: providers
#
#  id            :uuid             not null, primary key
#  placements    :boolean          default(FALSE)
#  provider_code :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_providers_on_placements     (placements)
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
class Provider < ApplicationRecord
  has_many :memberships, as: :organisation

  validates :provider_code, presence: true
  validates :provider_code, uniqueness: { case_sensitive: false }
end
