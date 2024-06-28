require "rails_helper"

RSpec.describe HostingEnvironmentHelper do
  describe "#hosting_environment_color" do
    context "when the environment is production" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("production")
        expect(hosting_environment_color).to eq("blue")
      end
    end

    context "when the environment is qa" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("qa")
        expect(hosting_environment_color).to eq("orange")
      end
    end

    context "when the environment is staging" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
        expect(hosting_environment_color).to eq("red")
      end
    end

    context "when the environment is sandbox" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("sandbox")
        expect(hosting_environment_color).to eq("purple")
      end
    end

    context "when the environment is review" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("review")
        expect(hosting_environment_color).to eq("purple")
      end
    end

    context "when the environment is not recognised" do
      it "returns the correct color" do
        allow(HostingEnvironment).to receive(:env).and_return("unknown")
        expect(hosting_environment_color).to eq("grey")
      end
    end
  end

  describe "#hosting_environment_phase" do
    context "when the phase is qa" do
      it "returns the correct phase" do
        current_service = instance_double("current_service")
        allow(HostingEnvironment).to receive(:phase).with(current_service).and_return("qa")
        expect(hosting_environment_phase(current_service)).to eq("QA")
      end
    end

    context "when the phase is not qa" do
      it "returns the correct phase" do
        current_service = instance_double("current_service")
        allow(HostingEnvironment).to receive(:phase).with(current_service).and_return("production")
        expect(hosting_environment_phase(current_service)).to eq("Production")
      end
    end
  end
end
