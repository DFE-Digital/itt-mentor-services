require "rails_helper"

# TODO: Support user tries to request a clawback of more hours than were claimed
# TODO: Support user tries to request a clawback of more hours than are available to clawback

RSpec.describe Claims::RequestClawbackWizard do
  subject(:wizard) { described_class.new(claim:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:claim) { create(:claim, status: "sampling_in_progress") }
  let!(:mentor_training) { create(:mentor_training, claim:, not_assured: true, reason_not_assured: "reason") }

  before do
    allow(claim).to receive(:save!).and_return(true)
  end

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq ["mentor_training_clawback_#{mentor_training.id}".to_sym, :check_your_answers] }
  end

  describe "#mentor_trainings" do
    it "returns the claim's mentor trainings that are not assured and orders them by mentor full name" do
      expect(wizard.mentor_trainings).to eq([mentor_training])
    end
  end

  describe "#step_name_for_mentor_training_clawback" do
    it "returns the step name for the mentor training clawback step" do
      expect(wizard.step_name_for_mentor_training_clawback(mentor_training)).to eq("mentor_training_clawback_#{mentor_training.id}".to_sym)
    end
  end

  describe "#esfa_responses_for_mentor_trainings" do
    context "when the mentor training clawback step is valid" do
      let(:state) do
        {
          "mentor_training_clawback_#{mentor_training.id}" => {
            "number_of_hours" => 5,
            "reason_for_clawback" => "Some reason",
          },
        }
      end

      it "returns an array of hashes containing the mentor training id, number of hours and reason for clawback" do
        expect(wizard.esfa_responses_for_mentor_trainings).to eq([{ id: mentor_training.id, number_of_hours: 5, reason_for_clawback: "Some reason" }])
      end
    end
  end

  describe "#submit_esfa_responses" do
    let(:esfa_responses) { [{ id: mentor_training.id, number_of_hours: 5, reason_for_clawback: "Some reason" }] }

    before do
      allow(Claims::Claim::Clawback::ClawbackRequested).to receive(:call)
    end

    context "when the wizard is valid" do
      let(:state) do
        {
          "mentor_training_clawback_#{mentor_training.id}" => {
            "number_of_hours" => 5,
            "reason_for_clawback" => "Some reason",
          },
        }
      end

      it "calls the ClawbackRequested service with the claim and esfa responses" do
        wizard.submit_esfa_responses
        expect(Claims::Claim::Clawback::ClawbackRequested).to have_received(:call).with(claim:, esfa_responses:)
      end
    end

    context "when the wizard is invalid" do
      it "raises an error" do
        expect { wizard.submit_esfa_responses }.to raise_error("Invalid wizard state")
      end
    end
  end
end
