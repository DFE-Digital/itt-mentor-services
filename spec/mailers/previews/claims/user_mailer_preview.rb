class Claims::UserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Claims::UserMailer.user_membership_created_notification(Claims::User.first, Claims::School.first)
  end

  def user_membership_destroyed_notification
    Claims::UserMailer.user_membership_destroyed_notification(Claims::User.first, Claims::School.first)
  end

  def claim_submitted_notification
    Claims::UserMailer.claim_submitted_notification(Claims::User.first, Claims::Claim.submitted.first)
  end

  def claim_created_support_notification
    Claims::UserMailer.claim_created_support_notification(Claims::Claim.draft.first, Claims::User.first)
  end
end
