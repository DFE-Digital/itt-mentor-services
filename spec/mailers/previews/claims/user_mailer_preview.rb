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
    Claims::User.new(
      id: SecureRandom.uuid,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe_bloggs@example.com",
    )
  end

  def claim
    Claims::Claim.new(id: SecureRandom.uuid, school:)
  end

  def school
    Claims::School.new(id: SecureRandom.uuid, name: "Test School", region:)
  end

  def region
    Region.new(
      name: "Test Region",
      claims_funding_available_per_hour_pence: 5360,
      claims_funding_available_per_hour_currency: "GBP",
    )
  end
end
