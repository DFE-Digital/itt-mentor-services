# == Schema Information
#
# Table name: schools
#
#  id         :uuid             not null, primary key
#  claims     :boolean          default(FALSE)
#  placements :boolean          default(FALSE)
#  urn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_schools_on_claims      (claims)
#  index_schools_on_placements  (placements)
#  index_schools_on_urn         (urn) UNIQUE
#
class School < ApplicationRecord
  belongs_to :gias_school, foreign_key: :urn, primary_key: :urn
  has_many :memberships, as: :organisation
  has_many :users, through: :memberships

  validates :urn, presence: true
  validates :urn, uniqueness: { case_sensitive: false }

  delegate :name,
           :postcode,
           :town,
           :telephone,
           :website,
           :address1,
           :address2,
           :address3,
           to: :gias_school, allow_nil: true

  scope :placements, -> { where placements: true }
  scope :claims, -> { where claims: true }
end
