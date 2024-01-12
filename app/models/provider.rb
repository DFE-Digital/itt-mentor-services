# == Schema Information
#
# Table name: providers
#
#  id            :uuid             not null, primary key
#  accredited    :boolean          default(FALSE)
#  address1      :string
#  address2      :string
#  address3      :string
#  city          :string
#  code          :string           not null
#  county        :string
#  email_address :string
#  name          :string           not null
#  placements    :boolean          default(FALSE)
#  postcode      :string
#  provider_type :enum             not null
#  telephone     :string
#  town          :string
#  ukprn         :string
#  urn           :string
#  website       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_providers_on_code        (code) UNIQUE
#  index_providers_on_placements  (placements)
#
class Provider < ApplicationRecord
  include PgSearch::Model

  has_many :memberships, as: :organisation

  enum :provider_type,
       { scitt: "scitt", lead_school: "lead_school", university: "university" },
       validate: true

  validates :code, :name, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  scope :accredited, -> { where accredited: true }
  scope :placements, -> { where placements: true }

  pg_search_scope :search_name_urn_ukprn_postcode,
                  against: %i[name postcode urn ukprn],
                  using: { trigram: { word_similarity: true } }
end
