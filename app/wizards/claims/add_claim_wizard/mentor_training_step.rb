class Claims::AddClaimWizard::MentorTrainingStep < BaseStep
  attribute :hours_completed
  attribute :mentor_id
  attribute :custom_hours_completed

  validates :mentor_id, presence: true
  validates(
    :hours_completed,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: :max_hours,
    },
    unless: :custom_hours_selected?,
  )

  validates(
    :custom_hours_completed,
    presence: true,
    numericality: { only_integer: true },
    between: { min: 1, max: :max_hours },
    if: :custom_hours_selected?,
  )

  def mentor
    @mentor ||= @wizard.steps.fetch(:mentor).selected_mentors.find_by(id: mentor_id)
  end

  def max_hours
    training_allowance.remaining_hours
  end

  def training_allowance
    @training_allowance ||= Claims::TrainingAllowance.new(
      mentor:,
      provider:,
      academic_year: @wizard.academic_year,
    )
  end

  def total_hours_completed
    (custom_hours_completed.presence || hours_completed).to_i
  end

  delegate :full_name, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :provider, to: :wizard

  private

  def custom_hours_selected?
    hours_completed == "custom"
  end
end
