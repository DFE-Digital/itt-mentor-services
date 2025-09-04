class Claims::Claim::Submit < ApplicationService
  include Claims::Claim::Referencable

  def initialize(claim:, user:)
    @claim = claim
    @user = user
  end

  def call
    updated_claim.save!

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
    updated_claim.saved_change_to_status? && updated_claim.submitted?
  end

  def updated_claim
    @updated_claim ||= begin
      claim.status = :submitted
      claim.submitted_at = Time.current
      claim.submitted_by = user
      claim.reference = generate_reference if claim.reference.nil?
      claim.claim_window = claim_window
      claim
    end
  end

  def claim_window
    Claims::ClaimWindow.current || claim.claim_window
  end
end
