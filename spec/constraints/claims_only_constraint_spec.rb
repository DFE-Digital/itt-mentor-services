require "rails_helper"

RSpec.describe ClaimsOnlyConstraint do
  describe ".matches?" do
    context "when current service is claims" do
      it "returns true" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(described_class.new.matches?({})).to be(true)
      end
    end

    context "when the current service is placements" do
      it "returns false" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(described_class.new.matches?({})).to be(false)
      end
    end
  end
end
