class Claims::AddClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_id
  attribute :hours_to_claim, :string
  attribute :custom_hours

  CUSTOM_HOURS = "custom".freeze
  MAXIMUM_HOURS = "maximum".freeze
  HOURS_TO_CLAIM = [CUSTOM_HOURS, MAXIMUM_HOURS].freeze

  validates :mentor_id, presence: true
  validates :hours_to_claim, presence: true, inclusion: { in: HOURS_TO_CLAIM }

  validates(
    :custom_hours,
    presence: true,
    numericality: { only_integer: true },
    between: { min: 1, max: :max_hours },
    if: :custom_hours_selected?,
  )

  delegate :full_name, :trn, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :provider, :claim, :claim_to_exclude, to: :wizard

  def initialize(wizard:, attributes:)
    super

    return if custom_hours_selected?

    self.custom_hours = nil
  end

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
      claim_to_exclude:,
    )
  end

  def hours_completed
    (hours_to_claim == "maximum" ? max_hours : custom_hours).to_i
  end

  def hours_of_training_hint
    remaining_hours = training_allowance.remaining_hours

    if training_allowance.training_type == :initial
      I18n.t("wizards.claims.add_claim_wizard.mentor_training_step.initial_hours_of_training_hint", mentor_full_name:, mentor_trn:, remaining_hours:)
    else
      I18n.t("wizards.claims.add_claim_wizard.mentor_training_step.refresher_hours_of_training_hint", mentor_full_name:, mentor_trn:, remaining_hours:)
    end
  end

  private

  def custom_hours_selected?
    hours_to_claim == "custom"
  end
end
