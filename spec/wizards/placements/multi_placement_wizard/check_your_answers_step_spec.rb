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
    it { is_expected.to delegate_method(:year_groups).to(:wizard) }
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_providers).to(:wizard) }
  end
end
