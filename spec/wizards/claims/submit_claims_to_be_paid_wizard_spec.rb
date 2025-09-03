require "rails_helper"

RSpec.describe Claims::SubmitClaimsToBePaidWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil, current_user:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_user) { create(:claims_support_user) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no paid claims exist for the current academic year" do
      it { is_expected.to contain_exactly(:no_claims_to_pay) }
    end

    context "when submitted claims exist for the current academic year" do
      before { create(:claim, :submitted) }

      it { is_expected.to eq(%i[select_claim_window check_your_answers]) }
    end
  end

  describe "#pay_claims" do
    subject(:pay_claims) { wizard.pay_claims }

    let(:claim_window) { build(:claim_window, :current) }
    let(:claim_window_id) { claim_window.id }

    let(:submitted_claim) do
      create(:claim, :submitted, reference: 11_111_111, claim_window:)
    end

    let(:state) do
      {
        "select_claim_window" => {
          "claim_window" => claim_window_id,
        },
      }
    end

    before { submitted_claim }

    context "when the steps are valid" do
      it "the payments create and deliver service" do
        expect(Claims::Payment::CreateAndDeliver).to receive(:call).with(
          current_user:,
          claim_window:,
        )

        pay_claims
      end
    end

    context "when a step is invalid" do
      context "when the a step is invalid" do
        let(:claim_window_id) { nil }

        it "returns an invalid wizard error" do
          expect { pay_claims }.to raise_error("Invalid wizard state")
        end
      end
    end
  end
end
