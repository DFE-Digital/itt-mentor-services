require "rails_helper"

RSpec.describe Claims::Clawback::UpdateClaimWithESFAResponseJob, type: :job do
  let(:claim) { create(:claim, :submitted, status: :clawback_in_progress) }
  let(:claim_update_details) { { id: claim.id, status:, esfa_responses: } }
  let(:status) { :clawback_complete }
  let(:esfa_responses) { [] }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    it "changes the status of the claim to sampling_provider_not_approved" do
      perform
      expect(claim.reload.status).to eq("clawback_complete")
    end

    context "when the claim has associated mentor trainings" do
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
      let(:john_smith_mentor_training) do
        create(:mentor_training,
               :rejected,
               claim:,
               mentor: mentor_john_smith,
               hours_completed: 20)
      end
      let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
      let(:jane_doe_mentor_training) do
        create(:mentor_training,
               :rejected,
               claim:,
               mentor: mentor_jane_doe,
               hours_completed: 10)
      end

      let(:esfa_responses) do
        [
          { id: john_smith_mentor_training.id, hours_clawed_back: 10, reason_clawed_back: "Some reason" },
          { id: jane_doe_mentor_training.id, hours_clawed_back: 5, reason_clawed_back: "Another reason" },
        ]
      end

      it "updates the clawed back hours and reason for mentors" do
        perform
        expect(claim.reload.status).to eq("clawback_complete")
        expect(john_smith_mentor_training.reload.hours_clawed_back).to eq(10)
        expect(john_smith_mentor_training.reload.reason_clawed_back).to eq("Some reason")
        expect(jane_doe_mentor_training.reload.hours_clawed_back).to be(5)
        expect(jane_doe_mentor_training.reload.reason_clawed_back).to eq("Another reason")
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
