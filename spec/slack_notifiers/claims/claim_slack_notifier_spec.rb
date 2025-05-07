require "rails_helper"

RSpec.describe Claims::ClaimSlackNotifier do
  let(:academic_year) { AcademicYear.for_date(Date.current) }

  describe "#daily_submitted_claims_notification" do
    subject(:notification) do
      described_class.daily_submitted_claims_notification(
        academic_year:,
        claim_count:,
        school_count:,
        provider_count:,
        total_claims_count:,
      )
    end

    context "when multiple claims are created" do
      let(:claim_count) { 5 }
      let(:school_count) { 3 }
      let(:provider_count) { 2 }
      let(:total_claims_count) { 100 }

      it "returns a message with the correct blocks" do
        expect(notification.blocks).to include(
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
              text: ":sparkles: *#{claim_count} #{"claim".pluralize(claim_count)}* have been created",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":school: *#{school_count} #{"school".pluralize(school_count)}* have made their first claim",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":student: *#{provider_count} #{"provider".pluralize(provider_count)}* have been selected for the first time",
            },
          },
          {
            type: "divider",
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*#{total_claims_count}* claims have been created for the #{academic_year.name} academic year!",
            },
          },
        )
      end
    end

    context "when a single claim is created" do
      let(:claim_count) { 1 }
      let(:school_count) { 1 }
      let(:provider_count) { 1 }
      let(:total_claims_count) { 1 }

      it "returns a message with the correct blocks" do
        expect(notification.blocks).to include(
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
              text: ":sparkles: *#{claim_count} #{"claim".pluralize(claim_count)}* has been created",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":school: *#{school_count} #{"school".pluralize(school_count)}* has made their first claim",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":student: *#{provider_count} #{"provider".pluralize(provider_count)}* has been selected for the first time",
            },
          },
          {
            type: "divider",
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*#{total_claims_count}* claim has been created for the #{academic_year.name} academic year!",
            },
          },
        )
      end
    end
  end
end
