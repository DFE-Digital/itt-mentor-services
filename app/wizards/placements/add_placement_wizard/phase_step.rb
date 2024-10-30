class Placements::AddPlacementWizard::PhaseStep < BaseStep
  attribute :phase

  VALID_PHASES = [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].freeze

  validates :phase, presence: true, inclusion: { in: VALID_PHASES }

  def phases_for_selection
    [
      OpenStruct.new(name: Placements::School::PRIMARY_PHASE),
      OpenStruct.new(name: Placements::School::SECONDARY_PHASE),
    ]
  end
end
