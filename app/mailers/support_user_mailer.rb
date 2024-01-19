class SupportUserMailer < ApplicationMailer
  def support_user_invitation(support_user)
    subject = t(".subject", service_name: t("#{support_user.service}.service_name"))
    body = t(
      ".body",
      user_name: support_user.full_name,
      service_name: t("#{support_user.service}.service_name"),
      sign_in_url:,
    )

    notify_email to: support_user.email, subject:, body:
  end
end
