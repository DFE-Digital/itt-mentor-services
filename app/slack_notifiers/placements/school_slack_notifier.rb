class Placements::SchoolSlackNotifier < Placements::ApplicationSlackNotifier
  def school_onboarded_notification(school)
    message(
      text: ":new:  School onboarded.",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":new:  School onboarded: {school.name} have added their placement contact details. They can now start listing placements.",
          },
          accessory: {
            type: "button",
            text: {
              type: "plain_text",
              text: "View school",
            },
            url: placements_support_school_url(school),
          },
        },
      ],
    )
  end
end
