class Claims::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    Claims::SupportUserMailer.support_user_invitation(support_user)
  end

  def support_user_removal_notification
    Claims::SupportUserMailer.support_user_removal_notification(support_user)
  end

  private

  def support_user
    Claims::SupportUser.new(
      id: SecureRandom.uuid,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "example@education.gov.uk",
    )
  end
end
