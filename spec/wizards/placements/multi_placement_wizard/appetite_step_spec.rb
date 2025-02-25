require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::AppetiteStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(appetite: nil) }
  end

  describe "validations" do
    it {
      expect(step).to validate_inclusion_of(:appetite).in_array(
        Placements::HostingInterest.appetites.keys,
      )
    }
  end

  describe "#appetite_options" do
    subject(:appetite_options) { step.appetite_options }

    it "returns struct objects for each appetite" do
      actively_looking = appetite_options[0]
      interested = appetite_options[1]
      not_open = appetite_options[2]
      already_organised = appetite_options[3]

      expect(actively_looking.value).to eq("actively_looking")
      expect(actively_looking.name).to eq("Actively looking to host placements")
      expect(actively_looking.description).to eq(
        "You'll have to the option to specify what you'd like to host in the next step",
      )

      expect(interested.value).to eq("interested")
      expect(interested.name).to eq("Interested in hosting placements")
      expect(interested.description).to eq(
        "Providers will be able to contact you and discuss",
      )

      expect(not_open.value).to eq("not_open")
      expect(not_open.name).to eq("Not open to hosting placements")
      expect(not_open.description).to eq(
        "Providers will not be able to contact you using this service this academic year",
      )

      expect(already_organised.value).to eq("already_organised")
      expect(already_organised.name).to eq("Placements already organised with providers")
      expect(already_organised.description).to eq(
        "We'll show any providers who search for you that you're at capacity",
      )
    end
  end

  describe "#placement_appetites" do
    subject(:placement_appetites) { step.placement_appetites }

    it "returns the keys of the appetites" do
      expect(placement_appetites).to match_array(Placements::HostingInterest.appetites.keys)
    end
  end
end
