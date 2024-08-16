require "rails_helper"

RSpec.describe ProviderDecorator do
  describe "#partner_provider_placements" do
    it "returns placements belonging to a partner provider" do
      provider = create(:provider)
      subject = create(:subject)
      region = Region.create!(name: "Springfield")
      school = Placements::School.create!(
        name: "Springfield Elementary",
        urn: "1234567890",
        region:,
      )
      placement = Placement.create!(provider:, school:, subject:)

      decorated_provider = provider.decorate
      result = decorated_provider.partner_provider_placements(school)
      decorated_placement = placement.decorate

      expect(result).to include(decorated_placement)
    end
  end

  describe "#formatted_address" do
    it "returns a formatted address" do
      provider = create(:provider,
                        address1: "A School",
                        address2: "The School Road",
                        address3: "Somewhere",
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

    context "when attributes are missing" do
      it "returns a formatted address based on the present attributes" do
        provider = create(:provider,
                          address1: "A School",
                          address2: "The School Road",
                          address3: "Somewhere",
                          postcode: "LN12 1LN")
        expect(
          provider.decorate.formatted_address,
        ).to eq(
          "<p>A School\n<br />The School Road\n<br />Somewhere\n<br />LN12 1LN</p>",
        )
      end
    end

    context "when all address attributes are missing" do
      it "returns nil" do
        provider = create(:provider)
        expect(
          provider.decorate.formatted_address,
        ).to be_nil
      end
    end
  end
end
