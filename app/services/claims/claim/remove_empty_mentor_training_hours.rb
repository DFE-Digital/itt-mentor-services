class Claims::Claim::RemoveEmptyMentorTrainingHours < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.mentor_trainings.without_hours.destroy_all
  end

  private

  attr_reader :claim
end
