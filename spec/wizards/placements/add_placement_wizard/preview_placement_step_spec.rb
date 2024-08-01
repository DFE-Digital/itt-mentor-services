require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PreviewPlacementStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes: nil) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard)
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:build_placement).to(:wizard) }
  end

  describe "aliases" do
    it "aliases #build_placement to #placement" do
      expect(step.method(:build_placement)).to eq step.method(:placement)
    end
  end
end
