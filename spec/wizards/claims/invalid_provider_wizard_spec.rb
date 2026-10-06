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

  describe "#academic_year" do
    it "is the academic year of the current claim window" do
      expect(wizard.academic_year).to eq(Claims::ClaimWindow.current.academic_year)
    end

    context "when there is no current claim window" do
      before { allow(Claims::ClaimWindow).to receive(:current).and_return(nil) }

      it "is the academic year of the claim" do
        expect(wizard.academic_year).to eq(claim.claim_window.academic_year)
      end
    end
  end

  describe "provider selection" do
    let(:state) { { "provider" => { "id" => selected_provider.id } } }
    let(:selected_provider) { eligible_provider }
    let(:eligible_provider) { create(:claims_provider, :best_practice_network, accredited: false) }
    let(:ineligible_provider) { create(:claims_provider, name: "Ineligible provider", accredited: true) }

    before do
      Claims::ProviderEligibility.create!(provider: eligible_provider, academic_year: Claims::ClaimWindow.current.academic_year)
      ineligible_provider.eligibilities.destroy_all
    end

    it "accepts a provider that is eligible for the academic year, even if it is not accredited" do
      expect(wizard.steps.fetch(:provider).provider).to eq(eligible_provider)
    end

    context "when the provider is accredited but not eligible for the academic year" do
      let(:selected_provider) { ineligible_provider }

      it "does not accept the provider" do
        expect(wizard.steps.fetch(:provider).provider).to be_nil
      end
    end

    it "uses the academic year in the provider suggestions path" do
      expect(wizard.steps.fetch(:provider).autocomplete_path_value).to eq("/api/academic_years/#{wizard.academic_year.id}/provider_suggestions")
    end
  end

  describe "#steps" do
    subject { wizard.steps.keys }

    let(:another_provider) { create(:claims_provider, :best_practice_network) }
    let(:state) { { "provider" => { "id" => another_provider.id } } }

    context "when the provider selected has not been claimed for with the maximum training hours" do
      it { is_expected.to eq(%i[provider]) }
    end

    context "when the provider selected has already been claimed for with the maximum training hours" do
      before do
        another_claim = create(
          :claim,
          :submitted,
          school:,
          reference: "12345679",
          provider: another_provider,
          created_by:,
          reviewed: true,
          claim_window:,
        )
        create(
          :mentor_training,
          claim: another_claim,
          mentor: mentor_1,
          provider: another_provider,
          hours_completed: 20,
          date_completed: claim_window.starts_on + 1.day,
        )
      end

      it { is_expected.to eq(%i[provider unable_to_assign_provider]) }
    end
  end

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
