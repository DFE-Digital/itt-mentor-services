class Placements::MultiPlacementWizard::KeyStageSelectionStep < BaseStep
  attribute :key_stage_ids, default: []

  validates :key_stage_ids, presence: true

  MIXED_KEY_STAGES = "Mixed key stages".freeze

  def key_stages_for_selection
    Placements::KeyStage.where.not(name: MIXED_KEY_STAGES).order_by_name
  end

  def mixed_key_stage_option
    Placements::KeyStage.find_by(name: MIXED_KEY_STAGES)
  end

  def key_stage_ids=(value)
    super normalised_key_stage_ids(value)
  end

  private

  def normalised_key_stage_ids(selected_key_stage_ids)
    return [] if selected_key_stage_ids.blank?

    selected_key_stage_ids.reject(&:blank?)
  end
end
