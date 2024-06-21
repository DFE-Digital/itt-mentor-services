require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PhaseStep, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(phase: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phase) }

    describe "phase" do
      subject { described_class.new(school: build(:placements_school), phase:) }

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
      step = described_class.new(school: build(:placements_school))

      expect(step.phases_for_selection).to eq({ primary: "Primary", secondary: "Secondary" })
    end
  end

  describe "#wizard_attributes" do
    it "returns the phase" do
      step = described_class.new(school: build(:placements_school), phase: "Primary")

      expect(step.wizard_attributes).to eq({ phase: "Primary" })
    end
  end
end
