class Claims::SupportUserMailer < Claims::ApplicationMailer
  def support_user_invitation(support_user)
    subject = t("claims.support_user_mailer.support_user_invitation.subject", service_name:)
    body = t(
      "claims.support_user_mailer.support_user_invitation.body",
      user_name: support_user.first_name,
      service_name:,
      sign_in_url:,
      slack_url: t("claims.support_slack_url"),
    )

    notify_email to: support_user.email, subject:, body:
  end

  def support_user_removal_notification(support_user)
    subject = t("claims.support_user_mailer.support_user_removal_notification.subject", service_name:)
    body = t(
      "claims.support_user_mailer.support_user_removal_notification.body",
      user_name: support_user.first_name,
      service_name:,
      slack_url: t("claims.support_slack_url"),
    )

    notify_email to: support_user.email, subject:, body:
  end
end
