require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::YearGroupSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(year_groups: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:year_groups) }
  end

  describe "#year_groups_for_selection" do
    subject(:year_groups_for_selection) { step.year_groups_for_selection }

    it "returns all year groups, expect for mixed year group" do
      expect(year_groups_for_selection).to eq(
        [
          OpenStruct.new(value: "nursery", name: "Nursery", description: "3 to 4 years"),
          OpenStruct.new(value: "reception", name: "Reception", description: "4 to 5 years"),
          OpenStruct.new(value: "year_1", name: "Year 1", description: "5 to 6 years"),
          OpenStruct.new(value: "year_2", name: "Year 2", description: "6 to 7 years"),
          OpenStruct.new(value: "year_3", name: "Year 3", description: "7 to 8 years"),
          OpenStruct.new(value: "year_4", name: "Year 4", description: "8 to 9 years"),
          OpenStruct.new(value: "year_5", name: "Year 5", description: "9 to 10 years"),
          OpenStruct.new(value: "year_6", name: "Year 6", description: "10 to 11 years"),
          # OpenStruct.new(value: "mixed_year_groups", name: "Mixed year groups", description: ""),
        ],
      )
    end
  end

  describe "#mixed_year_group_option" do
    subject(:mixed_year_group_option) { step.mixed_year_group_option }

    it "returns the mixed year group" do
      expect(mixed_year_group_option).to eq(
        OpenStruct.new(value: "mixed_year_groups", name: "Mixed year groups", description: ""),
      )
    end
  end

  describe "#year_groups" do
    subject(:year_groups) { step.year_groups }

    context "when year_groups is blank" do
      it "returns an empty array" do
        expect(year_groups).to eq([])
      end
    end

    context "when the year_groups attribute contains a blank element" do
      let(:attributes) { { year_groups: ["year_1", nil] } }

      it "removes the nil element from the year_groups attribute" do
        expect(year_groups).to contain_exactly("year_1")
      end
    end

    context "when the year_groups attribute contains no blank elements" do
      let(:attributes) { { year_groups: %w[reception year_2] } }

      it "returns the year_groups attribute unchanged" do
        expect(year_groups).to contain_exactly(
          "reception",
          "year_2",
        )
      end
    end
  end
end
