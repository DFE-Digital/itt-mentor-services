class Placements::AddPlacementWizard::PhaseStep < Placements::BaseStep
  attribute :phase

  VALID_PHASES = [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].freeze

  validates :phase, presence: true, inclusion: { in: VALID_PHASES }

  def phases_for_selection
    { primary: "Primary", secondary: "Secondary" }
  end

  def wizard_attributes
    { phase: }
  end
end
