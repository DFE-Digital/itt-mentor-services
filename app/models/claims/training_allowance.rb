class Claims::TrainingAllowance
  def initialize(mentor:, provider:, academic_year:)
    @mentor = mentor
    @provider = provider
    @academic_year = academic_year
  end

  def training_type
    has_previous_training? ? :refresher : :initial
    has_initial_training? ? :refresher : :initial
  end
  end

  private

  attr_reader :mentor, :provider, :academic_year
  def mentor_training_scope
    @mentor_training_scope ||= provider.mentor_trainings
                                       .where(mentor:)
                                       .joins(claim: { claim_window: :academic_year })
  end

  def has_previous_training?
    provider.mentor_trainings.includes(claim: :claim_window).where(claim: { status: :submitted, claim_window: { academic_year: } }).exists?
  def has_initial_training?(previous: true)
    query = if previous
              mentor_training_scope.where(claims: { status: :submitted, claim_windows: { academic_years: { ends_on: ..academic_year.starts_on } } })
            else
              mentor_training_scope.where(claims: { status: :submitted, claim_windows: { academic_year: } })
            end

    query.exists?
  end
  end
end
