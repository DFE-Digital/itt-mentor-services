class Placements::AddPlacement::Steps::AdditionalSubjects
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :parent_subject_id
  attribute :additional_subject_ids, default: []

  validates :school, presence: true
  validates :parent_subject_id, presence: true
  validates :additional_subject_ids, presence: true
  validate :additional_subjects_valid

  delegate :name, to: :parent_subject, prefix: true, allow_nil: true

  def additional_subjects_for_selection
    parent_subject.child_subjects
  end

  def additional_subject_ids=(value)
    super Array(value)
  end

  def wizard_attributes
    { additional_subject_ids: }
  end

  def parent_subject
    @parent_subject ||= Subject.find(parent_subject_id)
  end

  private

  def additional_subjects_valid
    return if additional_subject_ids.all? { |id| Subject.exists?(id:) }

    errors.add(:additional_subject_ids, :invalid)
  end
end
