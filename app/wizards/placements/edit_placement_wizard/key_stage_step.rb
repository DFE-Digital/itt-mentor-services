class Placements::EditPlacementWizard::KeyStageStep < BaseStep
  attribute :key_stages, default: []

  validates :key_stages, presence: true

  def key_stages_for_selection
    Placements::KeyStage.order_by_name
  end

  def unknown_option
    @unknown_option ||=
      OpenStruct.new(
        value: Placements::AddHostingInterestWizard::UNKNOWN_OPTION,
        name: I18n.t(
          "#{unknown_option_locale_path}.unknown",
        ),
        description: I18n.t(
          "#{unknown_option_locale_path}.unknown_description",
        ),
      )
  end

  def key_stages=(value)
    super normalised_key_stages(value)
  end

  private

  def normalised_key_stages(selected_key_stages)
    return [] if selected_key_stages.blank?

    selected_key_stages.reject(&:blank?)
  end

  def unknown_option_locale_path
    ".wizards.placements.multi_placement_wizard.key_stage_step.options"
  end
end
