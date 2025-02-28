class Placements::MultiPlacementWizard::PhaseStep < BaseStep
  attribute :phases, default: []

  VALID_PHASES = [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].freeze

  validates :phases, presence: true

  def phases_for_selection
    [
      OpenStruct.new(name: Placements::School::PRIMARY_PHASE),
      OpenStruct.new(name: Placements::School::SECONDARY_PHASE),
    ]
  end

  def phases=(value)
    super normalised_phases(value)
  end

  private

  def normalised_phases(selected_phases)
    return [] if selected_phases.blank?

    selected_phases.reject(&:blank?)
  end
end
