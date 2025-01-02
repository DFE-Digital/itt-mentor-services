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

  describe "#update_status" do
    it "updates the claim status to 'clawback_requested' and saves the claim" do
      wizard.update_status
      expect(claim.status).to eq("clawback_requested")
      expect(claim).to have_received(:save!)
    end
  end
end
