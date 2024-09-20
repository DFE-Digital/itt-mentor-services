class Claims::TrainingAllowance
  def initialize(mentor:, provider:, academic_year:, claim_to_exclude: nil)
    @mentor = mentor
    @provider = provider
    @academic_year = academic_year
    @claim_to_exclude = claim_to_exclude
  end

  def training_type
    @training_type ||= has_trained_in_a_previous_year? ? REFRESHER_TRAINING_TYPE : INITIAL_TRAINING_TYPE
  end

  def total_hours
    training_type == INITIAL_TRAINING_TYPE ? INITIAL_TRAINING_HOURS : REFRESHER_TRAINING_HOURS
  end

  def remaining_hours
    @remaining_hours ||= total_hours - hours_completed
  end

  def available?
    remaining_hours.positive?
  end

  private

  attr_reader :mentor, :provider, :academic_year, :claim_to_exclude

  INITIAL_TRAINING_TYPE = :initial
  INITIAL_TRAINING_HOURS = 20
  REFRESHER_TRAINING_TYPE = :refresher
  REFRESHER_TRAINING_HOURS = 6

  private_constant :INITIAL_TRAINING_TYPE, :INITIAL_TRAINING_HOURS, :REFRESHER_TRAINING_TYPE,
                   :REFRESHER_TRAINING_HOURS

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
      .where.not(claim_id: [claim_to_exclude&.id, claim_to_exclude&.previous_revision_id])
      .merge(Claims::Claim.active)
      .sum(:hours_completed)
  end
end
