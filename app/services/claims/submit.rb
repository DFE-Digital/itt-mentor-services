class Claims::Submit
  include ServicePattern

  def initialize(claim:, claim_params:, user:)
    @claim = claim
    @claim_params = claim_params
    @user = user
  end

  def call
    updated_claim.save!

    if user.support_user? && status_changed_to_draft?
      send_claim_created_support_notification_email
    elsif !user.support_user? && status_changed_to_submitted?
      send_claim_submitted_notification_email
    end
  end

  private

  attr_reader :claim, :claim_params, :user

  def send_claim_submitted_notification_email
    UserMailer.with(service: user.service).claim_submitted_notification(user, claim).deliver_later
  end

  def send_claim_created_support_notification_email
    user_emails = claim.school_users.pluck(:email)

    user_emails.each do |email|
      UserMailer.with(service: user.service).claim_created_support_notification(claim, email).deliver_later
    end
  end

  def status_changed_to_submitted?
    updated_claim.saved_change_to_status? && updated_claim.submitted?
  end

  def status_changed_to_draft?
    updated_claim.saved_change_to_status? && updated_claim.draft?
  end

  def updated_claim
    @updated_claim ||= begin
      claim.assign_attributes(claim_params)
      claim.reference = generate_reference if claim.reference.nil?
      claim
    end
  end

  def generate_reference
    reference = SecureRandom.random_number(99_999_999) while Claim.exists?(reference:)
    reference
  end
end
