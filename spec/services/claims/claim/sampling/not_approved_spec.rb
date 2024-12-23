require "rails_helper"

describe Claims::Claim::Sampling::NotApproved do
  let!(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved) }

  describe "#call" do
    subject(:call) { described_class.call(claim:, school_responses:) }

    context "when given no school responses" do
      let(:school_responses) { [] }

      it "changes to status of the claim to provider not approved" do
        expect { call }.to change(claim, :status)
          .from("sampling_provider_not_approved")
          .to("sampling_not_approved")
      end
    end

    context "when given school responses" do
      let(:mentor_training_1) do
        create(:mentor_training, claim:, not_assured: true, reason_not_assured: "Some reason not assured")
      end
      let(:mentor_training_2) do
        create(:mentor_training, claim:, not_assured: true, reason_not_assured: "Another reason not assured")
      end
      let(:school_responses) do
        [
          { id: mentor_training_1.id, rejected: true, reason_rejected: "Some reason" },
          { id: mentor_training_2.id, rejected: false, reason_rejected: nil },
        ]
      end

      it "updates the mentor trainings with the given response" do
        expect { call }.to change(claim, :status)
          .from("sampling_provider_not_approved")
          .to("sampling_not_approved")

        mentor_training_1.reload
        expect(mentor_training_1.rejected).to be(true)
        expect(mentor_training_1.reason_rejected).to eq("Some reason")
        expect(mentor_training_2.reload.rejected).to be(false)
      end

      context "when a school response is not given for a mentor training associated with this claim" do
        let(:school_responses) do
          [
            { id: mentor_training_1.id, rejected: true, reason_rejected: "Some reason rejected" },
          ]
        end

        before do
          mentor_training_1
          mentor_training_2
        end

        it "skips the mentor training not associated with the claim" do
          expect { call }.not_to change(mentor_training_2, :rejected).from(false)
        end
      end
    end
  end
end
