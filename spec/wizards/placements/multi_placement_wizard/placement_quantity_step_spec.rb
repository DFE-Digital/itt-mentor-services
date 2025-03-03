require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::PlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "validations" do
    it "adds no errors to the step" do
      expect(step.valid?).to be(true)
    end
  end

  describe "#subjects" do
    subject(:subjects) { step.subjects }

    it "returns an empty array" do
      expect(subjects).to eq([])
    end
  end
end
