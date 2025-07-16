require "rails_helper"

RSpec.describe Claims::InvalidProviderWizard do
  subject(:wizard) { described_class.new(school:, claim:, created_by:, state:, params:, current_step:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:current_step) { nil }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { build(:claims_school) }
  let(:created_by) { build(:claims_user, schools: [school]) }
  let(:provider) { build(:claims_provider, :niot) }
  let(:mentor_1) { build(:claims_mentor, schools: [school], first_name: "Alan", last_name: "Anderson") }
  let(:claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }
  let!(:claim) do
    create(
      :claim,
      :draft,
      school:,
      reference: "12345678",
      provider:,
      created_by:,
      reviewed: true,
      claim_window:,
    )
  end
  let(:mentor_1_training) do
    create(
      :mentor_training,
      claim:,
      mentor: mentor_1,
      provider:,
      hours_completed: 6,
      date_completed: claim_window.starts_on + 1.day,
    )
  end

  before { mentor_1_training }

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true) }
  end

  describe "#update_claim" do
    subject(:update_claim) { wizard.update_claim }

    let(:state) do
      {
        "provider" => { "id" => provider.id },
      }
    end

    context "when the provider is changed" do
      let(:another_provider) { create(:claims_provider, :best_practice_network) }
      let(:state) do
        {
          "provider" => { "id" => another_provider.id },
        }
      end

      it "updates the claim's provider to the one set in the provider step" do
        expect { update_claim }.to change(claim, :provider).from(provider).to(another_provider)

        claim.reload
        mentor_1_training = claim.mentor_trainings.find_by(mentor_id: mentor_1)
        expect(mentor_1_training.provider).to eq(another_provider)
      end
    end
  end

  describe "#provider" do
    context "when the provider isn't set in the provider step" do
      it "returns nil as the provider is invalid" do
        expect(wizard.provider).to be_nil
      end
    end

    context "when the provider is set in the provider step" do
      let(:another_provider) { create(:claims_provider, :niot) }
      let(:state) do
        {
          "provider" => { "id" => another_provider.id },
        }
      end

      it "returns the provider assigned to the provider step" do
        expect(wizard.provider).to eq(another_provider)
      end
    end
  end
end
