require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::Interested::SecondaryChildSubjectPlacementSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard:, attributes: {}) }

  let(:wizard) { instance_double(Placements::AddHostingInterestWizard) }

  describe "#unknown_option" do
    it "offers an unknown selection for interested schools" do
      expect(step.unknown_option.value).to eq("unknown")
      expect(step.unknown_option.name).to eq("Not sure yet")
    end
  end
end
