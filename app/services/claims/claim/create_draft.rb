class Claims::Claim::CreateDraft < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    updated_claim.save!

    if status_changed_to_draft?
      send_claim_created_support_notification_email
    end
  end

  private

  attr_reader :claim

  def send_claim_created_support_notification_email
    claim.school_users.each do |user|
      Claims::UserMailer
        .claim_created_support_notification(claim, user).deliver_later
    end
  end

  def status_changed_to_draft?
    updated_claim.saved_change_to_status? && updated_claim.draft?
  end

  def updated_claim
    @updated_claim ||= begin
      claim.status = :draft
      claim.reference = generate_reference if claim.reference.nil?
      claim
    end
  end

  def generate_reference
    loop do
      reference = SecureRandom.random_number(99_999_999)

      break reference unless Claims::Claim.exists?(reference:)
    end
  end
end
