require "rails_helper"

RSpec.describe Placements::AddPlacement::Steps::Phase, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil, phase: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:phase) }

    context "when validating the phase" do
      let(:school) { build(:placements_school) }

      context "and the phase is primary" do
        it "is valid" do
          step = described_class.new(school:, phase: "Primary")

          expect(step).to be_valid
        end
      end

      context "and the phase is secondary" do
        it "is valid" do
          step = described_class.new(school:, phase: "Secondary")

          expect(step).to be_valid
        end
      end

      context "and the phase is not primary or secondary" do
        it "is invalid" do
          step = described_class.new(school:, phase: "Nursery")

          expect(step).not_to be_valid
        end
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
