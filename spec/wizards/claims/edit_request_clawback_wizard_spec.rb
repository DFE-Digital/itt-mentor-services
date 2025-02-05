require "rails_helper"

RSpec.describe Claims::EditRequestClawbackWizard, type: :model do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, mentor_training_id:, current_step: nil) }

  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:claim) { create(:claim, status: "clawback_requested") }
  let(:current_user) { create(:claims_support_user) }
  let!(:mentor_training) { create(:mentor_training, claim:, not_assured: true, reason_not_assured: "reason", hours_completed: 20, hours_clawed_back: 6, reason_clawed_back: "Insufficient evidence") }
  let(:mentor_training_id) { mentor_training.id }
  let(:state) { {} }

  before do
    allow(claim).to receive(:save!).and_return(true)
  end

  describe "#steps" do
    subject { wizard.steps.keys }

    it "includes the mentor training clawback step only" do
      expect(wizard.steps.keys).to eq(["mentor_training_clawback_#{mentor_training.id}".to_sym])
    end
  end

  describe "#mentor_trainings" do
    it "returns the claim's mentor trainings that are not assured and orders them by mentor full name" do
      expect(wizard.mentor_trainings).to eq([mentor_training])
    end
  end

  describe "#step_name_for_mentor_training_clawback" do
    it "returns the correct step name for the mentor training clawback step" do
      expect(wizard.step_name_for_mentor_training_clawback(mentor_training)).to eq("mentor_training_clawback_#{mentor_training.id}".to_sym)
    end
  end

  describe "#setup_state" do
    before do
      wizard.setup_state
    end

    it "prepopulates the state with the relevant clawback information" do
      step_name = wizard.step_name_for_mentor_training_clawback(mentor_training).to_s
      expected_state = {
        "number_of_hours" => 6,
        "reason_for_clawback" => "Insufficient evidence",
      }

      expect(state[step_name]).to eq(expected_state)
    end
  end

  describe "#update_clawback" do
    before do
      wizard.setup_state
    end

    context "when the state is valid" do
      let(:state) do
        {
          "mentor_training_clawback_#{mentor_training.id}" => {
            "number_of_hours" => 1,
            "reason_for_clawback" => "New evidence",
          },
        }
      end

      it "updates the relevant mentor training with the new params data" do
        wizard.update_clawback

        mentor_training.reload
        expect(mentor_training.hours_clawed_back).to eq(1)
        expect(mentor_training.reason_clawed_back).to eq("New evidence")
      end
    end

    context "when the state is invalid" do
      let(:state) do
        {
          "mentor_training_clawback_#{mentor_training.id}" => {
            "number_of_hours" => 40,
            "reason_for_clawback" => "",
          },
        }
      end

      it "raises an invalid wizard error" do
        expect { wizard.update_clawback }.to raise_error("Invalid wizard state")
      end
    end
  end
end
