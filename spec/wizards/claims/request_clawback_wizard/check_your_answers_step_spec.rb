require "rails_helper"

RSpec.describe Claims::RequestClawbackWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::RequestClawbackWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        claim:,
        mentor_trainings: claim.mentor_trainings.not_assured,
        steps: { "mentor_training_clawback_#{mentor_training.id}".to_sym => mentor_training_clawback_step },
        step_name_for_mentor_training_clawback: "mentor_training_clawback_#{mentor_training.id}".to_sym,
      )
    end
  end

  let(:mentor_training_clawback_step) do
    instance_double(Claims::RequestClawbackWizard::MentorTrainingClawbackStep).tap do |mentor_training_clawback_step|
      allow(mentor_training_clawback_step).to receive_messages(number_of_hours: 15, reason_for_clawback: "reason")
    end
  end

  let(:claim) { create(:claim) }
  let(:mentor_trainings) { create_list(:mentor_training, 2, claim:, not_assured: true, reason_not_assured: "reason") }
  let(:mentor_training) { mentor_trainings.first }
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
    it { is_expected.to delegate_method(:steps).to(:wizard) }
    it { is_expected.to delegate_method(:step_name_for_mentor_training_clawback).to(:wizard) }
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:school).to(:claim) }
    it { is_expected.to delegate_method(:region_funding_available_per_hour).to(:school) }
  end

  describe "#mentor_training_clawback_data" do
    let(:mentor_training) { create(:mentor_training) }

    it "returns the data for the mentor training clawback" do
      expect(step.mentor_training_clawback_data(mentor_training)).to eq(mentor_training_clawback_step)
    end
  end

  describe "#mentor_training_clawback_hours" do
    it "returns the number of hours for the mentor training clawback" do
      expect(step.mentor_training_clawback_hours(mentor_training)).to eq(15)
    end
  end

  describe "#mentor_training_clawback_amount" do
    it "returns the amount for the mentor training clawback" do
      expect(step.mentor_training_clawback_amount(mentor_training)).to eq(15 * step.region_funding_available_per_hour)
    end
  end

  describe "#mentor_training_clawback_reason" do
    it "returns the reason for the mentor training clawback" do
      expect(step.mentor_training_clawback_reason(mentor_training)).to eq("reason")
    end
  end

  describe "#total_clawback_hours" do
    it "returns the total number of hours for all mentor training clawbacks" do
      expect(step.total_clawback_hours).to eq(30)
    end
  end

  describe "#total_clawback_amount" do
    it "returns the total amount for all mentor training clawbacks" do
      expect(step.total_clawback_amount).to eq(30 * step.region_funding_available_per_hour)
    end
  end
end
