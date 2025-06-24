class Placements::EditPlacementWizard::KeyStageStep < BaseStep
  attribute :key_stage_id

  validates :key_stage_id, presence: true, inclusion: { in: ->(step) { step.key_stage_ids } }

  MIXED_KEY_STAGES = "Mixed key stages".freeze

  def key_stages_for_selection
    Placements::KeyStage.where.not(name: MIXED_KEY_STAGES).order_by_name
  end

  def mixed_key_stage_option
    Placements::KeyStage.find_by(name: MIXED_KEY_STAGES)
  end

  def key_stage
    @key_stage ||= Placements::KeyStage.find(key_stage_id)
  end

  def key_stage_ids
    Placements::KeyStage.ids
  end
end
