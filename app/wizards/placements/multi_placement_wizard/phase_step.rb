class Placements::MultiPlacementWizard::PhaseStep < BaseStep
  attribute :phases, default: []

  VALID_PHASES = [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].freeze

  validates :phases, presence: true

  def phases_for_selection
    [
      OpenStruct.new(
        name: Placements::School::PRIMARY_PHASE,
        hint: I18n.t(
          "#{locale_path}.options.primary.hint",
        ),
      ),
      OpenStruct.new(
        name: Placements::School::SECONDARY_PHASE,
        hint: I18n.t(
          "#{locale_path}.options.secondary.hint",
        ),
      ),
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

  def locale_path
    ".wizards.placements.multi_placement_wizard.phase_step"
  end
end
