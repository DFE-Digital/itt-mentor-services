require "rails_helper"

RSpec.describe ProviderDecorator do
  describe "#formatted_address" do
    it "returns a formatted address" do
      provider = create(:provider,
                        street_address_1: "A School",
                        street_address_2: "The School Road",
                        street_address_3: "Somewhere",
                        town: "London",
                        city: "City of London",
                        county: "London",
                        postcode: "LN12 1LN")

      expect(
        provider.decorate.formatted_address,
      ).to eq(
        "<p>A School\n<br />The School Road\n<br />Somewhere\n<br />London\n<br />City of London\n<br />London\n<br />LN12 1LN</p>",
      )
    end
  end
end
