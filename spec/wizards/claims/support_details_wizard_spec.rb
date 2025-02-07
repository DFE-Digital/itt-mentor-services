require "rails_helper"

RSpec.describe Claims::SupportDetailsWizard do
  subject(:wizard) { described_class.new(claim:, state:, params:, current_step:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:claim) { create(:claim) }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when the current step is zendesk" do
      let(:current_step) { :zendesk }

      it { is_expected.to contain_exactly(:zendesk) }
    end

    context "when the current step is support_user" do
      let(:current_step) { :support_user }

      it { is_expected.to contain_exactly(:support_user) }
    end
  end

  describe "#update_support_details" do
    subject(:update_support_details) { wizard.update_support_details }

    before { claim }

    context "when the step is zendesk" do
      let(:current_step) { :zendesk }
      let(:state) do
        {
          "zendesk" => { "zendesk_url" => "example.zendesk.com" },
        }
      end

      it "updates the zendesk url of the claim" do
        expect { update_support_details }.to change(claim, :zendesk_url).to("example.zendesk.com")
      end
    end

    context "when the step is support_user" do
      let(:support_user) { create(:claims_support_user) }
      let(:current_step) { :support_user }
      let(:state) do
        {
          "support_user" => { "support_user_id" => support_user.id },
        }
      end

      it "updates the zendesk url of the claim" do
        expect { update_support_details }.to change(claim, :support_user).to(support_user)
      end
    end
  end

  describe "#setup_state" do
    subject(:setup_state) { wizard.setup_state }

    let(:support_user) { create(:claims_support_user) }

    before do
      claim.update!(support_user:, zendesk_url: "example.zendesk.com")
    end

    context "when the step is zendesk" do
      let(:current_step) { :zendesk }

      it "returns a hash containing the zendesk attributes of the claim" do
        expect(wizard.setup_state).to eq(
          { "zendesk_url" => "example.zendesk.com" },
        )
      end
    end

    context "when the step is support user" do
      let(:current_step) { :support_user }

      it "returns a hash containing the zendesk attributes of the claim" do
        expect(wizard.setup_state).to eq(
          { "support_user_id" => support_user.id },
        )
      end
    end
  end

  describe "#success_message" do
    subject(:success_message) { wizard.success_message }

    context "when the step is zendesk" do
      let(:current_step) { :zendesk }

      it { is_expected.to eq("Link to Zendesk ticket added") }
    end

    context "when the step is support_user" do
      let(:current_step) { :support_user }

      it { is_expected.to eq("Support agent assigned") }
    end
  end
end
