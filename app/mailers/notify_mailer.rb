class NotifyMailer < ApplicationMailer
  # NotifyMailer.send_school_invite_email.deliver_later
  def send_school_invite_email(user, school, sign_in_url)
    body = t("claims.notify_message.invite_user_to_school", user_name: user.full_name, school_name: school.name, sign_in_url:)

    mailer_options = { to: user.email, subject: "You have been invited to #{school.name}", body: }

    notify_email(mailer_options)
  end
end
