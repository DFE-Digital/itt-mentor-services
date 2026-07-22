require "rails_helper"

RSpec.describe Claims::UserResearch::ProviderClaimsPrototype do
  subject(:prototype) { described_class.new }

  describe "#claims_for" do
    it "returns the claims for a known provider code" do
      claims = prototype.claims_for(" bpn01 ")

      expect(claims.map(&:id)).to include("proto-claim-9001", "proto-claim-9002", "proto-claim-9003")
    end

    it "returns an empty array for an unknown provider code" do
      expect(prototype.claims_for("unknown")).to eq([])
    end
  end

  describe "#find_claim" do
    it "returns the matching claim for a provider and id" do
      claim = prototype.find_claim(code: "BPN01", id: "proto-claim-9002")

      expect(claim).to have_attributes(id: "proto-claim-9002", reference: "90000002")
    end

    it "returns nil when the claim id does not exist" do
      claim = prototype.find_claim(code: "BPN01", id: "missing-id")

      expect(claim).to be_nil
    end
  end
end
