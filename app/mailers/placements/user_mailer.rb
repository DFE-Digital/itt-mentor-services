class Placements::UserMailer < Placements::ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   heading: t(".heading"),
                   support_email:,
                   sign_in_url:,
                 )
  end

  def user_membership_destroyed_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   support_email:,
                 )
  end
end
