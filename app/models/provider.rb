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
#  index_providers_on_name_trigram        (name) USING gin
#  index_providers_on_placements_service  (placements_service)
#  index_providers_on_postcode_trigram    (postcode) USING gin
#  index_providers_on_provider_type       (provider_type)
#  index_providers_on_ukprn_trigram       (ukprn) USING gin
#  index_providers_on_urn_trigram         (urn) USING gin
#
class Provider < ApplicationRecord
  include PgSearch::Model

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
  scope :order_by_name, -> { order(name: :asc) }

  multisearchable against: %i[name postcode],
                  if: :placements_service?,
                  additional_attributes: ->(provider) { { organisation_type: provider.provider_type } }

  pg_search_scope :search_name_urn_ukprn_postcode,
                  against: %i[name postcode urn ukprn],
                  using: { trigram: { word_similarity: true } }

  accepts_nested_attributes_for :provider_email_addresses, allow_destroy: true

  def primary_email_address
    provider_email_addresses.primary.last.email_address
  end

  def email_addresses
    provider_email_addresses.pluck(:email_address).uniq
  end
end
