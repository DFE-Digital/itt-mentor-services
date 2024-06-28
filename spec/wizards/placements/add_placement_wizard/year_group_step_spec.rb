require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::YearGroupStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Placements::AddPlacementWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(year_group: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:year_group) }
  end

  describe "#year_groups_for_selection" do
    subject { step.year_groups_for_selection }

    it { is_expected.to eq(Placement.year_groups_as_options) }
  end
end
