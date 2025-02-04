class Placements::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    Placements::SupportUserMailer.support_user_invitation(Placements::SupportUser.first)
  end

  def support_user_removal_notification
    Placements::SupportUserMailer.support_user_removal_notification(Placements::SupportUser.first)
  end
end
