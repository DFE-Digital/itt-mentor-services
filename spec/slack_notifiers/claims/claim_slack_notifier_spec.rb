require "rails_helper"

RSpec.describe Claims::ClaimSlackNotifier do
  let(:academic_year) { AcademicYear.for_date(Date.current) }

  describe "#daily_submitted_claims_notification" do
    subject(:notification) do
      described_class.claim_submitted_notification(
        academic_year:,
        claim_count:,
        school_count:,
        provider_count:,
        invalid_claim_count:,
        claim_amount:,
        total_claims_count:,
        total_claims_amount:,
      )
    end

    context "when multiple claims are created" do
      let(:claim_count) { 5 }
      let(:school_count) { 3 }
      let(:provider_count) { 2 }
      let(:claim_amount) { "£5000" }
      let(:invalid_claim_count) { 3 }
      let(:total_claims_count) { 100 }
      let(:total_claims_amount) { "£50000" }

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
              text: ":warning: *#{invalid_claim_count} claims* have an invalid provider and cannot be paid",
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
              text: ":chart_with_upwards_trend: *#{total_claims_count}* claims have been created",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":bank: *#{total_claims_amount}* has been claimed",
            },
          },
        )
      end
    end

    context "when a single claim is created" do
      let(:claim_count) { 1 }
      let(:school_count) { 1 }
      let(:claim_amount) { "£1000" }
      let(:provider_count) { 1 }
      let(:invalid_claim_count) { 1 }
      let(:total_claims_count) { 1 }
      let(:total_claims_amount) { "£1000" }

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
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":warning: *#{invalid_claim_count} claim* has an invalid provider and cannot be paid",
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
              text: ":chart_with_upwards_trend: *#{total_claims_count}* claim has been created",
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":bank: *#{total_claims_amount}* has been claimed",
            },
          },
        )
      end
    end
  end
end
