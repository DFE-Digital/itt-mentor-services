require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::HelpStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school, latitude: 51.1844248, longitude: -0.580242) }

  describe "delegations" do
    it { is_expected.to delegate_method(:school).to(:wizard) }
  end

  describe "#local_providers" do
    subject(:local_providers) { step.local_providers }

    let(:provider_1) do
      create(:provider,
             name: "Ashford Provider",
             latitude: 51.240551,
             longitude: -0.580243)
    end
    let(:provider_2) do
      create(:provider,
             name: "Bath Provider",
             latitude: 51.1844249,
             longitude: -0.617529)
    end
    let(:provider_3) do
      create(:provider,
             name: "Coventry Provider",
             latitude: 53.68806439999999,
             longitude: -1.853286)
    end
    let(:provider_4) do
      create(:provider,
             name: "Woking Provider",
             latitude: 51.240554,
             longitude: -0.617530)
    end

    before do
      provider_1
      provider_2
      provider_3
      provider_4
    end

    it "returns the 2 closest providers to the school's location" do
      expect(local_providers).to eq([provider_2.decorate, provider_1.decorate])
    end
  end
end
