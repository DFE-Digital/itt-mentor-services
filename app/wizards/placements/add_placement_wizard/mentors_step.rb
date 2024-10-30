class Placements::AddPlacementWizard::MentorsStep < BaseStep
  attribute :mentor_ids, default: []

  validates :mentor_ids, presence: true

  def mentors_for_selection
    school_mentors.order_by_full_name
  end

  def mentor_ids=(value)
    super normalised_mentor_ids(value)
  end

  def mentors
    return mentors_for_selection.none if mentor_ids == NOT_KNOWN

    mentors_for_selection.where(id: mentor_ids)
  end

  def mentor_names
    return if mentor_ids == NOT_KNOWN

    mentors.map(&:full_name).to_sentence
  end

  private

  NOT_KNOWN = %w[not_known].freeze

  def normalised_mentor_ids(mentor_ids)
    if mentor_ids.blank?
      []
    elsif mentor_ids.include?("not_known")
      NOT_KNOWN
    else
      school_mentors.where(id: mentor_ids).ids
    end
  end

  def school_mentors
    @school_mentors ||= wizard.school.mentors
  end
end
