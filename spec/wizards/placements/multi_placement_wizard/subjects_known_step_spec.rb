require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::SubjectsKnownStep, type: :model do
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
    it { is_expected.to have_attributes(subjects_known: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:subjects_known).in_array(%w[Yes No]) }
  end

  describe "#responses_for_selection" do
    subject(:responses_for_selection) { step.responses_for_selection }

    it "returns open struct objects for the options Yes and No" do
      expect(responses_for_selection).to eq(
        [
          OpenStruct.new(name: "Yes"),
          OpenStruct.new(name: "No"),
        ],
      )
    end
  end
end
