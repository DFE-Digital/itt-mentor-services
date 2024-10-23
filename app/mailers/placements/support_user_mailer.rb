class Placements::SupportUserMailer < Placements::ApplicationMailer
  def support_user_invitation(support_user)
    @user_name = support_user.first_name
    @service_name = service_name
    @sign_in_url = sign_in_url
    @slack_url = slack_url

    notify_email to: support_user.email, subject: t(".subject", service_name:)
  end

  def support_user_removal_notification(support_user)
    @user_name = support_user.first_name
    @service_name = service_name
    @slack_url = slack_url

    notify_email to: support_user.email, subject: t(".subject", service_name:)
  end
end
