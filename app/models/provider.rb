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
#  latitude           :float
#  longitude          :float
#  name               :string           default(""), not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             default("scitt"), not null
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
#  index_providers_on_latitude            (latitude)
#  index_providers_on_longitude           (longitude)
#  index_providers_on_name_trigram        (name) USING gin
#  index_providers_on_placements_service  (placements_service)
#  index_providers_on_postcode_trigram    (postcode) USING gin
#  index_providers_on_provider_type       (provider_type)
#  index_providers_on_ukprn_trigram       (ukprn) USING gin
#  index_providers_on_urn_trigram         (urn) USING gin
#
class Provider < ApplicationRecord
  include PgSearch::Model
  extend Geocoder::Model::ActiveRecord

  ADDRESS_FIELDS = %w[address1 address2 address3 city county postcode].freeze

  # Provider latitudes/longitudes are populated by the PublishTeacherTraining import (see PublishTeacherTraining::Provider::Importer).
  # This is only here to make sure geocoder is initialised on the model. While the address could be
  # used _as a fallback_ for geocoding, you should never normally need to call #geocode on a provider.
  geocoded_by :address

  alias_attribute :organisation_type, :provider_type

  has_many :user_memberships, as: :organisation
  has_many :users, through: :user_memberships
  has_many :provider_email_addresses, dependent: :destroy

  enum :provider_type,
       { scitt: "scitt", lead_school: "lead_school", university: "university" },
       validate: true

  validates :code, :name, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  scope :accredited, -> { where accredited: true }
  scope :placements_service, -> { where placements_service: true }

  # This scope removes the additional NIoT provider records that exist in the publish API. The NIoT HQ is still included and should be the only NIoT result for the Claims service.
  scope :excluding_niot_providers, -> { where.not(code: %w[1YF 21J 1GV 2HE 24P 1MN 1TZ 5J5 7K9 L06 2P4 21P 1FE 3P4 3L4 2H7 2A6 4W2 4L1 4L3 4C2 5A6 2U6]) }

  scope :order_by_name, -> { order(name: :asc) }

  multisearchable against: %i[name postcode],
                  if: :placements_service?,
                  additional_attributes: ->(provider) { { organisation_type: provider.provider_type } }

  pg_search_scope :search_name_urn_ukprn_postcode,
                  against: %i[name postcode urn ukprn],
                  using: { trigram: { word_similarity: true } }

  accepts_nested_attributes_for :provider_email_addresses, allow_destroy: true

  def self.order_by_ids(ids)
    t = arel_table
    condition = Arel::Nodes::Case.new(t[:id])
    ids.each_with_index do |id, index|
      condition.when(id).then(index)
    end
    order(condition)
  end

  def primary_email_address
    provider_email_addresses.primary.last.email_address
  end

  def email_addresses
    provider_email_addresses.pluck(:email_address).uniq
  end

  def address
    [
      *attributes.slice(*ADDRESS_FIELDS).values,
      "United Kingdom",
    ].compact.join(", ")
  end
end
