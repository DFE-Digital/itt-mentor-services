require "rails_helper"

RSpec.describe Claims::AddOrganisationWizard::RegionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddOrganisationWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(region_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:region_id) }
  end

  describe "#regions" do
    it "returns all regions" do
      expect(step.regions).to match_array(Region.all)
    end
  end
end
