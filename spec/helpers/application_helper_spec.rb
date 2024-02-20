require "rails_helper"

RSpec.describe ApplicationHelper do
  describe ".external_link" do
    context "when value is blank" do
      it "returns nil" do
        value = ""
        expect(external_link(value)).to eq(nil)
      end
    end

    context "when value does not have a protocol" do
      it "returns just the correct url" do
        value = "www.google.com"
        expect(external_link(value)).to eq("http://www.google.com")
      end
    end

    context "when value already has http" do
      it "returns just the correct url" do
        value = "http://www.google.com"
        expect(external_link(value)).to eq("http://www.google.com")
      end
    end

    context "when value already has https" do
      it "returns just the correct url" do
        value = "https://www.google.com"
        expect(external_link(value)).to eq("https://www.google.com")
      end
    end
  end

  describe ".current_service" do
    it "delegates to HostingEnvironment.current_service" do
      allow(HostingEnvironment).to receive(:current_service)
                                   .with(kind_of(ActionDispatch::Request))
                                   .and_return(:pineapple)

      expect(current_service).to eq(:pineapple)
    end
  end
end
