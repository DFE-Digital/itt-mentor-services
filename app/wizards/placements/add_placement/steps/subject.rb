class Placements::AddPlacement::Steps::Subject
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :phase
  attribute :subject_id

  validates :school, presence: true
  validates :phase, presence: true
  validates :subject_id, presence: true

  def subjects_for_selection
    phase == "Primary" ? Subject.parent_subjects.primary : Subject.parent_subjects.secondary
  end

  def wizard_attributes
    { subject_id: }
  end

  def subject_has_child_subjects?
    Subject.find(subject_id).has_child_subjects?
  end
end
