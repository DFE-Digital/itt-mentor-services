require "rails_helper"

RSpec.describe Claims::ChangeProviderWizard do
  subject(:wizard) { described_class.new(claim:, state:, params:, current_step:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:claim) { create(:claim, :submitted, provider: old_provider) }
  let(:old_provider) { create(:claims_provider, name: "Old Provider") }
  let(:new_provider) { create(:claims_provider, name: "New Provider") }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when a provider has not been selected" do
      it { is_expected.to eq(%i[provider provider_options check_your_answers]) }
    end

    context "when a provider has been selected" do
      let(:state) { { "provider" => { "id" => new_provider.id } } }

      it { is_expected.to eq(%i[provider check_your_answers]) }
    end
  end

  describe "#provider" do
    context "when the provider was selected from the provider step" do
      let(:state) { { "provider" => { "id" => new_provider.id } } }

      it "returns the provider" do
        expect(wizard.provider).to eq(new_provider)
      end
    end

    context "when the provider was selected from the provider options step" do
      let(:state) do
        {
          "provider" => { "id" => "New" },
          "provider_options" => { "id" => new_provider.id },
        }
      end

      it "returns the provider" do
        expect(wizard.provider).to eq(new_provider)
      end
    end
  end

  describe "validation" do
    context "when the selected provider is the claim's current provider" do
      let(:state) { { "provider" => { "id" => old_provider.id } } }

      it "is invalid" do
        expect(wizard.steps.fetch(:provider)).to be_invalid
        expect(wizard.steps.fetch(:provider).errors[:id]).to include("Select a different accredited provider")
      end
    end

    context "when none of the mentors on the claim have hours left with the selected provider" do
      let(:state) { { "provider" => { "id" => new_provider.id } } }

      before do
        mentor_training = create(:mentor_training, claim:, provider: old_provider, hours_completed: 10)
        claim_hours_with_new_provider(mentor_training.mentor, 20)
      end

      it "is invalid" do
        expect(wizard.steps.fetch(:provider)).to be_invalid
        expect(wizard.steps.fetch(:provider).errors[:id]).to include(
          "None of the mentors on this claim have hours left to claim with New Provider",
        )
      end
    end
  end

  describe "#removed_mentor_trainings and #reduced_mentor_trainings" do
    let(:state) { { "provider" => { "id" => new_provider.id } } }
    let!(:unaffected_training) { create(:mentor_training, claim:, provider: old_provider, hours_completed: 10) }
    let!(:reduced_training) { create(:mentor_training, claim:, provider: old_provider, hours_completed: 10) }
    let!(:removed_training) { create(:mentor_training, claim:, provider: old_provider, hours_completed: 10) }

    before do
      claim_hours_with_new_provider(reduced_training.mentor, 15)
      claim_hours_with_new_provider(removed_training.mentor, 20)
    end

    it "returns the mentor trainings that will be removed from the claim" do
      expect(wizard.removed_mentor_trainings).to contain_exactly(removed_training)
    end

    it "returns the mentor trainings that will have their hours reduced, with the new hours" do
      expect(wizard.reduced_mentor_trainings).to eq(reduced_training => 5)
    end

    it "does not include mentor trainings that are unaffected" do
      expect(wizard.removed_mentor_trainings).not_to include(unaffected_training)
      expect(wizard.reduced_mentor_trainings).not_to have_key(unaffected_training)
    end
  end

  describe "#change_provider" do
    context "when the wizard is valid" do
      let(:state) { { "provider" => { "id" => new_provider.id } } }

      it "changes the provider of the claim" do
        expect { wizard.change_provider }.to change { claim.reload.provider }.from(old_provider).to(new_provider)
      end
    end

    context "when the wizard is invalid" do
      it "raises an error" do
        expect { wizard.change_provider }.to raise_error("Invalid wizard state")
      end
    end
  end

  def claim_hours_with_new_provider(mentor, hours_completed)
    other_claim = create(:claim, :submitted, provider: new_provider)
    create(:mentor_training, claim: other_claim, mentor:, provider: new_provider, hours_completed:)
  end
end
