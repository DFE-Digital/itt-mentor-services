require "rails_helper"

describe Claims::Claim::Clawback::ClawbackRequested do
  let!(:claim) { create(:claim, :submitted, status: :sampling_not_approved) }

  describe "#call" do
    subject(:call) { described_class.call(claim:, esfa_responses:) }

    context "when given no esfa responses" do
      let(:esfa_responses) { [] }

      it "changes to status of the claim to clawback requested" do
        expect { call }.to change(claim, :status)
          .from("sampling_not_approved")
          .to("clawback_requested")
      end
    end

    context "when given an esfa responses" do
      let(:mentor_training_1) { create(:mentor_training, claim:, not_assured: true, reason_not_assured: "reason") }
      let(:mentor_training_2) { create(:mentor_training, claim:, not_assured: true, reason_not_assured: "reason") }
      let(:esfa_responses) do
        [
          { id: mentor_training_1.id, hours_clawed_back: 20, reason_for_clawback: "Some reason" },
          { id: mentor_training_2.id, hours_clawed_back: 10, reason_for_clawback: "Another reason" },
        ]
      end

      it "updates the mentor trainings with the given response" do
        expect { call }.to change(claim, :status)
          .from("sampling_not_approved")
          .to("clawback_requested")

        mentor_training_1.reload
        mentor_training_2.reload

        expect(mentor_training_1.hours_clawed_back).to be(20)
        expect(mentor_training_1.reason_clawed_back).to eq("Some reason")
        expect(mentor_training_2.hours_clawed_back).to be(10)
        expect(mentor_training_2.reason_clawed_back).to eq("Another reason")
      end

      context "when an esfa response is not given for a mentor training associated with this claim" do
        let(:esfa_responses) do
          [
            { id: mentor_training_1.id, hours_clawed_back: 20, reason_for_clawback: "Some reason" },
          ]
        end

        before do
          mentor_training_1
          mentor_training_2
        end

        it "skips the mentor training not associated with the claim" do
          expect { call }.not_to change(mentor_training_1, :hours_clawed_back).from(nil)
        end
      end
    end
  end
end
