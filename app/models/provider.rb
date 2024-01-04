# == Schema Information
#
# Table name: providers
#
#  id               :uuid             not null, primary key
#  city             :string
#  county           :string
#  email            :string
#  name             :string           not null
#  placements       :boolean          default(FALSE)
#  postcode         :string
#  provider_code    :string           not null
#  provider_type    :enum             not null
#  street_address_1 :string
#  street_address_2 :string
#  street_address_3 :string
#  telephone        :string
#  town             :string
#  ukprn            :string
#  urn              :string
#  website          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_providers_on_placements     (placements)
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
class Provider < ApplicationRecord
  has_many :memberships, as: :organisation

  enum :provider_type,
       { scitt: "scitt", lead_school: "lead_school", university: "university" },
       validate: true

  validates :provider_code, :name, presence: true
  validates :provider_code, uniqueness: { case_sensitive: false }
end
