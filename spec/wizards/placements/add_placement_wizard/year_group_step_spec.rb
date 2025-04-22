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
    subject(:year_groups_for_selection) { step.year_groups_for_selection }

    it "returns objects for all year groups, except 'mixed year groups'" do
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
        ],
      )
    end
  end

  describe "#mixed_year_group_option" do
    subject(:mixed_year_group_option) { step.mixed_year_group_option }

    it "returns an object for the mixed year groups" do
      expect(mixed_year_group_option).to eq(OpenStruct.new(
                                              value: "mixed_year_groups",
                                              name: "Mixed year groups",
                                              description: "",
                                            ))
    end
  end
end
