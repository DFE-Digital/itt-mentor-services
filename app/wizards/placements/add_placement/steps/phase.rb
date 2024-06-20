class Placements::AddPlacement::Steps::Phase
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :phase

  VALID_PHASES = [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].freeze

  validates :school, presence: true
  validates :phase, presence: true, inclusion: { in: VALID_PHASES }

  def phases_for_selection
    { primary: "Primary", secondary: "Secondary" }
  end

  def wizard_attributes
    { phase: }
  end
end
