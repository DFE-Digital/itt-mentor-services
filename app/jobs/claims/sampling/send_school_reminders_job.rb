class Claims::Sampling::SendSchoolRemindersJob < ApplicationJob
  queue_as :default

  def perform
    outstanding_claims.each do |claim|
      NotifyRateLimiter.call(
        batch_size: 1,
        collection: claim.school_users,
        mailer: "Claims::UserMailer",
        mailer_method: :claim_rejected_by_provider,
        mailer_args: [claim.decorate],
      )
    end
  end

  private

  def outstanding_claims
    @outstanding_claims ||= Claims::Claim.sampling_provider_not_approved
  end
end
