class Claims::Claim::Submit < ApplicationService
  include Claims::Claim::Referencable

  def initialize(claim:, user:)
    @claim = claim
    @user = user
  end

  def call
    Claims::Claim::ChangeStatus.call(
      claim:,
      actor: user,
      attributes: {
        status: :submitted,
        submitted_at: Time.current,
        submitted_by: user,
        reference: claim.reference || generate_reference,
        claim_window:,
      },
    )

    if status_changed_to_submitted?
      send_claim_submitted_notification_email
    end
  end

  private

  attr_reader :claim, :user

  def send_claim_submitted_notification_email
    Claims::UserMailer
      .claim_submitted_notification(user, claim).deliver_later
  end

  def status_changed_to_submitted?
    claim.saved_change_to_status? && claim.submitted?
  end

  def claim_window
    Claims::ClaimWindow.current || claim.claim_window
  end
end
