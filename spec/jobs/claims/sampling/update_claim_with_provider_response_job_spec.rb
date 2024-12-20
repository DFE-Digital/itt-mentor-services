require "rails_helper"

RSpec.describe Claims::Sampling::UpdateClaimWithProviderResponseJob, type: :job do
  let(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }
  let(:claim_update_details) { { id: claim.id, status:, provider_responses: } }
  let(:status) { :paid }
  let(:provider_responses) { [] }

  describe "#perform" do
    subject(:perform) { described_class.perform_now(claim_update_details) }

    context "when the updated status is paid" do
      it "changes the status of the claim to paid" do
        perform
        expect(claim.reload.status).to eq("paid")
      end
    end

    context "when the updated status is sampling_provider_not_approved" do
      let(:status) { :sampling_provider_not_approved }

      it "changes the status of the claim to sampling_provider_not_approved" do
        perform
        expect(claim.reload.status).to eq("sampling_provider_not_approved")
      end

      context "when the claim has associated mentor trainings" do
        let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
        let(:john_smith_mentor_training) { create(:mentor_training, claim:, mentor: mentor_john_smith) }
        let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
        let(:jane_doe_mentor_training) { create(:mentor_training, claim:, mentor: mentor_jane_doe) }

        let(:provider_responses) do
          [
            { id: john_smith_mentor_training.id, not_assured: false, reason_not_assured: nil },
            { id: jane_doe_mentor_training.id, not_assured: true, reason_not_assured: "Some reason" },
          ]
        end

        it "updates the not assured status and reason not assured for mentors flagged as not assured" do
          perform
          expect(claim.reload.status).to eq("sampling_provider_not_approved")
          expect(john_smith_mentor_training.reload.not_assured).to be(false)
          expect(john_smith_mentor_training.reload.reason_not_assured).to be_nil
          expect(jane_doe_mentor_training.reload.not_assured).to be(true)
          expect(jane_doe_mentor_training.reload.reason_not_assured).to eq("Some reason")
        end
      end
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_update_details)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
