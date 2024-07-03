class Claims::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    SupportUserMailer.with(service: :claims).support_user_invitation(Claims::SupportUser.first)
  end

  def support_user_removal_notification
    SupportUserMailer.with(service: :claims).support_user_removal_notification(Claims::SupportUser.first)
  end
end
