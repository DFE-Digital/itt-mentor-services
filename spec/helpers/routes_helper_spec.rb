require "rails_helper"

describe RoutesHelper do
  describe "#root_path" do
    context "when the current service is claims" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.root_path).to eq(sign_in_path)
      end
    end

    context "when the current service is placements" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.root_path).to eq(placements_root_path)
      end
    end
  end

  describe "#support_root_path" do
    context "when the current service is claims" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.support_root_path).to eq(claims_support_root_path)
      end
    end

    context "when the current service is placements" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.support_root_path).to eq(placements_support_root_path)
      end
    end
  end

  describe "#support_organisations_path" do
    context "when the current service is claims" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.support_organisations_path).to eq(claims_support_schools_path)
      end
    end

    context "when the current service is placements" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.support_organisations_path).to eq(placements_support_organisations_path)
      end
    end
  end

  describe "#support_support_users_path" do
    context "when the current service is claims" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.support_support_users_path).to eq(claims_support_support_users_path)
      end
    end

    context "when the current service is placements" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.support_support_users_path).to eq(placements_support_support_users_path)
      end
    end
  end

  describe "#organisations_path" do
    context "when the current service is claims" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.organisations_path).to eq(claims_schools_path)
      end
    end

    context "when the current service is placements" do
      it "returns the correct path" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.organisations_path).to eq(placements_organisations_path)
      end
    end

    describe "#feedback_url" do
      context "when the current service is claims" do
        it "returns the correct url" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
          expect(helper.feedback_url).to eq("https://forms.office.com/e/0E3277Kqpi")
        end
      end

      context "when the current service is placements" do
        it "returns the correct url" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
          expect(helper.feedback_url).to eq(placements_feedback_url)
        end
      end
    end

    describe "#omniauth_sign_in_path" do
      it "returns the correct path" do
        expect(helper.omniauth_sign_in_path("dfe")).to eq("/auth/dfe")
      end
    end
  end
end
