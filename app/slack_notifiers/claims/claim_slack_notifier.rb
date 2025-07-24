class Claims::ClaimSlackNotifier < Claims::ApplicationSlackNotifier
  def claim_submitted_notification(academic_year: AcademicYear.for_date(Date.current), claim_count: 0, school_count: 0, provider_count: 0, claim_amount: "£0", total_claims_count: 0, total_claims_amount: "£0", invalid_claim_count: 0, average_claim_amount: "£0")
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
            text: ":sparkles: *#{claim_count} #{"claim".pluralize(claim_count)}* #{has_or_have(claim_count)} been created",
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
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":money_with_wings: *#{claim_amount}* has been claimed in the past 24 hours",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":warning: *#{invalid_claim_count} #{"claim".pluralize(invalid_claim_count)}* #{has_or_have(invalid_claim_count)} an invalid provider and cannot be paid",
          },
        },
        {
          type: "divider",
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "For the #{academic_year.name} academic year:",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":chart_with_upwards_trend: *#{total_claims_count}* #{"claim".pluralize(total_claims_count)} #{has_or_have(total_claims_count)} been created",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":bank: *#{total_claims_amount}* has been claimed",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":abacus: *#{average_claim_amount}* is the average amount claimed",
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
