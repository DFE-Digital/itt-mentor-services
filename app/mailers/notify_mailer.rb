class NotifyMailer < ApplicationMailer
  # NotifyMailer.send_organisation_invite_email.deliver_later
  def send_organisation_invite_email(user, organisation, sign_in_url)
    body = t("claims.notify_message.invite_user_to_school", user_name: user.full_name, organisation_name: organisation.name, sign_in_url:)

    mailer_options = { to: user.email, subject: "You have been invited to #{organisation.name}", body: }

    notify_email(mailer_options)
  end
end
