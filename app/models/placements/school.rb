# == Schema Information
#
# Table name: schools
#
#  id                                     :uuid             not null, primary key
#  address1                               :string
#  address2                               :string
#  address3                               :string
#  admissions_policy                      :string
#  claims_grant_conditions_accepted_at    :datetime
#  claims_private_beta                    :boolean          default(FALSE)
#  claims_service                         :boolean          default(FALSE)
#  district_admin_code                    :string
#  district_admin_name                    :string
#  email_address                          :string
#  gender                                 :string
#  group                                  :string
#  last_inspection_date                   :date
#  latitude                               :float
#  local_authority_code                   :string
#  local_authority_name                   :string
#  longitude                              :float
#  maximum_age                            :integer
#  minimum_age                            :integer
#  name                                   :string
#  percentage_free_school_meals           :integer
#  phase                                  :string
#  placements_service                     :boolean          default(FALSE)
#  postcode                               :string
#  rating                                 :string
#  religious_character                    :string
#  school_capacity                        :integer
#  send_provision                         :string
#  special_classes                        :string
#  telephone                              :string
#  total_boys                             :integer
#  total_girls                            :integer
#  total_pupils                           :integer
#  town                                   :string
#  type_of_establishment                  :string
#  ukprn                                  :string
#  urban_or_rural                         :string
#  urn                                    :string           not null
#  website                                :string
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  claims_grant_conditions_accepted_by_id :uuid
#  region_id                              :uuid
#  trust_id                               :uuid
#
# Indexes
#
#  index_schools_on_claims_grant_conditions_accepted_by_id  (claims_grant_conditions_accepted_by_id)
#  index_schools_on_claims_service                          (claims_service)
#  index_schools_on_latitude                                (latitude)
#  index_schools_on_longitude                               (longitude)
#  index_schools_on_name_trigram                            (name) USING gin
#  index_schools_on_placements_service                      (placements_service)
#  index_schools_on_postcode_trigram                        (postcode) USING gin
#  index_schools_on_region_id                               (region_id)
#  index_schools_on_trust_id                                (trust_id)
#  index_schools_on_urn                                     (urn) UNIQUE
#  index_schools_on_urn_trigram                             (urn) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (claims_grant_conditions_accepted_by_id => users.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (trust_id => trusts.id)
#
class Placements::School < School
  default_scope { placements_service }

  has_one :school_contact, dependent: :destroy

  has_many :users, through: :user_memberships
  has_many :mentor_memberships
  has_many :mentors, through: :mentor_memberships
  has_many :placements

  has_many :partnerships, dependent: :destroy
  has_many :partner_providers,
           through: :partnerships,
           source: :provider
end
