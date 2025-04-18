require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        steps: {
          phase: mock_phase_step,
        },
      )
    end
  end
  let(:mock_phase_step) do
    instance_double(Placements::MultiPlacementWizard::PhaseStep).tap do |mock_phase_step|
      allow(mock_phase_step).to receive_messages(
        phases: selected_phases,
        class: Placements::MultiPlacementWizard::PhaseStep,
      )
    end
  end
  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:selected_phases) { %w[Primary Secondary] }

  describe "delegations" do
    it { is_expected.to delegate_method(:phases).to(:phase_step) }
    it { is_expected.to delegate_method(:selected_primary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_providers).to(:wizard) }
  end

  describe "#primary_and_secondary_phases?" do
    subject(:primary_and_secondary_phases) { step.primary_and_secondary_phases? }

    context "when both Primary and Secondary phases are selected" do
      it "returns true" do
        expect(primary_and_secondary_phases).to be(true)
      end
    end

    context "when only the Primary phase is selected" do
      let(:selected_phases) { %w[Primary] }

      it "returns false" do
        expect(primary_and_secondary_phases).to be(false)
      end
    end

    context "when only the Secondary phase is selected" do
      let(:selected_phases) { %w[Secondary] }

      it "returns false" do
        expect(primary_and_secondary_phases).to be(false)
      end
    end
  end
end
