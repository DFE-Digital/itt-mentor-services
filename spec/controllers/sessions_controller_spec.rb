require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "#claims_patricia_persona?" do
    subject(:claims_patricia_persona?) { controller.send(:claims_patricia_persona?) }

    let(:current_service) { :claims }
    let(:current_user) { build_stubbed(:claims_user, first_name: "Patricia") }

    before do
      allow(controller).to receive(:current_service).and_return(current_service)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it "returns true for Patricia in claims service" do
      expect(claims_patricia_persona?).to be(true)
    end

    context "when user is not Patricia" do
      let(:current_user) { build_stubbed(:claims_user, first_name: "Alex") }

      it "returns false" do
        expect(claims_patricia_persona?).to be(false)
      end
    end

    context "when service is not claims" do
      let(:current_service) { :placements }

      it "returns false" do
        expect(claims_patricia_persona?).to be(false)
      end
    end
  end
end
