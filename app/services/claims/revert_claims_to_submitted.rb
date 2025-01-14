class Claims::RevertClaimsToSubmitted < ApplicationService
  def call
    return if HostingEnvironment.env.production?

    ActiveRecord::Base.transaction do
      Claims::Claim.not_draft_status.update_all(
        status: :submitted,
        unpaid_reason: nil,
        payment_in_progress_at: nil,
        sampling_reason: nil,
      )
      Claims::MentorTraining.update_all(
        hours_clawed_back: nil,
        reason_clawed_back: nil,
        reason_not_assured: nil,
        not_assured: false,
        reason_rejected: nil,
        rejected: false,
      )
      Claims::ClaimActivity.destroy_all
    end
  end
end
