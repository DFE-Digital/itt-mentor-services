require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PreviewPlacementStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes: nil) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard)
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:build_placement).to(:wizard) }
  end

  describe "#placement" do
    it "returns the placement built by the wizard" do
      placement = instance_double(Placement)
      allow(mock_wizard).to receive(:build_placement).and_return(placement)

      expect(step.placement).to eq(placement)
    end
  end
end
