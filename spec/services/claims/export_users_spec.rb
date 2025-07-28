require "rails_helper"

RSpec.describe Claims::ExportUsers do
  let(:window_with_active_users)   { create(:claim_window, :current) }
  let(:window_with_inactive_users) { create(:claim_window, :upcoming) }

  let(:school_with_window_1_claim) { create(:claims_school) }
  let(:school_with_window_2_claim) { create(:claims_school) }
  let(:school_with_no_claims)      { create(:claims_school) }

  let(:active_user_with_window_1_claim)   { create(:claims_user, last_signed_in_at: 1.day.ago) }
  let(:inactive_user_with_window_2_claim) { create(:claims_user, last_signed_in_at: nil) }

  # Defaults so top-level examples work without redefining
  let(:claim_window_id) { "all" }
  let(:activity_level)  { "all" }

  before do
    # Memberships
    create(:user_membership, user: active_user_with_window_1_claim,   organisation: school_with_window_1_claim)
    create(:user_membership, user: active_user_with_window_1_claim,   organisation: school_with_no_claims)
    create(:user_membership, user: inactive_user_with_window_2_claim, organisation: school_with_window_2_claim)

    # Claims
    create(:claim, school: school_with_window_1_claim, claim_window: window_with_active_users)
    # duplicate claim to ensure we don't get duplicate rows for the same (user, school)
    create(:claim, school: school_with_window_1_claim, claim_window: window_with_active_users)

    create(:claim, school: school_with_window_2_claim, claim_window: window_with_inactive_users)
  end

  describe ".call" do
    subject(:csv_output) { described_class.call(claim_window_id:, activity_level:) }

    let(:csv) { CSV.parse(csv_output, headers: true) }

    def rows_for_user(email)
      csv.select { |r| r["email_address"] == email }
    end

    def row_for_user_and_school(email:, school:)
      csv.find { |r| r["email_address"] == email && r["school_urn"] == school.urn }
    end

    it "emits the expected CSV headers" do
      expect(csv.headers).to eq(%w[school_urn school_name user_first_name user_last_name email_address])
    end

    context "when claim_window_id is 'all'" do
      let(:claim_window_id) { "all" }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes one row per (user × school) that has any claim across all windows" do
          # Expect exactly 2 rows: (active, school_1) and (inactive, school_2)
          expect(csv["email_address"]).to contain_exactly(
            active_user_with_window_1_claim.email,
            inactive_user_with_window_2_claim.email,
          )

          active_row = row_for_user_and_school(
            email: active_user_with_window_1_claim.email,
            school: school_with_window_1_claim,
          )
          expect(active_row).not_to be_nil
          expect(active_row["school_name"]).to eq(school_with_window_1_claim.name)
          expect(active_row["user_first_name"]).to eq(active_user_with_window_1_claim.first_name)
          expect(active_row["user_last_name"]).to eq(active_user_with_window_1_claim.last_name)

          inactive_row = row_for_user_and_school(
            email: inactive_user_with_window_2_claim.email,
            school: school_with_window_2_claim,
          )
          expect(inactive_row).not_to be_nil

          # Membership without claims (school_with_no_claims) should not appear
          expect(row_for_user_and_school(
                   email: active_user_with_window_1_claim.email,
                   school: school_with_no_claims,
                 )).to be_nil
        end

        it "does not duplicate rows when multiple claims exist for the same (user, school)" do
          rows = rows_for_user(active_user_with_window_1_claim.email)
          # still only one row for school_with_window_1_claim
          expect(rows.count { |r| r["school_urn"] == school_with_window_1_claim.urn }).to eq(1)
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "includes only active users' memberships that have any claims" do
          expect(csv["email_address"]).to contain_exactly(active_user_with_window_1_claim.email)

          active_row = row_for_user_and_school(
            email: active_user_with_window_1_claim.email,
            school: school_with_window_1_claim,
          )
          expect(active_row).not_to be_nil
        end
      end
    end

    context "when claim_window_id is a specific window with active users" do
      let(:claim_window_id) { window_with_active_users.id }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes memberships with claims in that window only" do
          # Only the active user's membership at school_with_window_1_claim should be present
          expect(csv["email_address"]).to contain_exactly(active_user_with_window_1_claim.email)

          active_row = row_for_user_and_school(
            email: active_user_with_window_1_claim.email,
            school: school_with_window_1_claim,
          )
          expect(active_row).not_to be_nil

          # Should not include anything for the other school or the membership with no claims in this window
          expect(row_for_user_and_school(
                   email: active_user_with_window_1_claim.email,
                   school: school_with_no_claims,
                 )).to be_nil
          expect(row_for_user_and_school(
                   email: inactive_user_with_window_2_claim.email,
                   school: school_with_window_2_claim,
                 )).to be_nil
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "includes only active users' memberships with claims for that window" do
          expect(csv["email_address"]).to contain_exactly(active_user_with_window_1_claim.email)
        end
      end
    end

    context "when claim_window_id is a specific window with only inactive users" do
      let(:claim_window_id) { window_with_inactive_users.id }
      let(:activity_level)  { "active" }

      it "returns no results" do
        # Header only
        expect(csv.to_a.length).to eq(1)
        expect(csv).to be_empty
      end
    end
  end
end
