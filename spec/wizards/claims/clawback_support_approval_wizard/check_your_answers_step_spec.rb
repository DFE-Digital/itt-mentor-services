require "rails_helper"

RSpec.describe Claims::ClawbackSupportApprovalWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::ClawbackSupportApprovalWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim:)
      allow(mock_wizard).to receive_messages(step_name_for_approval: :approval)
      allow(mock_wizard).to receive_messages(steps: { approval: mock_approval_step })
    end
  end
  let(:mock_approval_step) do
    instance_double(Claims::ClawbackSupportApprovalWizard::ApprovalStep).tap do |mock_approval_step|
      allow(mock_approval_step).to receive(:approved).and_return("Yes")
    end
  end
  let(:claim) { create(:claim) }
  let(:mentor_training) { create(:mentor_training, :rejected, claim:) }
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:step_name_for_approval).to(:wizard) }
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
  end

  describe "#clawback_approved?" do
    it "returns whether or not the mentor training clawback is approved" do
      expect(step.clawback_approved?(mentor_training)).to be(true)
    end
  end
end
