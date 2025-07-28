require "rails_helper"

RSpec.describe Claims::ExportUsers do
  let(:claim_window_1)   { create(:claim_window, :current) }
  let(:claim_window_2) { create(:claim_window, :upcoming) }

  let(:springfield_high_school_with_claim_and_user_membership) { create(:claims_school, urn: "111111", name: "Springfield High") }
  let(:shelbyville_primary_school_with_claim_and_two_user_memberships) { create(:claims_school, urn: "222222", name: "Shelbyville Primary") }
  let(:ogdenville_college_with_claim_and_no_user_memberships) { create(:claims_school, urn: "333333", name: "Ogdenville College") }

  let(:active_user) do
    create(:claims_user,
           first_name: "Lisa",
           last_name: "Simpson",
           email: "lisa.simpson@example.com",
           last_signed_in_at: 1.day.ago)
  end

  let(:inactive_user) do
    create(:claims_user,
           first_name: "Milhouse",
           last_name: "Van Houten",
           email: "milhouse.vanhouten@example.com",
           last_signed_in_at: nil)
  end

  before do
    create(:user_membership, user: active_user, organisation: springfield_high_school_with_claim_and_user_membership)
    create(:user_membership, user: active_user, organisation: shelbyville_primary_school_with_claim_and_two_user_memberships)
    create(:user_membership, user: active_user, organisation: ogdenville_college_with_claim_and_no_user_memberships)
    create(:user_membership, user: inactive_user, organisation: shelbyville_primary_school_with_claim_and_two_user_memberships)

    create(:claim, school: springfield_high_school_with_claim_and_user_membership, claim_window: claim_window_1)
    create(:claim, school: shelbyville_primary_school_with_claim_and_two_user_memberships, claim_window: claim_window_1)

    create(:claim, school: shelbyville_primary_school_with_claim_and_two_user_memberships, claim_window: claim_window_2)
  end

  describe ".call (all windows)" do
    subject(:csv_rows) { CSV.parse(described_class.call(claim_window_id:, activity_level:)) }

    let(:claim_window_id) { "all" }

    context "when activity_level is 'all'" do
      let(:activity_level) { "all" }
      let(:duplicated_claim) { create(:claim, school: springfield_high_school_with_claim_and_user_membership, claim_window: claim_window_1) }

      it "includes one row per user membership for schools with claims, across all windows" do
        duplicated_claim
        expect(csv_rows).to contain_exactly(
          %w[school_urn school_name user_first_name user_last_name email_address],
          ["111111", "Springfield High", "Lisa", "Simpson", "lisa.simpson@example.com"],
          ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
          ["222222", "Shelbyville Primary", "Milhouse", "Van Houten", "milhouse.vanhouten@example.com"],
        )
      end
    end

    context "when activity_level is 'active'" do
      let(:activity_level) { "active" }

      it "includes only active users' memberships that have any claims" do
        expect(csv_rows).to contain_exactly(
          %w[school_urn school_name user_first_name user_last_name email_address],
          ["111111", "Springfield High", "Lisa", "Simpson", "lisa.simpson@example.com"],
          ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
        )
      end
    end
  end

  describe ".call (specific windows)" do
    subject(:csv_rows) { CSV.parse(described_class.call(claim_window_id:, activity_level:)) }

    context "when claim_window_id is window 1" do
      let(:claim_window_id) { claim_window_1.id }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes only memberships with claims in window 1 and doesnt show duplicates" do
          expect(csv_rows).to contain_exactly(
            %w[school_urn school_name user_first_name user_last_name email_address],
            ["111111", "Springfield High", "Lisa", "Simpson", "lisa.simpson@example.com"],
            ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
            ["222222", "Shelbyville Primary", "Milhouse", "Van Houten", "milhouse.vanhouten@example.com"],
          )
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "includes only active users with claims in window 1" do
          expect(csv_rows).to contain_exactly(
            %w[school_urn school_name user_first_name user_last_name email_address],
            ["111111", "Springfield High", "Lisa", "Simpson", "lisa.simpson@example.com"],
            ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
          )
        end
      end
    end

    context "when claim_window_id is the inactive window (window 2)" do
      let(:claim_window_id) { claim_window_2.id }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes only memberships with claims in window 2" do
          expect(csv_rows).to contain_exactly(
            %w[school_urn school_name user_first_name user_last_name email_address],
            ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
            ["222222", "Shelbyville Primary", "Milhouse", "Van Houten", "milhouse.vanhouten@example.com"],
          )
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "shows active users with claims in window 2" do
          expect(csv_rows).to eq([
            %w[school_urn school_name user_first_name user_last_name email_address],
            ["222222", "Shelbyville Primary", "Lisa", "Simpson", "lisa.simpson@example.com"],
          ])
        end
      end
    end
  end
end
