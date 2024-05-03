class Claims::Mentor::CalculateTotalMentorTrainingHoursForProvider
  include ServicePattern

  def initialize(mentor:, provider:, claim: nil)
    @mentor = mentor
    @provider = provider
    @claim = claim
  end

  def call
    mentor.mentor_trainings.joins(:claim).merge(Claims::Claim.active).where(provider:).where.not(claim_id: claim&.previous_revision_id).sum(:hours_completed)
  end

  private

  attr_reader :mentor, :provider, :claim
end
