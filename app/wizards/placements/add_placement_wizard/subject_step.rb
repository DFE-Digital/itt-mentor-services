class Placements::AddPlacementWizard::SubjectStep < Placements::BaseStep
  attribute :phase
  attribute :subject_id

  validates :phase, presence: true
  validates :subject_id, presence: true, inclusion: { in: ->(step) { step.subjects_for_selection.ids } }, if: ->(step) { step.phase.present? }

  def subjects_for_selection
    {
      "Primary" => Subject.parent_subjects.primary,
      "Secondary" => Subject.parent_subjects.secondary,
    }.fetch phase
  end

  def wizard_attributes
    { subject_id: }
  end

  def subject_has_child_subjects?
    Subject.find(subject_id).has_child_subjects?
  end
end
