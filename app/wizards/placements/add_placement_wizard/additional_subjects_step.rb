class Placements::AddPlacementWizard::AdditionalSubjectsStep
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :parent_subject_id
  attribute :additional_subject_ids, default: []

  validates :school, presence: true
  validates :parent_subject_id, presence: true
  validates :additional_subject_ids, presence: true,
                                     inclusion: { in: ->(step) { step.parent_subject.child_subjects.ids } },
                                     if: ->(step) { step.parent_subject_id.present? }

  delegate :name, to: :parent_subject, prefix: true, allow_nil: true

  def additional_subjects_for_selection
    parent_subject.child_subjects
  end

  def wizard_attributes
    { additional_subject_ids: }
  end

  def parent_subject
    @parent_subject ||= Subject.find(parent_subject_id)
  end
end
