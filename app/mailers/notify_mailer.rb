class NotifyMailer < ApplicationMailer
  # NotifyMailer.send_organisation_invite_email.deliver_later
  def send_organisation_invite_email(user, organisation, sign_in_url)
    body = t("#{user.service}.mailers.notify_mailer.body",
             user_name: user.full_name,
             organisation_name: organisation.name,
             sign_in_url:)

    mailer_options = { to: user.email,
                       subject: t(
                         "#{user.service}.mailers.notify_mailer.subject",
                         organisation_name: organisation.name,
                       ),
                       body: }

    notify_email(mailer_options)
  end
end
