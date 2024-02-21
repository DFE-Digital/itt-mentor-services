class UserMailer < ApplicationMailer
  def user_invitation_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", organisation_name: organisation.name),
                 body: t(".body", user_name: user.full_name, organisation_name: organisation.name, service_name:, sign_in_url:)
  end

  def user_removal_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", organisation_name: organisation.name),
                 body: t(".body", user_name: user.full_name, organisation_name: organisation.name, service_name:)
  end
end
