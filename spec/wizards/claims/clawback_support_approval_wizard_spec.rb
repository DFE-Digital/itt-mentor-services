require "rails_helper"

RSpec.describe Claims::ClawbackSupportApprovalWizard, type: :model do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, current_step: nil) }

  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:claim) { create(:claim, :audit_requested, status: :clawback_requires_approval) }
  let(:current_user) { create(:claims_support_user) }
  let!(:mentor_training) do
    create(
      :mentor_training,
      :rejected,
      claim:,
      hours_completed: 20,
      hours_clawed_back: 6,
      reason_clawed_back: "Insufficient evidence",
    )
  end
  let(:mentor_training_id) { mentor_training.id }
  let(:state) { {} }

  describe "#steps" do
    subject { wizard.steps.keys }

    it "includes the mentor training clawback step only" do
      expect(wizard.steps.keys).to contain_exactly(
        "approval_#{mentor_training.id}".to_sym,
        :check_your_answers,
      )
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:reference).to(:claim).with_prefix(true) }
  end

  describe "#mentor_trainings" do
    before do
      create(:mentor_training, :submitted, claim:)
    end

    it "returns the claim's mentor trainings that are not assured and orders them by mentor full name" do
      expect(wizard.mentor_trainings).to eq([mentor_training])
    end
  end

  describe "#approve_clawback" do
    subject(:approve_clawback) { wizard.approve_clawback }

    context "when all mentor training clawbacks are approved" do
      let(:state) do
        {
          "approval_#{mentor_training.id}" => {
            mentor_training_id: mentor_training.id,
            approved: "Yes",
          },
        }
      end

      it "updates the claim status to clawback_requested" do
        expect { approve_clawback }.to change(claim, :status)
          .from("clawback_requires_approval")
          .to("clawback_requested")
          .and change(claim, :clawback_approved_by)
          .to(current_user)
      end
    end

    context "when at least one mentor training clawback is not approved" do
      let(:state) do
        {
          "approval_#{mentor_training.id}" => {
            mentor_training_id: mentor_training.id,
            approved: "No",
            reason_clawback_rejected: "Some reason",
          },
        }
      end

      it "updates the claim status to clawback_rejected" do
        expect { approve_clawback }.to change(claim, :status)
          .from("clawback_requires_approval")
          .to("clawback_rejected")
      end

      it "updates the mentor training with the reason it was rejected" do
        approve_clawback

        mentor_training.reload
        expect(mentor_training.reason_clawback_rejected).to eq("Some reason")
      end
    end
  end

  describe "#step_name_for_approval" do
    it "returns the step name for the mentor training approval step" do
      expect(wizard.step_name_for_approval(mentor_training)).to eq("approval_#{mentor_training.id}".to_sym)
    end
  end
end
