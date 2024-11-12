class Claims::AddClaimWizard::MentorStep < BaseStep
  attribute :mentor_ids, default: []

  validates :mentor_ids, presence: true, inclusion: { in: ->(step) { step.mentors_with_claimable_hours.unscoped.ids } }

  delegate :school, :claim, :mentors_with_claimable_hours, to: :wizard

  def selected_mentors
    return Claims::Mentor.none if mentors_with_claimable_hours.nil?

    @selected_mentors ||= mentors_with_claimable_hours.where(id: mentor_ids).order_by_full_name
  end

  def all_school_mentors_visible?
    @all_school_mentors_visible ||= school.mentors.count == mentors_with_claimable_hours.count
  end

  def mentor_ids=(value)
    super Array(value).compact_blank
  end

  private

  def provider
    @wizard.steps.fetch(:provider).provider
  end
end
