class Claims::ProviderUserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Claims::ProviderUserMailer.user_membership_created_notification(provider_user, provider)
  end

  def user_membership_destroyed_notification
    Claims::ProviderUserMailer.user_membership_destroyed_notification(provider_user, provider)
  end

  private

  def provider_user
    Claims::ProviderUser.new(
      id: SecureRandom.uuid,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "example@education.gov.uk",
    )
  end

  def provider
    Claims::Provider.new(
      id: SecureRandom.uuid,
      name: "Example Provider",
      code: "123",
    )
  end
end
