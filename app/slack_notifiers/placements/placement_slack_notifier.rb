class Placements::PlacementSlackNotifier < Placements::ApplicationSlackNotifier
  def placement_created_notification(school, placement)
    message(
      text: ":new:  Placement added.",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":new:  Placement added: {school.name} have added a {placement.title} placement.",
          },
          accessory: {
            type: "button",
            text: {
              type: "plain_text",
              text: "View placement",
            },
            url: placements_support_school_placements_url(school, placement),
          },
        },
      ],
    )
  end
end
