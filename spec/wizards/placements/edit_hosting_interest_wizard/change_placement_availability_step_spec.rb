require "rails_helper"

RSpec.describe Placements::EditHostingInterestWizard::ChangePlacementAvailabilityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        current_user:,
        available_placements:,
      )
    end
  end

  let(:attributes) { nil }
  let(:school) { create(:placements_school) }
  let(:school_placements) { create_list(:placement, 3, school:) }
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:available_placements) { Placement.where(id: school_placements.pluck(:id)) }

  describe "delegations" do
    it { is_expected.to delegate_method(:school).to(:wizard) }
    it { is_expected.to delegate_method(:current_user).to(:wizard) }
    it { is_expected.to delegate_method(:available_placements).to(:wizard) }
  end

  describe "#placements" do
    subject(:placements) { step.placements }

    it "returns the available placements decorated" do
      expect(placements).to match_array(
        available_placements.decorate,
      )
    end
  end
end
