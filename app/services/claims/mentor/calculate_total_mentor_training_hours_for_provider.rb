class Claims::Mentor::CalculateTotalMentorTrainingHoursForProvider
  include ServicePattern

  def initialize(mentor:, provider:)
    @mentor = mentor
    @provider = provider
  end

  def call
    mentor.mentor_trainings.joins(:claim).merge(Claims::Claim.active).where(provider:).sum(:hours_completed)
  end

  private

  attr_reader :mentor, :provider
end
