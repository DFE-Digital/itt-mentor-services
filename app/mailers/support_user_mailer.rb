class SupportUserMailer < ApplicationMailer
  TEAM_SLACK_CHANNEL_URLS = {
    claims: "https://ukgovernmentdfe.slack.com/archives/C0657JE64HX",
    placements: "https://ukgovernmentdfe.slack.com/archives/C04MLBVP876",
  }.with_indifferent_access.freeze

  def support_user_invitation(support_user)
    subject = t(".subject", service_name:)
    body = t(
      ".body",
      user_name: support_user.first_name,
      service_name:,
      sign_in_url:,
      slack_url:,
    )

    notify_email to: support_user.email, subject:, body:
  end

  def support_user_removal_notification(support_user)
    subject = t(".subject", service_name:)
    body = t(
      ".body",
      user_name: support_user.first_name,
      service_name:,
      slack_url:,
    )

    notify_email to: support_user.email, subject:, body:
  end

  private

  def slack_url
    TEAM_SLACK_CHANNEL_URLS.fetch(service)
  end
end
