class Claims::Claim::Submit
  include ServicePattern

  def initialize(claim:, user:)
    @claim = claim
    @user = user
  end

  def call
    updated_claim.save!

    if status_changed_to_submitted?
      send_claim_submitted_notification_email
      send_claim_submitted_notification_slack_message
    end
  end

  private

  attr_reader :claim, :user

  def send_claim_submitted_notification_email
    UserMailer.with(service: :claims)
      .claim_submitted_notification(user, claim).deliver_later
  end

  def send_claim_submitted_notification_slack_message
    Claims::ClaimSlackNotifier.claim_submitted_notification(claim).deliver_later
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
      claim
    end
  end

  def generate_reference
    reference = SecureRandom.random_number(99_999_999) while Claims::Claim.exists?(reference:)
    reference
  end
end
