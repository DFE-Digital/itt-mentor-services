class Claims::TrainingAllowance
  def initialize(mentor:, provider:, academic_year:, claim_to_exclude: nil)
    @mentor = mentor
    @provider = provider
    @academic_year = academic_year
    @claim_to_exclude = claim_to_exclude
  end

  def training_type
    has_initial_training? ? :refresher : :initial
  end

  def total_hours
    if training_type == :initial
      20
    elsif training_type == :refresher
      6
    end
  end

  def remaining_hours
    total_hours - hours_completed
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

  def has_initial_training?(previous: true)
    query = if previous
              mentor_training_scope.where(claims: { status: :submitted, claim_windows: { academic_years: { ends_on: ..academic_year.starts_on } } })
            else
              mentor_training_scope.where(claims: { status: :submitted, claim_windows: { academic_year: } })
            end

    query.exists?
  end

  def hours_completed
    mentor_training_scope
      .where(claims: { status: :submitted, claim_windows: { academic_year: } })
      .merge(Claims::Claim.active)
      .where.not(claim_id: [claim_to_exclude.id, claim_to_exclude&.previous_revision_id])
      .sum(:hours_completed)
  end
end
