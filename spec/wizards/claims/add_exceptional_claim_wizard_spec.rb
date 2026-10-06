require "rails_helper"

RSpec.describe Claims::AddExceptionalClaimWizard do
  subject(:wizard) { described_class.new(created_by:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params) { ActionController::Parameters.new({}) }
  let(:created_by) { create(:claims_support_user) }
  let(:claim_window) { create(:claim_window, :historic) }
  let(:school) { create(:claims_school, eligibilities: [build(:eligibility, claim_window:)]) }
  let(:other_academic_year) { AcademicYear.for_date(claim_window.academic_year.ends_on + 1.day) }
  let(:provider) do
    create(:claims_provider, accredited: false).tap do |provider|
      Claims::ProviderEligibility.create!(provider:, academic_year: claim_window.academic_year)
    end
  end

  before { Claims::ClaimWindow.current || create(:claim_window, :current) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no answers have been given" do
      it { is_expected.to eq %i[exceptional_circumstances claim_window school school_options provider provider_options no_mentors] }
    end

    context "when the school and provider have been selected but the school has no mentors" do
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      it { is_expected.to eq %i[exceptional_circumstances claim_window school provider no_mentors] }
    end

    context "when the school is not eligible for the selected claim window" do
      let(:school) { create(:claims_school) }
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      it { is_expected.to eq %i[exceptional_circumstances claim_window school eligibility provider no_mentors] }
    end

    context "when the school has not been onboarded to the claims service" do
      let(:school) { create(:school, claims_service: false, region: regions(:inner_london)) }
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      it { is_expected.to eq %i[exceptional_circumstances claim_window school eligibility provider no_mentors] }
    end

    context "when the provider is only eligible for a different academic year" do
      let(:provider) do
        create(:claims_provider, accredited: false).tap { |provider| Claims::ProviderEligibility.create!(provider:, academic_year: other_academic_year) }
      end
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      it { is_expected.to eq %i[exceptional_circumstances claim_window school provider provider_options no_mentors] }
    end

    context "when the provider is accredited but has no eligibility for the academic year" do
      let(:provider) { create(:claims_provider, accredited: true).tap { |provider| provider.eligibilities.destroy_all } }
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      it { is_expected.to include(:provider_options) }
    end

    context "when the school is searched for by name" do
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.name },
        }
      end

      it { is_expected.to include(:school_options) }
    end

    context "when the provider is searched for by name" do
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.name },
        }
      end

      it { is_expected.to include(:provider_options) }
    end

    context "when the school has mentors with claimable hours" do
      let!(:mentor) { create(:claims_mentor, schools: [school]) }
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
          "mentor" => { "mentor_ids" => [mentor.id] },
        }
      end

      it { is_expected.to eq [:exceptional_circumstances, :claim_window, :school, :provider, :mentor, :"mentor_training_#{mentor.id}", :confirmation, :claim_status, :check_your_answers] }
    end

    context "when the school has no mentors with claimable hours in the selected academic year" do
      let!(:mentor) { create(:claims_mentor, schools: [school]) }
      let(:state) do
        {
          "claim_window" => { "id" => claim_window.id },
          "school" => { "id" => school.id },
          "provider" => { "id" => provider.id },
        }
      end

      before do
        create(:mentor_training,
               hours_completed: 20,
               mentor:,
               provider:,
               claim: create(:claim, :submitted, school:, provider:, claim_window:))
      end

      it { is_expected.to eq %i[exceptional_circumstances claim_window school provider no_mentors] }
    end
  end

  describe "#claim_window" do
    let(:state) { { "claim_window" => { "id" => claim_window.id } } }

    it "returns the selected claim window" do
      expect(wizard.claim_window).to eq(claim_window)
    end

    it "uses the academic year of the selected claim window" do
      expect(wizard.academic_year).to eq(claim_window.academic_year)
    end
  end

  describe "#mentors_with_claimable_hours" do
    let!(:mentor) { create(:claims_mentor, schools: [school]) }
    let(:other_claim_window) { Claims::ClaimWindow.current }
    let(:state) do
      {
        "claim_window" => { "id" => claim_window.id },
        "school" => { "id" => school.id },
        "provider" => { "id" => provider.id },
      }
    end

    it "includes mentors with hours remaining in the selected academic year" do
      expect(wizard.mentors_with_claimable_hours).to contain_exactly(mentor)
    end

    context "when the mentor has used all hours in a different academic year" do
      before do
        create(:mentor_training,
               hours_completed: 20,
               mentor:,
               provider:,
               claim: create(:claim, :submitted, school:, provider:, claim_window: other_claim_window))
      end

      it "still includes the mentor (as refresher training)" do
        expect(wizard.mentors_with_claimable_hours).to contain_exactly(mentor)
      end
    end

    context "when the provider has not been selected" do
      let(:state) { { "claim_window" => { "id" => claim_window.id }, "school" => { "id" => school.id } } }

      it "returns no mentors" do
        expect(wizard.mentors_with_claimable_hours).to be_empty
      end
    end
  end

  describe "#claim" do
    let!(:mentor) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "exceptional_circumstances" => { "confirmed" => true },
        "claim_window" => { "id" => claim_window.id },
        "school" => { "id" => school.id },
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor.id] },
        "mentor_training_#{mentor.id}" => { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 6 },
        "confirmation" => { "confirmed" => true },
        "claim_status" => { "status" => "submitted" },
      }
    end

    it "builds a claim for the selected school, provider and claim window" do
      claim = wizard.claim

      expect(claim).to have_attributes(school:, provider:, claim_window:, created_by:)
      expect(claim.mentor_trainings.map { |mt| [mt.mentor_id, mt.hours_completed] }).to eq([[mentor.id, 6]])
    end

    it "calculates the total hours" do
      expect(wizard.total_hours).to eq(6)
    end
  end

  describe "#create_claim" do
    let!(:mentor) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "exceptional_circumstances" => { "confirmed" => true },
        "claim_window" => { "id" => claim_window.id },
        "school" => { "id" => school.id },
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor.id] },
        "mentor_training_#{mentor.id}" => { "mentor_id" => mentor.id, "hours_to_claim" => "maximum" },
        "confirmation" => { "confirmed" => true },
        "claim_status" => { "status" => "submitted" },
      }
    end

    it "creates a submitted claim in the selected claim window on behalf of the school" do
      expect { wizard.create_claim }.to change(Claims::Claim, :count).by(1)

      claim = Claims::Claim.last
      expect(claim).to have_attributes(status: "submitted", claim_window:, school:, provider:, submitted_by: created_by)
      expect(claim.mentor_trainings.sole).to have_attributes(mentor_id: mentor.id, hours_completed: 20)
    end

    context "when the claim status is paid" do
      let(:date_paid) { claim_window.starts_on + 10.days }

      before do
        state["claim_status"] = {
          "status" => "paid",
          "paid_to_la" => "true",
          "date_paid(1i)" => date_paid.year,
          "date_paid(2i)" => date_paid.month,
          "date_paid(3i)" => date_paid.day,
        }
      end

      it "creates a paid claim with the payment details and no notification emails" do
        expect { wizard.create_claim }.to change(Claims::Claim, :count).by(1)
          .and not_have_enqueued_mail

        expect(Claims::Claim.last).to have_attributes(
          status: "paid",
          paid_to_la: true,
          date_paid: date_paid.in_time_zone,
          claim_window:,
          submitted_by: created_by,
        )
        expect(Claims::Claim.last.paid_notification_sent_at).to be_present
      end

      it "raises when the date paid is before the claim window opened" do
        state["claim_status"]["date_paid(3i)"] = (claim_window.starts_on - 1.day).day
        state["claim_status"]["date_paid(2i)"] = (claim_window.starts_on - 1.day).month
        state["claim_status"]["date_paid(1i)"] = (claim_window.starts_on - 1.day).year

        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end

      it "raises when who the claim was paid to is missing" do
        state["claim_status"].delete("paid_to_la")

        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end
    end

    context "when the claim status has not been chosen" do
      before { state.delete("claim_status") }

      it "raises an invalid wizard state error" do
        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end
    end

    context "when the mentor has previously trained with the provider in an earlier academic year" do
      let(:earlier_claim_window) do
        create(:claim_window, starts_on: Date.new(2021, 10, 1), ends_on: Date.new(2021, 12, 1), academic_year: AcademicYear.for_date(Date.new(2021, 10, 1)))
      end

      before do
        create(:mentor_training,
               hours_completed: 20,
               mentor:,
               provider:,
               claim: create(:claim, :submitted, school:, provider:, claim_window: earlier_claim_window))
      end

      it "treats the training as refresher training limited to the refresher hours" do
        state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "maximum" }

        wizard.create_claim

        expect(wizard.claim.mentor_trainings.sole).to have_attributes(training_type: "refresher", hours_completed: 6)
      end

      it "rejects more than the refresher hours" do
        state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 7 }

        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
      end
    end

    context "when the claim window is in an academic year starting after 2025" do
      let(:claim_window) do
        create(:claim_window, starts_on: Date.new(2025, 10, 1), ends_on: Date.new(2025, 12, 1), academic_year: AcademicYear.for_date(Date.new(2025, 10, 1)))
      end

      it "limits the maximum hours to the post 2025 initial hours" do
        wizard.create_claim

        expect(wizard.claim.mentor_trainings.sole).to have_attributes(training_type: "initial", hours_completed: 16)
      end

      it "rejects more hours than the post 2025 initial hours" do
        state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 17 }

        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
      end
    end

    context "when the mentor already has hours claimed in the same academic year" do
      before do
        create(:mentor_training,
               hours_completed: 14,
               mentor:,
               provider:,
               claim: create(:claim, :submitted, school:, provider:, claim_window:))
      end

      it "only allows the remaining hours" do
        state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "maximum" }

        wizard.create_claim

        expect(wizard.claim.mentor_trainings.sole.hours_completed).to eq(6)
      end
    end

    context "when the mentor's earlier claim in the same academic year was not approved for payment" do
      before do
        create(:mentor_training,
               hours_completed: 20,
               mentor:,
               provider:,
               claim: create(:claim, :submitted, status: :payment_not_approved, school:, provider:, claim_window:))
      end

      it "does not count those hours" do
        wizard.create_claim

        expect(wizard.claim.mentor_trainings.sole.hours_completed).to eq(20)
      end
    end

    context "when the provider is not eligible for the academic year of the claim window" do
      let(:provider) do
        create(:claims_provider, accredited: true).tap do |provider|
          provider.eligibilities.destroy_all
          Claims::ProviderEligibility.create!(provider:, academic_year: other_academic_year)
        end
      end

      it "raises an invalid wizard state error" do
        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end
    end

    context "when the provider is eligible for the claim window academic year but not the current one" do
      it "creates the claim" do
        expect(provider.eligible_for_academic_year?(AcademicYear.current)).to be(false)

        expect { wizard.create_claim }.to change(Claims::Claim, :count).by(1)
      end
    end

    context "when the exceptional circumstances have not been acknowledged" do
      before { state.delete("exceptional_circumstances") }

      it "raises an invalid wizard state error" do
        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end
    end

    context "when the school is not eligible for the selected claim window" do
      let(:school) { create(:claims_school) }

      context "and the eligibility has not been confirmed" do
        it "raises an invalid wizard state error" do
          expect { wizard.create_claim }.to raise_error("Invalid wizard state")
          expect(Claims::Claim.count).to eq(0)
          expect(school.eligibilities).to be_empty
        end
      end

      context "and the eligibility has been confirmed" do
        before { state["eligibility"] = { "confirmed" => true } }

        it "makes the school eligible for the academic year and creates the claim" do
          expect { wizard.create_claim }.to change(Claims::Claim, :count).by(1)
            .and change { school.eligibilities.where(academic_year: claim_window.academic_year).count }.from(0).to(1)
        end

        it "does not onboard the school when it is already onboarded" do
          expect { wizard.create_claim }.not_to(change { school.reload.manually_onboarded_by })
        end

        it "does not make the school eligible when the claim cannot be created" do
          state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 21 }

          expect { wizard.create_claim }.to raise_error("Invalid wizard state")
          expect(school.eligibilities).to be_empty
        end
      end
    end

    context "when the school has not been onboarded to the claims service" do
      let(:school) { create(:school, claims_service: false, region: regions(:inner_london)).becomes(Claims::School) }

      it "raises an invalid wizard state error when the eligibility has not been confirmed" do
        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(school.reload.claims_service).to be(false)
      end

      context "and the eligibility has been confirmed" do
        before { state["eligibility"] = { "confirmed" => true } }

        it "onboards the school, makes it eligible and creates the claim" do
          expect { wizard.create_claim }.to change(Claims::Claim, :count).by(1)

          school.reload
          expect(school).to have_attributes(claims_service: true, manually_onboarded_by: created_by)
          expect(school.eligibilities.map(&:academic_year)).to eq([claim_window.academic_year])
        end

        it "does not onboard the school when the claim cannot be created" do
          state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 21 }

          expect { wizard.create_claim }.to raise_error("Invalid wizard state")
          expect(school.reload.claims_service).to be(false)
        end
      end
    end

    context "when the hours exceed what the mentor has remaining" do
      before do
        state["mentor_training_#{mentor.id}"] = { "mentor_id" => mentor.id, "hours_to_claim" => "custom", "custom_hours" => 21 }
      end

      it "raises an invalid wizard state error" do
        expect { wizard.create_claim }.to raise_error("Invalid wizard state")
        expect(Claims::Claim.count).to eq(0)
      end
    end
  end
end
