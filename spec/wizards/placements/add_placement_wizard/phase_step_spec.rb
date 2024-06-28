require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PhaseStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Placements::AddPlacementWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(phase: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phase) }

    describe "phase" do
      let(:attributes) { { phase: } }

      context "when the phase is primary" do
        let(:phase) { "Primary" }

        it { is_expected.to be_valid }
      end

      context "when the phase is secondary" do
        let(:phase) { "Secondary" }

        it { is_expected.to be_valid }
      end

      context "when the phase is neither primary nor secondary" do
        let(:phase) { "Nursery" }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe "#phases_for_selection" do
    it "returns primary and secondary phases" do
      expect(step.phases_for_selection.map(&:name)).to eq(%w[Primary Secondary])
    end
  end
end
