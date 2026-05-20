class Claims::UserResearch::ApproveRejectSamplingClaimWizard::MentorStep < BaseStep
  attribute :mentor_ids, default: []

  validates :mentor_ids, presence: true, inclusion: { in: ->(step) { step.mentors.map(&:id) } }

  delegate :mentor_trainings, to: :wizard

  def selected_mentors
    return Claims::Mentor.none if mentor_trainings.blank?

    @selected_mentors ||= Claims::Mentor.where(id: mentor_ids).order_by_full_name
  end

  def mentors
    @mentors ||= mentor_trainings.map(&:mentor).uniq
  end

  def mentor_ids=(value)
    super Array(value).compact_blank
  end
end
