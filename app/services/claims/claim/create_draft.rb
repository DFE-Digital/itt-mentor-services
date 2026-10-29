class Claims::Claim::CreateDraft < ApplicationService
  include Claims::Claim::Referencable

  def initialize(claim:)
    @claim = claim
  end

  def call
    Claims::Claim::ChangeStatus.call(claim:, attributes: { status: :draft, reference: claim.reference || generate_reference })

    if status_changed_to_draft?
      send_claim_created_support_notification_email
    end
  end

  private

  attr_reader :claim

  def send_claim_created_support_notification_email
    NotifyRateLimiter.call(
      collection: claim.school_users,
      mailer: "Claims::UserMailer",
      mailer_method: :claim_created_support_notification,
      mailer_args: [claim],
    )
  end

  def status_changed_to_draft?
    claim.saved_change_to_status? && claim.draft?
  end
end
