require "rails_helper"

RSpec.describe Claims::Providers::ApplicationController, type: :controller do
  describe "#authorize_user!" do
    subject(:authorize_user!) { controller.send(:authorize_user!) }

    before do
      allow(controller).to receive(:sign_in_path).and_return("/sign-in")
      allow(controller).to receive(:t).with("you_cannot_perform_this_action").and_return("You cannot perform this action")
    end

    context "when current_user is a support user" do
      before do
        allow(controller).to receive(:current_user).and_return(create(:claims_support_user))
      end

      it "does not redirect" do
        expect(controller).not_to receive(:redirect_to)

        authorize_user!
      end
    end

    context "when current_user is a provider user" do
      before do
        allow(controller).to receive(:current_user).and_return(create(:claims_provider_user))
      end

      it "does not redirect" do
        expect(controller).not_to receive(:redirect_to)

        authorize_user!
      end
    end

    context "when current_user is neither a support user nor a provider user" do
      before do
        allow(controller).to receive(:current_user).and_return(create(:claims_user))
      end

      it "redirects to sign in with an error flash" do
        expect(controller).to receive(:redirect_to).with(
          "/sign-in",
          flash: {
            heading: "You cannot perform this action",
            success: false,
          },
        )

        authorize_user!
      end
    end
  end

  describe "#set_provider" do
    subject(:set_provider) { controller.send(:set_provider) }

    let(:provider) { create(:claims_provider) }

    before do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(provider_id: provider.id))
      allow(controller).to receive(:policy_scope).with(Claims::Provider).and_return(Claims::Provider)
    end

    it "sets @provider using the policy scope and provider_id param" do
      set_provider

      expect(controller.instance_variable_get(:@provider)).to eq(provider)
    end
  end
end
