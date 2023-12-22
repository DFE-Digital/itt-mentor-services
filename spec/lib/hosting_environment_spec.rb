require "rails_helper"

RSpec.describe HostingEnvironment do
  describe ".name" do
    it "returns the name of the hosting environment" do
      current_service = "claims"
      expect(described_class.name(current_service)).to eq("test")
    end

    context "when environment is production" do
      it "returns the name of the hosting environment for claims" do
        allow(Rails.env).to receive(:production?).and_return(true)
        current_service = "claims"
        expect(described_class.name(current_service)).to eq("beta")
      end

      it "returns the name of the hosting environment for placements" do
        allow(Rails.env).to receive(:production?).and_return(true)
        current_service = "placements"
        expect(described_class.name(current_service)).to eq("beta")
      end
    end
  end

  describe ".banner_description" do
    it "returns the banner description of the hosting environment for claims" do
      current_service = "claims"
      expect(described_class.banner_description(current_service)).to eq(
        "Make a complaint or give feedback",
      )
    end

    it "returns the banner description of the hosting environment for placements" do
      current_service = "placements"
      expect(described_class.banner_description(current_service)).to eq(
        "Make a complaint or give feedback",
      )
    end
  end
end
