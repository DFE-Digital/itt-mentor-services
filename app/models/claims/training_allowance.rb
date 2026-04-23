class Claims::TrainingAllowance
  def initialize(mentor:, provider:, academic_year:, claim_to_exclude: nil)
    @mentor = mentor
    @provider = provider
    @academic_year = academic_year
    @claim_to_exclude = claim_to_exclude
  end

  def training_type
    @training_type ||= has_trained_in_a_previous_year? ? Claims::TrainingHours::REFRESHER_TRAINING_TYPE : Claims::TrainingHours::INITIAL_TRAINING_TYPE
  end

  def total_hours
    training_type == Claims::TrainingHours::INITIAL_TRAINING_TYPE ? initial_training_hours : refresher_training_hours
  end

  def remaining_hours
    @remaining_hours ||= total_hours - hours_completed
  end

  def available?
    remaining_hours.positive?
  end

  private

  attr_reader :mentor, :provider, :academic_year, :claim_to_exclude

  def mentor_training_scope
    @mentor_training_scope ||= provider.mentor_trainings
                                       .where(mentor:)
                                       .joins(claim: { claim_window: :academic_year })
  end

  def has_trained_in_a_previous_year?
    mentor_training_scope
      .where(academic_years: { ends_on: ..academic_year.starts_on })
      .merge(Claims::Claim.not_draft_status)
      .exists?
  end

  def hours_completed
    mentor_training_scope
      .where(claims: { claim_windows: { academic_year: } })
      .where.not(claim_id: claim_to_exclude&.id)
      .merge(Claims::Claim.not_internal_draft.not_payment_not_approved)
      .sum(:hours_completed)
  end

  def initial_training_hours
    Claims::TrainingHours.new(academic_year:).initial
  end

  def refresher_training_hours
    Claims::TrainingHours.new(academic_year:).refresher
  end
end
