# == Schema Information
#
# Table name: key_stages
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Placements::KeyStage < ApplicationRecord
  EARLY_YEARS = "Early years".freeze
  KEY_STAGE_1 = "Key stage 1".freeze
  KEY_STAGE_2 = "Key stage 2".freeze
  KEY_STAGE_3 = "Key stage 3".freeze
  KEY_STAGE_4 = "Key stage 4".freeze
  KEY_STAGE_5 = "Key stage 5".freeze

  VALID_NAMES = [
    EARLY_YEARS,
    KEY_STAGE_1,
    KEY_STAGE_2,
    KEY_STAGE_3,
    KEY_STAGE_4,
    KEY_STAGE_5,
  ].freeze

  has_many :placement_key_stages, class_name: "Placements::PlacementKeyStage"
  has_many :placements, through: :placement_key_stages

  validates :name, presence: true, inclusion: { in: VALID_NAMES }

  scope :order_by_name, -> { order(name: :asc) }
end
