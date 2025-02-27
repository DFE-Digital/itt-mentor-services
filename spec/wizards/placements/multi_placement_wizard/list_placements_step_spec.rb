require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::ListPlacementsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(list_placements: nil) }
  end

  describe "validations" do
    it {
      expect(step).to validate_inclusion_of(:list_placements).in_array(
        Placements::MultiPlacementWizard::ListPlacementsStep::LIST_PLACEMENTS,
      )
    }
  end

  describe "#responses_for_selection" do
    subject(:responses_for_selection) { step.responses_for_selection }

    it "returns struct objects for each response" do
      yes = responses_for_selection[0]
      no = responses_for_selection[1]

      expect(yes.name).to eq("Yes")
      expect(no.name).to eq("No")
    end
  end
end
