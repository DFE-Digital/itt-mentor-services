class Placements::AddPlacementWizard::SubjectSelectionStep < BaseStep
  attribute :subject_id

  validates :subject_id, presence: true, inclusion: { in: ->(step) { step.subjects_for_selection.ids } }

  delegate :name, :has_child_subjects?, to: :subject, prefix: true, allow_nil: true

  def subject
    @subject ||= Subject.find(subject_id) if subject_id.present?
  end
end
