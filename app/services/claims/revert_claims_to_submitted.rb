class Claims::RevertClaimsToSubmitted < ApplicationService
  def call
    return if HostingEnvironment.env.production?

    ActiveRecord::Base.transaction do
      Claims::Claim.not_draft_status.update_all(
        status: :submitted,
        unpaid_reason: nil,
        payment_in_progress_at: nil,
        sampling_reason: nil,
        clawback_requested_by_id: nil,
        clawback_approved_by_id: nil,
      )
      Claims::MentorTraining.update_all(
        hours_clawed_back: nil,
        reason_clawed_back: nil,
        reason_not_assured: nil,
        not_assured: false,
        reason_rejected: nil,
        rejected: false,
        reason_clawback_rejected: nil,
      )
      Claims::ClaimActivity.destroy_all
    end
  end
end
