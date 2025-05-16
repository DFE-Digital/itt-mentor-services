require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::SENPlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        state:,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(sen_quantity: nil) }
  end

  describe "validations" do
    it {
      expect(step).to validate_numericality_of(:sen_quantity)
    .only_integer
    .is_greater_than(0)
    }
  end
end
