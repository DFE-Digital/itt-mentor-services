require "rails_helper"

RSpec.describe Claims::RequestClawbackWizard::MentorTrainingClawbackStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::RequestClawbackWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim:)
      allow(mock_wizard).to receive(:mentor_trainings).and_return(claim.mentor_trainings.not_assured)
    end
  end

  let(:claim) { create(:claim) }
  let(:mentor_trainings) { create_list(:mentor_training, 2, claim:, not_assured: true, reason_not_assured: "reason") }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_training_id: nil, number_of_hours: nil, reason_for_clawback: nil) }
  end

  describe "validations" do
    let(:mentor_training) { create(:mentor_training, claim:, hours_completed: 3, not_assured: true, reason_not_assured: "reason") }

    it { is_expected.to validate_presence_of(:mentor_training_id) }
    it { is_expected.to validate_presence_of(:number_of_hours) }
    it { is_expected.to validate_presence_of(:reason_for_clawback) }

    context "when the number of hours is greater than the hours completed" do
      let(:attributes) { { mentor_training_id: mentor_training.id, number_of_hours: 4, reason_for_clawback: "reason" } }

      it { is_expected.not_to be_valid }
    end

    context "when the number of hours is less than the hours completed" do
      let(:attributes) { { mentor_training_id: mentor_training.id, number_of_hours: 1, reason_for_clawback: "reason" } }

      it { is_expected.to be_valid }
    end

    context "when the number of hours is equal to the hours completed" do
      let(:attributes) { { mentor_training_id: mentor_training.id, number_of_hours: 3, reason_for_clawback: "reason" } }

      it { is_expected.to be_valid }
    end

    context "when the number of hours is less than 1" do
      let(:attributes) { { mentor_training_id: mentor_training.id, number_of_hours: 0, reason_for_clawback: "reason" } }

      it { is_expected.not_to be_valid }
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
    it { is_expected.to delegate_method(:mentor).to(:mentor_training) }
    it { is_expected.to delegate_method(:reason_rejected).to(:mentor_training) }
    it { is_expected.to delegate_method(:reason_not_assured).to(:mentor_training) }
    it { is_expected.to delegate_method(:full_name).to(:mentor).with_prefix }
  end

  describe "#mentor_training" do
    before do
      step.mentor_training_id = mentor_trainings.first.id
    end

    it "returns the mentor training with the given ID" do
      expect(step.mentor_training).to eq(mentor_trainings.first)
    end
  end
end
