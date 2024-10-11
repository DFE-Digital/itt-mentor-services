class Claims::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    Claims::SupportUserMailer.support_user_invitation(Claims::SupportUser.first)
  end

  def support_user_removal_notification
    Claims::SupportUserMailer.support_user_removal_notification(Claims::SupportUser.first)
  end
end
