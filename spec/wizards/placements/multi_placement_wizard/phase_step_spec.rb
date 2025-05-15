require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::PhaseStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(phases: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phases) }
  end

  describe "#phases_for_selection" do
    subject(:phases_for_selection) { step.phases_for_selection }

    it "returns open struct objects for the primary and secondary phase" do
      expect(phases_for_selection).to eq(
        [
          OpenStruct.new(
            name: "Primary",
            value: "Primary",
            description: "3 to 11 years",
          ),
          OpenStruct.new(
            name: "Secondary",
            value: "Secondary",
            description: "11 to 19 years",
          ),
          OpenStruct.new(
            name: "Special educational needs and disabilities (SEND) specific",
            value: "SEND",
            description: "You will be able to select year groups",
          ),
        ],
      )
    end
  end

  describe "#phases" do
    subject(:phases) { step.phases }

    context "when phases is blank" do
      it "returns an empty array" do
        expect(phases).to eq([])
      end
    end

    context "when the phases attribute contains a blank element" do
      let(:attributes) { { phases: ["Primary", nil] } }

      it "removes the nil element from the phases attribute" do
        expect(phases).to contain_exactly("Primary")
      end
    end

    context "when the phases attribute contains no blank elements" do
      let(:attributes) { { phases: %w[Primary Secondary] } }

      it "returns the phases attribute unchanged" do
        expect(phases).to contain_exactly(
          "Primary",
          "Secondary",
        )
      end
    end
  end
end
