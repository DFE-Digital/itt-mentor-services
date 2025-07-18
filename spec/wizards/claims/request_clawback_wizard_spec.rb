require "rails_helper"

RSpec.describe Claims::RequestClawbackWizard do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { build(:claims_school) }
  let(:user) { create(:claims_user, schools: [school]) }
  let(:claim) { create(:claim, status: "sampling_in_progress", school:) }
  let(:current_user) { create(:claims_support_user) }
  let!(:mentor_training) { create(:mentor_training, claim:, not_assured: true, reason_not_assured: "reason", hours_completed: 20) }

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
        expect(wizard.esfa_responses_for_mentor_trainings).to eq([{ id: mentor_training.id, hours_clawed_back: 15, reason_for_clawback: "Some reason" }])
      end
    end
  end

  describe "#submit_esfa_responses" do
    let(:esfa_responses) { [{ id: mentor_training.id, hours_clawed_back: 15, reason_for_clawback: "Some reason" }] }

    before do
      user
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

      it "calls the ClawbackRequested service with the claim and payer responses" do
        wizard.submit_esfa_responses
        expect(Claims::Claim::Clawback::ClawbackRequested).to have_received(:call).with(claim:, esfa_responses:)
      end

      it "creates a claim activity record" do
        expect { wizard.submit_esfa_responses }.to change(Claims::ClaimActivity, :count).by(1)
          .and enqueue_mail(Claims::UserMailer, :claim_requires_clawback)
        expect(Claims::ClaimActivity.last.action).to eq("clawback_requested")
        expect(Claims::ClaimActivity.last.user).to eq(current_user)
        expect(Claims::ClaimActivity.last.record).to eq(claim)
      end
    end

    context "when the wizard is invalid" do
      it "raises an error" do
        expect { wizard.submit_esfa_responses }.to raise_error("Invalid wizard state")
      end
    end
  end
end
