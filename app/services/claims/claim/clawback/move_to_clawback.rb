class Claims::Claim::Clawback::MoveToClawback < ApplicationService
  def initialize(claim:, current_user:)
    @claim = claim
    @current_user = current_user
  end

  def call
    Claims::Claim::Clawback::ClawbackRequested.call(claim:, esfa_responses:, current_user:)

    NotifyRateLimiter.call(
      collection: claim.school_users,
      mailer: "Claims::UserMailer",
      mailer_method: :claim_requires_clawback,
      mailer_args: [claim],
    )

    Claims::ClaimActivity.create!(action: :clawback_requested, user: current_user, record: claim)
  end

  private

  attr_reader :claim, :current_user

  def esfa_responses
    claim.mentor_trainings.not_assured.map do |mentor_training|
      {
        id: mentor_training.id,
        hours_clawed_back: mentor_training.hours_clawed_back.to_i,
        reason_for_clawback: mentor_training.reason_not_assured,
      }
    end
  end
end
