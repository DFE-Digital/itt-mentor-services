class Placements::SchoolSlackNotifier < Placements::ApplicationSlackNotifier
  def school_onboarded_notification(school)
    message(
      text: ":new: School onboarded: #{school.name}",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":new: *School onboarded:* <#{placements_school_url(school)}|#{school.name}> have added their placement contact details. They can now start listing placements.",
          },
        },
      ],
    )
  end
end
