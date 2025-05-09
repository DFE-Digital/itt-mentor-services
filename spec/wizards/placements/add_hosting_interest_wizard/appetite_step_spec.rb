require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::AppetiteStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(appetite: nil) }
  end

  describe "validations" do
    let(:appetites) { %w[actively_looking interested not_open] }

    it {
      expect(step).to validate_inclusion_of(:appetite).in_array(
        appetites,
      )
    }
  end

  describe "#appetite_options" do
    subject(:appetite_options) { step.appetite_options }

    it "returns struct objects for each appetite" do
      actively_looking = appetite_options[0]
      interested = appetite_options[1]
      not_open = appetite_options[2]
      # already_organised = appetite_options[3] # Remove for concept testing

      expect(actively_looking.value).to eq("actively_looking")
      expect(actively_looking.name).to eq("Yes - I can offer placements")
      expect(actively_looking.description).to eq(
        "Share the placements you can offer",
      )

      expect(interested.value).to eq("interested")
      expect(interested.name).to eq("Maybe - I’m not sure yet")
      expect(interested.description).to eq(
        "Share what you can potentially offer",
      )

      expect(not_open.value).to eq("not_open")
      expect(not_open.name).to eq("No - I can’t offer placements")
      expect(not_open.description).to eq(
        "Tell us why you cannot offer placements",
      )
    end
  end

  describe "#placement_appetites" do
    subject(:placement_appetites) { step.placement_appetites }

    let(:appetites) { %w[actively_looking interested not_open] }

    it "returns the keys of the appetites" do
      expect(placement_appetites).to match_array(appetites)
    end
  end
end
