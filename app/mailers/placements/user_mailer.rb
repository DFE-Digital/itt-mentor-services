class Placements::UserMailer < Placements::ApplicationMailer
  def user_membership_created_notification(user, organisation)
    @user_name = user.first_name
    @organisation_name = organisation.name
    @service_name = service_name
    @support_email = support_email
    @sign_in_url = sign_in_url

    notify_email to: user.email, subject: t(".subject", service_name:)
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
