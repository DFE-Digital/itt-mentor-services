require "rails_helper"

describe Claims::Claim::Clawback::Complete do
  let!(:claim) { create(:claim, :submitted, status: :clawback_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:, esfa_responses:) }

    context "when given no esfa responses" do
      let(:esfa_responses) { [] }

      it "changes to status of the claim to clawback requested" do
        expect { call }.to change(claim, :status)
          .from("clawback_in_progress")
          .to("clawback_complete")
      end
    end

    context "when given an esfa responses" do
      let(:mentor_training_1) do
        create(:mentor_training,
               :rejected,
               claim:,
               hours_completed: 20)
      end
      let(:mentor_training_2) do
        create(:mentor_training,
               :rejected,
               claim:,
               hours_completed: 10)
      end
      let(:esfa_responses) do
        [
          { id: mentor_training_1.id, hours_clawed_back: 10, reason_clawed_back: "Some reason" },
          { id: mentor_training_2.id, hours_clawed_back: 5, reason_clawed_back: "Another reason" },
        ]
      end

      it "updates the mentor trainings with the given response" do
        expect { call }.to change(claim, :status)
          .from("clawback_in_progress")
          .to("clawback_complete")

        mentor_training_1.reload
        mentor_training_2.reload

        expect(mentor_training_1.hours_clawed_back).to be(10)
        expect(mentor_training_1.reason_clawed_back).to eq("Some reason")
        expect(mentor_training_2.hours_clawed_back).to be(5)
        expect(mentor_training_2.reason_clawed_back).to eq("Another reason")
      end

      context "when an esfa response is not given for a mentor training associated with this claim" do
        let(:esfa_responses) do
          [
            { id: mentor_training_1.id, number_of_hours: 20, reason_for_clawback: "Some reason" },
          ]
        end

        before do
          mentor_training_1
          mentor_training_2
        end

        it "skips the mentor training not associated with the claim" do
          expect { call }.not_to change(mentor_training_2, :hours_clawed_back).from(nil)
        end
      end
    end
  end
end
