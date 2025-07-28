require "rails_helper"

RSpec.describe Claims::ExportUsers do
  let(:claim_window_1) { create(:claim_window, :current) }
  let(:claim_window_2) { create(:claim_window, :upcoming) }

  let(:school_1) { create(:claims_school) }
  let(:school_2) { create(:claims_school) }

  let(:active_user) { create(:claims_user, last_signed_in_at: 1.day.ago) }
  let(:inactive_user) { create(:claims_user, last_signed_in_at: nil) }

  before do
    # Memberships
    create(:user_membership, user: active_user, organisation: school_1)
    create(:user_membership, user: inactive_user, organisation: school_2)

    # Claims
    create(:claim, school: school_1, claim_window: claim_window_1)
    create(:claim, school: school_2, claim_window: claim_window_2)
  end

  describe ".call" do
    subject(:csv_output) { described_class.call(claim_window_id:, activity_level:) }

    let(:csv) { CSV.parse(csv_output, headers: true) }

    context "when claim_window_id is 'all'" do
      let(:claim_window_id) { "all" }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes all users with any claims" do
          expect(csv["Email"]).to contain_exactly(active_user.email, inactive_user.email)
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "includes only active users with any claims" do
          expect(csv["Email"]).to contain_exactly(active_user.email)
        end
      end
    end

    context "when claim_window_id is a specific window" do
      let(:claim_window_id) { claim_window_1.id }

      context "and activity_level is 'all'" do
        let(:activity_level) { "all" }

        it "includes all users with claims for that window" do
          expect(csv["Email"]).to contain_exactly(active_user.email)
        end
      end

      context "and activity_level is 'active'" do
        let(:activity_level) { "active" }

        it "includes only active users with claims for that window" do
          expect(csv["Email"]).to contain_exactly(active_user.email)
        end
      end
    end

    context "when claim_window_id is a specific window with no active users" do
      let(:claim_window_id) { claim_window_2.id }
      let(:activity_level) { "active" }

      it "returns no results" do
        expect(csv).to be_empty
      end
    end
  end
end
