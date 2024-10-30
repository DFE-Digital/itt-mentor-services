class Placements::AddPlacementWizard::SubjectStep < BaseStep
  attribute :subject_id

  validates :subject_id, presence: true, inclusion: { in: ->(step) { step.subjects_for_selection.ids } }

  delegate :name, :has_child_subjects?, to: :subject, prefix: true, allow_nil: true

  def subjects_for_selection
    {
      Placements::School::PRIMARY_PHASE => Subject.parent_subjects.primary,
      Placements::School::SECONDARY_PHASE => Subject.parent_subjects.secondary,
    }.fetch phase
  end

  def subject
    @subject ||= Subject.find(subject_id) if subject_id.present?
  end

  private

  def phase
    wizard.placement_phase
  end
end
