class Claims::Mentor::CalculateRemainingMentorTrainingHoursForProvider < ApplicationService
  MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER = 20

  def initialize(mentor:, provider:, claim: nil, mentor_training: nil)
    @mentor = mentor
    @provider = provider
    @mentor_training = claim ? claim.mentor_trainings.find_by(mentor:, provider:) : mentor_training
  end

  def call
    MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER -
      Claims::Mentor::CalculateTotalMentorTrainingHoursForProvider.call(mentor:, provider:, claim: mentor_training&.claim) +
      current_mentor_training_hours
  end

  private

  attr_reader :mentor, :provider, :mentor_training

  def current_mentor_training_hours
    mentor_training&.claim&.active? ? mentor_training.hours_completed.to_i : 0
  end
end
