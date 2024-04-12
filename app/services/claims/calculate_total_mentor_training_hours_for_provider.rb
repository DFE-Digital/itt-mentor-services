class Claims::CalculateTotalMentorTrainingHoursForProvider
  include ServicePattern

  def initialize(mentor:, provider:)
    @mentor = mentor
    @provider = provider
  end

  def call
    mentor.mentor_trainings.where(provider:).sum(:hours_completed)
  end

  private

  attr_reader :mentor, :provider
end
