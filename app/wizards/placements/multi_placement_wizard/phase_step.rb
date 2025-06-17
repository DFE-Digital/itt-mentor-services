class Placements::MultiPlacementWizard::PhaseStep < BaseStep
  attribute :phases, default: []

  validates :phases, presence: true

  SEND = "SEND".freeze

  def phases_for_selection
    [
      OpenStruct.new(
        name: Placements::School::PRIMARY_PHASE,
        value: Placements::School::PRIMARY_PHASE,
        description: I18n.t("#{locale_path}.options.#{Placements::School::PRIMARY_PHASE.downcase}_description"),
      ),
      OpenStruct.new(
        name: Placements::School::SECONDARY_PHASE,
        value: Placements::School::SECONDARY_PHASE,
        description: I18n.t("#{locale_path}.options.#{Placements::School::SECONDARY_PHASE.downcase}_description"),
      ),
      OpenStruct.new(
        name: I18n.t("#{locale_path}.options.send"),
        value: SEND,
        description: I18n.t("#{locale_path}.options.send_description"),
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
