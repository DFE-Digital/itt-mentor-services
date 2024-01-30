class UserMailer < ApplicationMailer
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

  def invitation_email(user, organisation, sign_in_url)
    translation_root = "mailers.user.#{user.service}.invitation_email"
    body = t("#{translation_root}.body",
             user_name: user.full_name,
             organisation_name: organisation.name,
             sign_in_url:)

    mailer_options = {
      to: user.email,
      subject: t("#{translation_root}.subject", organisation_name: organisation.name),
      body:,
    }

    notify_email(mailer_options)
  end
end
