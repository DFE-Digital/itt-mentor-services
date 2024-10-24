require "rails_helper"

RSpec.describe Claims::ApplicationMailer, type: :mailer do
  describe "#service_name" do
    it "returns the claims service name" do
      expect(described_class.new.send(:service_name)).to eq("Claim funding for mentor training")
    end
  end

  describe "#support_email" do
    it "returns the claims support email" do
      expect(described_class.new.send(:support_email)).to eq("ittmentor.funding@education.gov.uk")
    end
  end

  describe "#host" do
    it "returns the CLAIMS_HOST" do
      expect(described_class.new.send(:host)).to eq("claims.localhost")
    end
  end
end
