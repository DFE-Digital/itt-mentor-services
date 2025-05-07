class Claims::ClaimSlackNotifier < Claims::ApplicationSlackNotifier
  def daily_submitted_claims_notification(academic_year: AcademicYear.for_date(Date.current), claim_count: 0, school_count: 0, provider_count: 0, total_claims_count: 0)
    message(
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: ":claim-funding-for-mentor-training: Daily claims roundup",
            emoji: true,
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Here are today's statistics:",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":sparkles: *#{claim_count} #{"claim".pluralize(provider_count)}* #{has_or_have(claim_count)} been created",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":school: *#{school_count} #{"school".pluralize(school_count)}* #{has_or_have(school_count)} made their first claim",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":student: *#{provider_count} #{"provider".pluralize(provider_count)}* #{has_or_have(provider_count)} been selected for the first time",
          },
        },
        {
          type: "divider",
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*#{total_claims_count}* #{"claim".pluralize(total_claims_count)} #{has_or_have(total_claims_count)} been created for the #{academic_year.name} academic year!",
          },
        },
      ],
    )
  end

  private

  def has_or_have(count)
    if count == 1
      "has"
    else
      "have"
    end
  end
end
