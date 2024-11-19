require "rails_helper"

RSpec.describe Claims::AddClaimWizard do
  subject(:wizard) { described_class.new(school:, created_by:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:claims_school) }
  let(:created_by) { create(:claims_user, schools: [school]) }
  let(:provider) { create(:claims_provider, :niot) }
  let(:claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }

  before { claim_window }

  describe "#steps" do
    subject { wizard.steps.keys }

    let(:state) do
      {
        "provider" => { "id" => provider.id },
      }
    end

    context "when the school has no mentors" do
      it { is_expected.to eq %i[provider no_mentors] }
    end

    context "when the school has mentors" do
      let(:mentor) { create(:claims_mentor, schools: [school]) }

      before { mentor }

      context "with claimable hours" do
        it { is_expected.to eq %i[provider mentor check_your_answers] }
      end

      context "when mentors have been selected" do
        let(:state) do
          {
            "provider" => { "id" => provider.id },
            "mentor" => { "mentor_ids" => [mentor.id] },
          }
        end

        it { is_expected.to eq [:provider, :mentor, "mentor_training_#{mentor.id}".to_sym, :check_your_answers] }
      end

      context "with no claimable hours" do
        before do
          create(:mentor_training,
                 hours_completed: 20,
                 mentor:,
                 provider:,
                 date_completed: claim_window.starts_on + 1.day,
                 claim: create(:claim, :submitted, school:, provider:))
        end

        it { is_expected.to eq %i[provider no_mentors] }
      end
    end
  end

  describe "#add_step" do
    # this methods behaves just as it does in the BaseWizard,
    # unless preset attributes are given.
    context "when preset attribute 'mentor_id' is given" do
      let(:mentor_id) { "abcd" }

      it "adds a step, with the 'mentor_id' step name and attributes" do
        wizard.add_step(Claims::AddClaimWizard::MentorTrainingStep, { mentor_id: })
        expect(wizard.steps).to include(:mentor_training_abcd)
        expect(wizard.steps[:mentor_training_abcd]).to be_a(Claims::AddClaimWizard::MentorTrainingStep)
        expect(wizard.steps[:mentor_training_abcd]).to have_attributes(mentor_id:)
      end
    end
  end

  describe "#academic_year" do
    before { claim_window }

    it "returns the academic year of the current claim window" do
      expect(wizard.academic_year).to eq(claim_window.academic_year)
    end
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
          "mentor_id" => mentor_1.id, "hours_completed" => 20
        },
        "mentor_training_#{mentor_2.id}" => {
          "mentor_id" => mentor_2.id, "hours_completed" => 20
        },
        "mentor_training_#{mentor_3.id}" => {
          "mentor_id" => mentor_3.id, "hours_completed" => "custom", "custom_hours_completed" => 16
        },
        "mentor_training_#{mentor_4.id}" => {
          "mentor_id" => mentor_4.id, "hours_completed" => "custom", "custom_hours_completed" => 4
        },
      }
    end

    it "return the sum of the hours completed and custom hours completed" do
      expect(wizard.total_hours).to eq(60)
    end
  end

  describe "#claim" do
    let(:mentor_1) { create(:claims_mentor, schools: [school]) }
    let(:mentor_2) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor_1.id, mentor_2.id] },
        "mentor_training_#{mentor_1.id}" => {
          "mentor_id" => mentor_1.id, "hours_completed" => 20
        },
        "mentor_training_#{mentor_2.id}" => {
          "mentor_id" => mentor_2.id, "hours_completed" => "custom", "custom_hours_completed" => 16
        },
      }
    end

    it "initialises a new claim, build from the step attributes" do
      claim = wizard.claim
      expect(claim.new_record?).to be(true)
      expect(claim).to be_a(Claims::Claim)
      expect(claim.provider).to eq(provider)
      expect(claim.school).to eq(school)
      expect(claim.created_by).to eq(created_by)
    end

    it "initialises new mentor trainings for the claim, per mentor set in the step attributes" do
      claim = wizard.claim
      expect(claim.mentor_trainings.size).to eq(2)
      expect(claim.mentor_trainings.map(&:mentor)).to contain_exactly(mentor_1, mentor_2)
      expect(claim.mentor_trainings.map(&:hours_completed)).to contain_exactly(20, 16)
    end
  end

  describe "#create_claim" do
    subject(:create_claim) { wizard.create_claim }

    let(:mentor_1) { create(:claims_mentor, schools: [school], first_name: "Alan", last_name: "Anderson") }
    let(:mentor_2) { create(:claims_mentor, schools: [school], first_name: "Bob", last_name: "Bletcher") }

    let(:state) do
      {
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor_1.id, mentor_2.id] },
        "mentor_training_#{mentor_1.id}" => {
          "mentor_id" => mentor_1.id, "hours_completed" => 20
        },
        "mentor_training_#{mentor_2.id}" => {
          "mentor_id" => mentor_2.id, "hours_completed" => "custom", "custom_hours_completed" => 16
        },
      }
    end

    context "when the mentors still have available training hours with the provider" do
      context "when the created by user, is not a support user" do
        it "creates a submitted claim" do
          expect { create_claim }.to change(Claims::Claim, :count).by(1)
            .and change(Claims::MentorTraining, :count).by(2)

          claim = wizard.claim

          expect(claim).to be_persisted
          expect(claim.school).to eq(school)
          expect(claim.provider).to eq(provider)
          expect(claim.created_by).to eq(created_by)
          expect(claim.status).to eq("submitted")
          expect(claim.claim_window).to eq(claim_window)
          expect(claim.mentors.order_by_full_name).to contain_exactly(mentor_1, mentor_2)

          mentor_1_training = claim.mentor_trainings.find_by(mentor_id: mentor_1)
          expect(mentor_1_training.hours_completed).to eq(20)
          expect(mentor_1_training.provider).to eq(provider)

          mentor_2_training = claim.mentor_trainings.find_by(mentor_id: mentor_2)
          expect(mentor_2_training.hours_completed).to eq(16)
          expect(mentor_2_training.provider).to eq(provider)
        end
      end

      context "when the created by user, is a support user" do
        let(:created_by) { create(:claims_support_user) }

        it "creates a draft claim" do
          expect { create_claim }.to change(Claims::Claim, :count).by(1)
            .and change(Claims::MentorTraining, :count).by(2)

          claim = wizard.claim

          expect(claim).to be_persisted
          expect(claim.school).to eq(school)
          expect(claim.provider).to eq(provider)
          expect(claim.created_by).to eq(created_by)
          expect(claim.status).to eq("draft")
          expect(claim.claim_window).to eq(claim_window)
          expect(claim.mentors.order_by_full_name).to contain_exactly(mentor_1, mentor_2)

          mentor_1_training = claim.mentor_trainings.find_by(mentor_id: mentor_1)
          expect(mentor_1_training.hours_completed).to eq(20)
          expect(mentor_1_training.provider).to eq(provider)

          mentor_2_training = claim.mentor_trainings.find_by(mentor_id: mentor_2)
          expect(mentor_2_training.hours_completed).to eq(16)
          expect(mentor_2_training.provider).to eq(provider)
        end
      end
    end
  end

  describe "#mentors_with_claimable_hours" do
    subject(:mentors_with_claimable_hours) { wizard.mentors_with_claimable_hours }

    context "when a provider is not provided" do
      it "returns no mentors" do
        expect(mentors_with_claimable_hours).to eq([])
      end
    end

    context "when a provider is provided" do
      let(:mentor_1) { create(:claims_mentor, schools: [school]) }
      let!(:mentor_2) { create(:claims_mentor, schools: [school]) }
      let(:state) do
        {
          "provider" => { "id" => provider.id },
        }
      end

      before do
        existing_claim = create(:claim, :submitted, provider:, school:, claim_window:)
        create(:mentor_training,
               claim: existing_claim,
               hours_completed: 20,
               mentor: mentor_1,
               provider:,
               date_completed: claim_window.starts_on)
      end

      it "returns all mentors with available hours with the provider" do
        expect(mentors_with_claimable_hours).to contain_exactly(mentor_2)
      end
    end
  end

  describe "#provider" do
    let(:state) do
      {
        "provider" => { "id" => provider.id },
      }
    end

    it "returns the provider given by the provider step" do
      expect(wizard.provider).to eq(provider)
    end
  end
end
