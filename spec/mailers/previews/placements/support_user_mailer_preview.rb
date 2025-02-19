class Placements::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    Placements::SupportUserMailer.support_user_invitation(support_user)
  end

  def support_user_removal_notification
    Placements::SupportUserMailer.support_user_removal_notification(support_user)
  end

  private

  def support_user
    Placements::SupportUser.new(
      id: SecureRandom.uuid,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "example@education.gov.uk",
    )
  end
end
