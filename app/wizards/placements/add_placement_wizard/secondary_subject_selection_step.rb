class Placements::AddPlacementWizard::SecondarySubjectSelectionStep < BaseStep
  attribute :subject_id

  validates :subject_id, presence: true, inclusion: { in: ->(step) { step.subjects_for_selection.ids } }

  delegate :name, :has_child_subjects?, to: :subject, prefix: true, allow_nil: true

  delegate :stem_subjects, :lit_lang_subjects,
           :art_humanities_social_subjects, :health_physical_education_subjects,
           to: :subjects_for_selection

  def subject
    @subject ||= Subject.find(subject_id) if subject_id.present?
  end

  def subjects_for_selection
    @subjects_for_selection = Subject.parent_subjects.secondary
  end
end
