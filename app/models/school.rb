# == Schema Information
#
# Table name: schools
#
#  id                           :uuid             not null, primary key
#  address1                     :string
#  address2                     :string
#  address3                     :string
#  admissions_policy            :string
#  claims_service               :boolean          default(FALSE)
#  district_admin_code          :string
#  district_admin_name          :string
#  email_address                :string
#  gender                       :string
#  group                        :string
#  last_inspection_date         :date
#  local_authority_code         :string
#  local_authority_name         :string
#  maximum_age                  :integer
#  minimum_age                  :integer
#  name                         :string
#  percentage_free_school_meals :integer
#  phase                        :string
#  placements_service           :boolean          default(FALSE)
#  postcode                     :string
#  rating                       :string
#  religious_character          :string
#  school_capacity              :integer
#  send_provision               :string
#  special_classes              :string
#  telephone                    :string
#  total_boys                   :integer
#  total_girls                  :integer
#  total_pupils                 :integer
#  town                         :string
#  training_with_disabilities   :string
#  type_of_establishment        :string
#  ukprn                        :string
#  urban_or_rural               :string
#  urn                          :string           not null
#  website                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  region_id                    :uuid
#  trust_id                     :uuid
#
# Indexes
#
#  index_schools_on_claims_service      (claims_service)
#  index_schools_on_placements_service  (placements_service)
#  index_schools_on_region_id           (region_id)
#  index_schools_on_trust_id            (trust_id)
#  index_schools_on_urn                 (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (trust_id => trusts.id)
#
class School < ApplicationRecord
  include PgSearch::Model

  belongs_to :region
  belongs_to :trust, optional: true

  has_many :user_memberships, as: :organisation
  has_many :mentor_memberships
  has_many :mentors, through: :mentor_memberships

  validates :urn, presence: true
  validates :urn, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  scope :placements_service, -> { where placements_service: true }
  scope :claims_service, -> { where claims_service: true }

  multisearchable against: %i[name postcode],
                  if: :placements_service?,
                  additional_attributes: ->(_school) { { organisation_type: "school" } }

  pg_search_scope :search_name_urn_postcode,
                  against: %i[name postcode urn],
                  using: { trigram: { word_similarity: true } }

  pg_search_scope :search_name_postcode,
                  against: %i[name postcode],
                  using: { trigram: { word_similarity: true } }

  PRIMARY_PHASE = "Primary".freeze
  SECONDARY_PHASE = "Secondary".freeze

  def organisation_type
    "school"
  end

  def primary_or_secondary_only?
    [PRIMARY_PHASE, SECONDARY_PHASE].include?(phase)
  end
end
