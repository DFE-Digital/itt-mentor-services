class Claims::Mentor::CalculateRemainingMentorTrainingHoursForProvider
  include ServicePattern

  MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER = 20

  def initialize(mentor:, provider:)
    @mentor = mentor
    @provider = provider
  end

  def call
    MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER - Claims::Mentor::CalculateTotalMentorTrainingHoursForProvider.call(mentor:, provider:)
  end

  private

  attr_reader :mentor, :provider
end
