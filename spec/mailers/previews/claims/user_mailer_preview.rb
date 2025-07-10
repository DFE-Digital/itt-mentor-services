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

  def claims_have_not_been_submitted
    Claims::UserMailer.claims_have_not_been_submitted(user)
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
    PreviewClaim.new(id: SecureRandom.uuid, school:, provider:, reference: 123_456_789)
  end

  def school
    Claims::School.new(id: SecureRandom.uuid, name: "Test School", region:)
  end

  def provider
    Claims::Provider.new(id: SecureRandom.uuid, name: "Test Provider")
  end

  def region
    Region.new(
      name: "Test Region",
      claims_funding_available_per_hour_pence: 5360,
      claims_funding_available_per_hour_currency: "GBP",
    )
  end

  class PreviewClaim < Claims::Claim
    def total_clawback_amount
      Money.new(38_910, "GBP")
    end
  end
end
