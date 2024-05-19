class Claims::ClaimSlackNotifier < Claims::ApplicationSlackNotifier
  def claim_submitted_notification(claim)
    message(
      text: ":tada:  A new claim has been submitted.",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":tada:  A new claim has been submitted.",
          },
          accessory: {
            type: "button",
            text: {
              type: "plain_text",
              text: "View Claim",
            },
            url: claims_support_claim_url(claim),
          },
        },
      ],
    )
  end
end
