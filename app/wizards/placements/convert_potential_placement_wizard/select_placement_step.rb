class Placements::ConvertPotentialPlacementWizard::SelectPlacementStep < BaseStep
  delegate :potential_placement_details, :placement_count, to: :wizard

  attribute :year_groups, default: []
  attribute :subject_ids, default: []
  attribute :key_stage_ids, default: []

  validates :year_groups, presence: true, if: -> { primary_year_groups.present? && subject_ids.blank? && key_stage_ids.blank? }
  validates :subject_ids, presence: true, if: -> { secondary_subjects.present? && year_groups.blank? && key_stage_ids.blank? }
  validates :key_stage_ids, presence: true, if: -> { key_stages.present? && year_groups.blank? && subject_ids.blank? }

  def primary_year_groups
    return [] if potential_placement_details.dig("year_group_selection", "year_groups").blank?

    @primary_year_groups ||= year_groups_as_options.select do |option|
      potential_placement_details.dig("year_group_selection", "year_groups").include?(option.value)
    end
  end

  def secondary_subjects
    @secondary_subjects ||= Subject.secondary.where(
      id: potential_placement_details.dig("secondary_subject_selection", "subject_ids"),
    )
  end

  def key_stages
    @key_stages ||= Placements::KeyStage.where(
      id: potential_placement_details.dig("key_stage_selection", "key_stage_ids"),
    )
  end

  def subject_ids=(value)
    super normalised_values(value)
  end

  def year_groups=(value)
    super normalised_values(value)
  end

  def key_stage_ids=(value)
    super normalised_values(value)
  end

  private

  def year_groups_as_options
    @year_groups_as_options ||= Placement.year_groups_as_options
  end

  def normalised_values(values)
    return [] if values.blank?

    values.reject(&:blank?)
  end
end
