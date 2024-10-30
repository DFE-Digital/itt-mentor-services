class Placements::AddPlacementWizard::AdditionalSubjectsStep < BaseStep
  attribute :additional_subject_ids, default: []

  validates :additional_subject_ids, presence: true,
                                     inclusion: { in: ->(step) { step.parent_subject.child_subjects.ids } }

  delegate :name, to: :parent_subject, prefix: true

  def addition_subject_category
    # For Modern languages this returns "modern language"
    parent_subject_name.singularize.downcase
  end

  def additional_subject_ids=(value)
    super Array(value).compact_blank
  end

  def additional_subjects_for_selection
    parent_subject.child_subjects
  end

  def additional_subjects
    additional_subjects_for_selection.where(id: additional_subject_ids)
  end

  def additional_subject_names
    additional_subjects.order_by_name.pluck(:name).to_sentence
  end

  def parent_subject_id
    wizard.steps[:subject].subject_id
  end

  def parent_subject
    @parent_subject ||= Subject.find(parent_subject_id)
  end
end
