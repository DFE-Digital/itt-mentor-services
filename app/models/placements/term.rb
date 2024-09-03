# == Schema Information
#
# Table name: terms
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Placements::Term < ApplicationRecord
  SUMMER_TERM = "Summer term".freeze
  SPRING_TERM = "Spring term".freeze
  AUTUMN_TERM = "Autumn term".freeze
  VALID_NAMES = [SUMMER_TERM, SPRING_TERM, AUTUMN_TERM].freeze

  scope :order_by_term, lambda {
    order(Arel.sql("
      CASE
        WHEN name = '#{AUTUMN_TERM}' THEN '1'
        WHEN name = '#{SPRING_TERM}' THEN '2'
        WHEN name = '#{SUMMER_TERM}' THEN '3'
      END
    "))
  }

  validates :name, presence: true, inclusion: { in: VALID_NAMES }

  has_many :placement_windows, class_name: "Placements::PlacementWindow"
  has_many :placements, through: :placement_windows
end
