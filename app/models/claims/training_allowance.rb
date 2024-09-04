class Claims::TrainingAllowance
  def initialize(mentor:, provider:, academic_year:)
    @mentor = mentor
    @provider = provider
    @academic_year = academic_year
  end

  def training_type
    has_previous_training? ? :refresher : :initial
  end

  private

  attr_reader :mentor, :provider, :academic_year

  def has_previous_training?
    provider.mentor_trainings.includes(claim: :claim_window).where(claim: { status: :submitted, claim_window: { academic_year: } }).exists?
  end
end
