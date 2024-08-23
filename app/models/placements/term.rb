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
  VALID_NAMES = ["Summer term", "Spring term", "Autumn term", "Any time in the academic year"].freeze
  private_constant :VALID_NAMES

  validates :name, presence: true, inclusion: { in: VALID_NAMES }
end
