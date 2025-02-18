class Claims::UserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Claims::UserMailer.user_membership_created_notification(user, school)
  end

  def user_membership_destroyed_notification
    Claims::UserMailer.user_membership_destroyed_notification(user, school)
  end

  def claim_submitted_notification
    Claims::UserMailer.claim_submitted_notification(user, claim)
  end

  def claim_created_support_notification
    Claims::UserMailer.claim_created_support_notification(claim, user)
  end

  def claim_requires_clawback
    Claims::UserMailer.claim_requires_clawback(claim, user)
  end

  private

  def user
    FactoryBot.build_stubbed(:claims_user)
  end

  def claim
    FactoryBot.build_stubbed(:claim)
  end

  def school
    FactoryBot.build_stubbed(:school)
  end
end
