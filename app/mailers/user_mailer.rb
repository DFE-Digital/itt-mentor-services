class UserMailer < ApplicationMailer
  def user_invitation_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", organisation_name: organisation.name),
                 body: t(".body", user_name: user.full_name, organisation_name: organisation.name, service_name:, sign_in_url:)
  end

  def removal_email(user, organisation)
    translation_root = "mailers.user.#{user.service}.removal_email"
    mailer_options = {
      to: user.email,
      subject: t("#{translation_root}.subject", organisation_name: organisation.name),
      body: t("#{translation_root}.body",
              user_name: user.full_name,
              organisation_name: organisation.name),
    }

    notify_email(mailer_options)
  end
end
