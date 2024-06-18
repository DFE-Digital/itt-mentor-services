class Placements::AddPlacement::Steps::Mentors
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :mentor_ids, default: []

  validates :school, presence: true
  validates :mentor_ids, presence: true

  def mentors_for_selection
    school.mentors
  end

  def mentor_ids=(value)
    super normalised_mentor_ids(value)
  end

  def wizard_attributes
    { mentor_ids: mentor_ids - NOT_KNOWN }
  end

  private

  NOT_KNOWN = %w[not_known].freeze

  def normalised_mentor_ids(mentor_ids)
    if mentor_ids.blank?
      []
    elsif mentor_ids.include?("not_known")
      NOT_KNOWN
    else
      school.mentors.where(id: mentor_ids).ids
    end
  end
end
