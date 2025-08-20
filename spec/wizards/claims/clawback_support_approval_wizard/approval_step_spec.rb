require "rails_helper"

RSpec.describe Claims::ClawbackSupportApprovalWizard::ApprovalStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::RequestClawbackWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim:)
      allow(mock_wizard).to receive(:mentor_trainings).and_return(claim.mentor_trainings.not_assured)
    end
  end

  let(:claim) { create(:claim) }
  let(:mentor_trainings) { create_list(:mentor_training, 2, :rejected, claim:) }
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:approved).in_array(%w[Yes No]) }

    context "when approved is NO" do
      let(:attributes) do
        {
          mentor_training_id: mentor_trainings.first.id,
          approved: "No",
        }
      end

      it "validates the presences of a reason clawback rejected" do
        step.valid?
        expect(step.errors[:reason_clawback_rejected]).to include(
          "Please enter a reason why you are rejecting this clawback",
        )
      end
    end
  end

  describe "#options_for_selection" do
    it "returns the options yes and no as OpenStruct objects" do
      expect(step.options_for_selection).to eq(
        [
          OpenStruct.new(
            name: "Yes",
          ),
          OpenStruct.new(
            name: "No",
          ),
        ],
      )
    end
  end

  describe "#mentor_training" do
    let(:mentor_training) { mentor_trainings.first }

    let(:attributes) do
      {
        mentor_training_id: mentor_training.id,
      }
    end

    it "returns the mentor training based on the given mentor training id" do
      expect(step.mentor_training).to eq(mentor_training)
    end
  end
end
