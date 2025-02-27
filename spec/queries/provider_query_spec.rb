require "rails_helper"

describe ProviderQuery do
  subject(:provider_query) { described_class.call(params:) }

  let(:params) { {} }
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

  before do
    provider_1
    provider_2
    provider_3
  end

  describe "#call" do
    it "returns the providers by the provider name" do
      expect(provider_query).to eq([provider_1, provider_2, provider_3])
    end

    context "when given location coordinates" do
      let(:params) { { location_coordinates: [51.1844248, -0.580242] } }

      it "returns the providers within 50 miles of the given coordinates,
        ordered by their proximity to the location coordinates" do
        expect(provider_query).to eq([provider_2, provider_1])
      end
    end
  end
end
