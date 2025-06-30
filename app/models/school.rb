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
#  claims_service                         :boolean          default(FALSE)
#  district_admin_code                    :string
#  district_admin_name                    :string
#  email_address                          :string
#  expression_of_interest_completed       :boolean          default(FALSE)
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
#  previously_offered_placements          :boolean          default(FALSE)
#  potential_placement_details            :jsonb
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
#  urn                                    :string
#  vendor_number                          :string
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
class School < ApplicationRecord
  include PgSearch::Model
  extend Geocoder::Model::ActiveRecord

  ADDRESS_FIELDS = %w[address1 address2 address3 town postcode].freeze

  # School latitudes/longitudes are populated by the GIAS import (see Gias::SyncAllSchoolsJob).
  # This is only here to make sure geocoder is initialised on the model. While the address could be
  # used _as a fallback_ for geocoding, you should never normally need to call #geocode on a school.
  geocoded_by :address

  belongs_to :region
  belongs_to :trust, optional: true
  belongs_to :manually_onboarded_by, polymorphic: true, optional: true

  has_many :user_memberships, as: :organisation
  has_many :users, through: :user_memberships

  has_many :mentor_memberships
  has_many :mentors, through: :mentor_memberships

  has_many :school_sen_provisions
  has_many :sen_provisions, through: :school_sen_provisions

  has_many :hosting_interests, class_name: "Placements::HostingInterest"
  has_many :placements
  has_many :academic_years, through: :placements

  has_many :partnerships, class_name: "Placements::Partnership", dependent: :destroy

  has_one :school_contact, dependent: :destroy, class_name: "Placements::SchoolContact"

  normalizes :email_address, with: ->(value) { value.strip.downcase }

  validates_with UniqueIdentifierValidator

  validates :urn, uniqueness: { case_sensitive: false }, if: -> { urn.present? }
  validates :vendor_number, uniqueness: { case_sensitive: false }, if: -> { vendor_number.present? }

  validates :name, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  scope :placements_service, -> { where placements_service: true }
  scope :claims_service, -> { where claims_service: true }
  scope :order_by_name, -> { order(name: :asc) }

  multisearchable against: %i[name postcode],
                  if: :placements_service?,
                  additional_attributes: ->(_school) { { organisation_type: "school" } }

  pg_search_scope :search_name_urn_postcode,
                  against: %i[name postcode urn],
                  using: { trigram: { word_similarity: true } }

  pg_search_scope :search_name_postcode,
                  against: %i[name postcode],
                  using: { trigram: { word_similarity: true } }

  delegate :email_address, :full_name, to: :school_contact, prefix: true, allow_nil: true

  PRIMARY_PHASE = "Primary".freeze
  SECONDARY_PHASE = "Secondary".freeze

  def organisation_type
    "school"
  end

  def primary_or_secondary_only?
    [PRIMARY_PHASE, SECONDARY_PHASE].include?(phase)
  end

  def address
    [
      *attributes.slice(*ADDRESS_FIELDS).values,
      "United Kingdom",
    ].compact.join(", ")
  end

  def primary?
    phase == PRIMARY_PHASE
  end

  def email_addresses
    return [] if email_address.nil?

    [email_address]
  end

  def current_hosting_interest(academic_year:)
    hosting_interests.find_by(academic_year:)
  end

  def new_hosting_interest_required?(academic_year:)
    current_hosting_interest(academic_year:).blank? || !expression_of_interest_completed?
  end

  def available_placements(academic_year:)
    placements.available_placements_for_academic_year(academic_year)
  end

  def unavailable_placements(academic_year:)
    placements.unavailable_placements_for_academic_year(academic_year)
  end

  def send_placements(academic_year:)
    placements.send_placements_for_academic_year(academic_year)
  end

  def potential_send_placements?
    return false if potential_placement_details.blank?

    potential_placement_details.dig("phase", "phases").include?("SEND")
  end

  def last_placement_for_school?(placement:)
    placements.where.not(id: placement.id).where(academic_year: placement.academic_year).none?
  end
end
