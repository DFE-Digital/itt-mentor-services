class Placements::PlacementSlackNotifier < Placements::ApplicationSlackNotifier
  def placement_created_notification(school, placement)
    message(
      text: ":new: Placement added: #{placement.title} at #{school.name}",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":new: *Placement added:* <#{placements_school_placement_url(school, placement)}|#{placement.title}> at #{school.name}",
          },
        },
      ],
    )
  end
end
