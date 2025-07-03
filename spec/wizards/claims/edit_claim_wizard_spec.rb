require "rails_helper"

RSpec.describe Claims::EditClaimWizard do
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

  describe "#steps" do
    subject { wizard.steps.keys }

    let(:state) do
      {
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor_1.id] },
        "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
      }
    end

    it { is_expected.to eq [:provider, :mentor, "mentor_training_#{mentor_1.id}".to_sym, :check_your_answers] }

    context "when current step is declaration" do
      let(:current_step) { :declaration }

      it { is_expected.to eq [:declaration] }
    end

    context "when the provider 'id' is set in the provider options step" do
      let(:state) do
        {
          "provider" => { "id" => provider.name },
          "provider_options" => { "id" => provider.id, "search_param" => provider.name },
          "mentor" => { "mentor_ids" => [mentor_1.id] },
          "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
        }
      end

      it { is_expected.to eq [:provider, :provider_options, :mentor, "mentor_training_#{mentor_1.id}".to_sym, :check_your_answers] }
    end

    context "when there are no mentors with claimable hours for the given provider" do
      let(:another_provider) { create(:claims_provider, :best_practice_network) }
      let(:another_claim) do
        create(
          :claim,
          :submitted,
          school:,
          reference: "12345677",
          provider: another_provider,
          created_by:,
          reviewed: true,
          claim_window:,
        )
      end
      let(:another_mentor_training) do
        create(
          :mentor_training,
          claim: another_claim,
          mentor: mentor_1,
          provider: another_provider,
          hours_completed: 20,
          date_completed: claim_window.starts_on + 1.day,
        )
      end

      let(:state) do
        {
          "provider" => { "id" => another_provider.id },
          "mentor" => { "mentor_ids" => [mentor_1.id] },
          "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
        }
      end

      before { another_mentor_training }

      it { is_expected.to eq %i[provider no_mentors] }
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:academic_year).to(:claim) }
    it { is_expected.to delegate_method(:claim_window).to(:claim) }
    it { is_expected.to delegate_method(:reference).to(:claim).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:school).with_prefix(true) }
    it { is_expected.to delegate_method(:region_funding_available_per_hour).to(:school).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:academic_year).with_prefix(true) }
  end

  describe "#total_hours" do
    let(:mentor_1) { create(:claims_mentor, schools: [school]) }
    let(:mentor_2) { create(:claims_mentor, schools: [school]) }
    let(:mentor_3) { create(:claims_mentor, schools: [school]) }
    let(:mentor_4) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor_1.id, mentor_2.id, mentor_3.id, mentor_4.id] },
        "mentor_training_#{mentor_1.id}" => {
          "mentor_id" => mentor_1.id, "hours_to_claim" => "maximum"
        },
        "mentor_training_#{mentor_2.id}" => {
          "mentor_id" => mentor_2.id, "hours_to_claim" => "maximum"
        },
        "mentor_training_#{mentor_3.id}" => {
          "mentor_id" => mentor_3.id, "hours_to_claim" => "custom", "custom_hours" => 16
        },
        "mentor_training_#{mentor_4.id}" => {
          "mentor_id" => mentor_4.id, "hours_to_claim" => "custom", "custom_hours" => 4
        },
      }
    end

    it "return the sum of the hours completed and custom hours completed" do
      expect(wizard.total_hours).to eq(60)
    end
  end

  describe "#selected_mentors" do
    subject(:selected_mentors) { wizard.selected_mentors }

    context "when the mentor step is not given" do
      let(:state) do
        {
          "provider" => { "id" => provider.id },
        }
      end

      it "returns the mentors assigned to the claim" do
        expect(selected_mentors).to contain_exactly(mentor_1.becomes(Mentor))
      end
    end

    context "when the mentor step is given" do
      let(:another_mentor) { create(:claims_mentor, schools: [school], first_name: "Bob", last_name: "Bletcher") }
      let(:state) do
        {
          "provider" => { "id" => provider.id },
          "mentor" => { "mentor_ids" => [mentor_1.id, another_mentor.id] },
        }
      end

      it "return the mentors selected in the mentor step" do
        expect(selected_mentors).to contain_exactly(mentor_1, another_mentor)
      end
    end
  end

  describe "#update_claim" do
    subject(:update_claim) { wizard.update_claim }

    let(:state) do
      {
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor_1.id] },
        "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
      }
    end

    context "when the created by user, is not a support user" do
      it "submits the draft claim" do
        expect { update_claim }.to change(claim, :status).from("draft").to("submitted")
      end
    end

    context "when the created by user, is a support user" do
      let(:created_by) { create(:claims_support_user) }

      it "does not submit the draft claim" do
        expect { update_claim }.not_to change(claim, :status).from("draft")
      end
    end

    context "when the provider is changed in the provider step" do
      let(:another_provider) { create(:claims_provider, :best_practice_network) }
      let(:state) do
        {
          "provider" => { "id" => another_provider.id },
          "mentor" => { "mentor_ids" => [mentor_1.id] },
          "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
        }
      end

      it "updates the claim's provider to the one set in the provider step" do
        expect { update_claim }.to change(claim, :provider).from(provider).to(another_provider)

        claim.reload
        mentor_1_training = claim.mentor_trainings.find_by(mentor_id: mentor_1)
        expect(mentor_1_training.provider).to eq(another_provider)
      end
    end

    context "when the mentors and training hours are changed" do
      let(:another_mentor) { create(:claims_mentor, schools: [school], first_name: "Bob", last_name: "Bletcher").becomes(Mentor) }
      let(:state) do
        {
          "provider" => { "id" => provider.id },
          "mentor" => { "mentor_ids" => [mentor_1.id, another_mentor.id] },
          "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 12 },
          "mentor_training_#{another_mentor.id}" => { mentor_id: another_mentor.id, hours_to_claim: "maximum" },
        }
      end

      it "updates the claim with the selected mentors and training hours" do
        update_claim
        claim.reload
        expect(claim.mentors).to contain_exactly(mentor_1.becomes(Mentor), another_mentor)

        mentor_1_training = claim.mentor_trainings.find_by(mentor_id: mentor_1)
        expect(mentor_1_training.hours_completed).to eq(12)

        another_mentor_training = claim.mentor_trainings.find_by(mentor_id: another_mentor)
        expect(another_mentor_training.hours_completed).to eq(20)
      end
    end
  end

  describe "#setup_state" do
    subject(:setup_state) { wizard.setup_state }

    it "sets the state to values related to the claim" do
      expect { setup_state }.to change(wizard, :state).to(
        {
          "provider" => { "id" => provider.id },
          "mentor" => { "mentor_ids" => [mentor_1.id] },
          "mentor_training_#{mentor_1.id}" => { mentor_id: mentor_1.id, hours_to_claim: "custom", custom_hours: 6 },
        },
      )
    end
  end

  describe "#provider" do
    context "when the provider isn't set in the provider step" do
      it "returns the provider assigned to the claim" do
        expect(wizard.provider).to eq(provider)
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

    context "when the provider is set in the provider options step" do
      let(:another_provider) { create(:claims_provider, :niot) }

      let(:state) do
        {
          "provider" => { "id" => another_provider.name },
          "provider_options" => { "id" => another_provider.id, "search_param" => another_provider.name },
        }
      end

      it "returns the provider assigned to the provider options step" do
        expect(wizard.provider).to eq(another_provider)
      end
    end
  end

  describe "#claim_to_exclude" do
    subject(:claim_to_exclude) { wizard.claim_to_exclude }

    it { is_expected.to eq(claim) }
  end

  describe "#mentors_with_claimable_hours" do
    subject(:mentors_with_claimable_hours) { wizard.mentors_with_claimable_hours }

    context "when a provider is provided" do
      let(:mentor_1) { create(:claims_mentor, schools: [school]) }
      let!(:mentor_2) { create(:claims_mentor, schools: [school]) }
      let(:another_provider) { create(:claims_provider, :niot) }
      let(:state) do
        {
          "provider" => { "id" => another_provider.id },
        }
      end

      before do
        existing_claim = create(:claim, :submitted, provider: another_provider, school:, claim_window:)
        create(:mentor_training,
               claim: existing_claim,
               hours_completed: 20,
               mentor: mentor_1,
               provider: another_provider,
               date_completed: claim_window.starts_on)
      end

      it "returns all mentors with available hours with the provider" do
        expect(mentors_with_claimable_hours).to contain_exactly(mentor_2)
      end
    end
  end
end
