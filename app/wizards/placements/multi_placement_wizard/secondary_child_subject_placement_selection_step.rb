class Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep < BaseStep
  attribute :parent_subject_id
  attribute :selection_id
  attribute :selection_number
  attribute :child_subject_ids, default: []

  validates :child_subject_ids, presence: true, inclusion: { in: ->(step) { step.child_subjects.ids } }

  delegate :child_subjects, to: :subject

  def subject
    @subject ||= Subject.find(parent_subject_id)
  end

  def child_subject_ids=(value)
    super normalised_child_subject_ids(value)
  end

  private

  def normalised_child_subject_ids(selected_ids)
    return [] if selected_ids.blank?

    selected_ids.reject(&:blank?)
  end
end
