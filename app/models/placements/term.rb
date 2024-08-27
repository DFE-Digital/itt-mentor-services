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
  VALID_NAMES = ["Summer term", "Spring term", "Autumn term"].freeze

  validates :name, presence: true, inclusion: { in: VALID_NAMES }

  has_many :placement_windows, class_name: "Placements::PlacementWindow"
  has_many :placements, through: :placement_windows
end
