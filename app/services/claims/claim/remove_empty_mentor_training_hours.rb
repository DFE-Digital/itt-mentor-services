class Claims::Claim::RemoveEmptyMentorTrainingHours
  include ServicePattern

  def initialize(claim:)
    @claim = claim
  end

  def call
    without_auditing do
      claim.mentor_trainings.without_hours.destroy_all
    end
  end

  private

  attr_reader :claim
end
