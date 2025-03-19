require "rails_helper"

RSpec.describe Claims::School::OnboardSchoolsJob, type: :job do
  describe "#perform" do
    let(:london_school) { create(:school, name: "London School") }
    let(:guildford_school) { create(:school, name: "Guildford School") }
    let(:york_school) { create(:school, name: "York School") }
    let(:school_ids) { [london_school.id, york_school.id] }

    context "when a current claim window exists" do
      let(:current_claim_window) { create(:claim_window, :current) }

      before { current_claim_window }

      it "onboards the school and adds eligibilty for the current claim window" do
        expect { described_class.perform_now(school_ids:) }.to change(Claims::School, :count).by(2)
          .and change(Claims::Eligibility, :count).by(2)

        london_school.reload
        york_school.reload
        guildford_school.reload

        expect(london_school.claims_service).to be(true)
        expect(york_school.claims_service).to be(true)
        expect(guildford_school.claims_service).to be(false)

        expect(current_claim_window.eligible_schools.ids).to match_array(school_ids)
      end
    end

    context "when given a specific claim window" do
      let(:claim_window) { create(:claim_window, :historic) }

      it "onboards the school and adds eligibilty for the given claim window" do
        expect {
          described_class.perform_now(school_ids:, claim_window_id: claim_window.id)
        }.to change(Claims::School, :count).by(2)
          .and change(Claims::Eligibility, :count).by(2)

        london_school.reload
        york_school.reload
        guildford_school.reload

        expect(london_school.claims_service).to be(true)
        expect(york_school.claims_service).to be(true)
        expect(guildford_school.claims_service).to be(false)

        expect(claim_window.eligible_schools.ids).to match_array(school_ids)
      end

      context "when the given specific claim window is invalid" do
        it "returns an error" do
          expect {
            described_class.perform_now(school_ids:, claim_window_id: "ABC")
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(school_ids:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
