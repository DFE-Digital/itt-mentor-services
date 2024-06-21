require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::YearGroupStep, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(year_group: nil) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:primary?).to(:school).with_prefix }
  end

  describe "validations" do
    context "when the school is primary" do
      subject { described_class.new(school:) }

      let(:school) { build(:placements_school, :primary) }

      it { is_expected.to validate_presence_of(:year_group) }
    end
  end

  describe "#year_groups_for_selection" do
    it "returns year groups as options" do
      expect(described_class.new.year_groups_for_selection).to eq(Placement.year_groups_as_options)
    end
  end

  describe "#wizard_attributes" do
    it "returns the year group" do
      year_group = "Year 1"
      step = described_class.new(year_group:)

      expect(step.wizard_attributes).to eq({ year_group: })
    end
  end
end
