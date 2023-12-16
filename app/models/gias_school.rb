# == Schema Information
#
# Table name: gias_schools
#
#  id         :uuid             not null, primary key
#  address1   :string
#  address2   :string
#  address3   :string
#  name       :string           not null
#  postcode   :string
#  telephone  :string
#  town       :string
#  ukprn      :string
#  urn        :string           not null
#  website    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_gias_schools_on_urn  (urn) UNIQUE
#
class GiasSchool < ApplicationRecord
  has_one :school, foreign_key: :urn, primary_key: :urn

  validates :urn, presence: true
  validates :urn, uniqueness: { case_sensitive: false }
  validates :name, presence: true
end
