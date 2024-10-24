require "rails_helper"

RSpec.describe Placements::ApplicationMailer, type: :mailer do
  describe "#service_name" do
    let(:body) { "service_name: \"Placements\"" }

    it "returns the placements service name" do
      expect(described_class.new.send(:service_name)).to eq("Manage school placements")
    end
  end

  describe "#support_email" do
    it "returns the placements support email" do
      expect(described_class.new.send(:support_email)).to eq("Manage.SchoolPlacements@education.gov.uk")
    end
  end

  describe "#host" do
    it "returns the PLACEMENTS_HOST" do
      expect(described_class.new.send(:host)).to eq("placements.localhost")
    end
  end
end
