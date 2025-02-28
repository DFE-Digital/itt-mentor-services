class Placements::MultiPlacementWizard::SubjectSelectionStep < BaseStep
  attribute :subject_ids, default: []

  validates :subject_ids, presence: true, inclusion: { in: ->(step) { step.subjects_for_selection.ids } }

  def subjects_for_selection
    {
      Placements::School::PRIMARY_PHASE => Subject.parent_subjects.primary,
      Placements::School::SECONDARY_PHASE => Subject.parent_subjects.secondary,
    }.fetch phase
  end

  def subject_ids=(value)
    super normalised_subject_ids(value)
  end

  private

  def normalised_subject_ids(selected_ids)
    return [] if selected_ids.blank?

    selected_ids.reject(&:blank?)
  end

  def phase; end
end
