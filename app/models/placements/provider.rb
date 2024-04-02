# == Schema Information
#
# Table name: providers
#
#  id                 :uuid             not null, primary key
#  accredited         :boolean          default(FALSE)
#  address1           :string
#  address2           :string
#  address3           :string
#  city               :string
#  code               :string           not null
#  county             :string
#  email_address      :string
#  name               :string           not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             not null
#  telephone          :string
#  town               :string
#  ukprn              :string
#  urn                :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_providers_on_code                (code) UNIQUE
#  index_providers_on_placements_service  (placements_service)
#
class Placements::Provider < Provider
  default_scope { placements_service }

  has_many :users, through: :user_memberships
  has_many :partnerships, dependent: :destroy
  has_many :partner_schools,
           through: :partnerships,
           source: :school
end
