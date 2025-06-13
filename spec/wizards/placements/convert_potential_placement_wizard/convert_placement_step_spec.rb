require "rails_helper"

RSpec.describe Placements::ConvertPotentialPlacementWizard::ConvertPlacementStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::ConvertPotentialPlacementWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(convert: nil) }
  end

  describe "validations" do
    it {
      expect(step).to validate_inclusion_of(:convert).in_array(
        %w[Yes No],
      )
    }
  end

  describe "#options_for_selection" do
    it "returns the options yes and no as OpenStruct objects" do
      expect(step.options_for_selection).to eq(
        [
          OpenStruct.new(
            value: "Yes",
            name: "Yes, I will select the potential placements I want to convert",
            hint: "Only the information you select will remain on the service",
          ),
          OpenStruct.new(
            value: "No",
            name: "No, I will manually add the placements I can offer",
            hint: "Remove your potential information and replace with placements you can offer providers",
          ),
        ],
      )
    end
  end

  describe "#covert?" do
    subject(:to_convert) { step.convert? }

    context "when the convert attribute is 'Yes'" do
      let(:attributes) { { convert: "Yes" } }

      it "returns true" do
        expect(to_convert).to be(true)
      end
    end

    context "when the convert attribute is 'No'" do
      let(:attributes) { { convert: "No" } }

      it "returns false" do
        expect(to_convert).to be(false)
      end
    end
  end
end
