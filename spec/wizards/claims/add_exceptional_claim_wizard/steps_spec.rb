require "rails_helper"

RSpec.describe "Claims::AddExceptionalClaimWizard steps" do
  let(:wizard) { Claims::AddExceptionalClaimWizard.new(created_by:, state:, params: ActionController::Parameters.new({}), current_step:) }
  let(:created_by) { create(:claims_support_user) }
  let(:past_claim_window) { create(:claim_window, :historic) }
  let(:school) { create(:claims_school, eligibilities: [build(:eligibility, claim_window: past_claim_window)]) }
  let(:state) { {} }
  let(:current_step) { nil }
  let(:step) { wizard.step }

  before { Claims::ClaimWindow.current || create(:claim_window, :current) }

  describe Claims::AddExceptionalClaimWizard::ExceptionalCircumstancesStep do
    let(:current_step) { :exceptional_circumstances }

    it "requires the support user to acknowledge the warning" do
      step.confirmed = false
      expect(step).not_to be_valid
      expect(step.errors[:confirmed]).to include("Confirm that this claim is being made under exceptional circumstances")

      step.confirmed = true
      expect(step).to be_valid
    end
  end

  describe Claims::AddExceptionalClaimWizard::ClaimWindowStep do
    let(:current_step) { :claim_window }

    it "lists only past claim windows, most recent first" do
      older = create(:claim_window, starts_on: Date.new(2022, 9, 1), ends_on: Date.new(2022, 10, 1), academic_year: AcademicYear.for_date(Date.new(2022, 9, 1)))
      past_claim_window

      expect(step.claim_windows).to eq([past_claim_window, older].sort_by(&:ends_on).reverse)
      expect(step.claim_windows).not_to include(Claims::ClaimWindow.current)
    end

    it "does not list discarded claim windows" do
      discarded = create(:claim_window, starts_on: Date.new(2020, 9, 1), ends_on: Date.new(2020, 10, 1), academic_year: AcademicYear.for_date(Date.new(2020, 9, 1)))
      discarded.discard
      past_claim_window

      expect(step.claim_windows).to include(past_claim_window)
      expect(step.claim_windows).not_to include(discarded)
    end

    it "does not accept a discarded claim window" do
      discarded = create(:claim_window, starts_on: Date.new(2020, 9, 1), ends_on: Date.new(2020, 10, 1), academic_year: AcademicYear.for_date(Date.new(2020, 9, 1)))
      discarded.discard
      step.id = discarded.id

      expect(step).not_to be_valid
    end

    it "is invalid without a selection" do
      expect(step).not_to be_valid
      expect(step.errors[:id]).to include("Select a claim window")
    end

    it "is invalid for the current claim window" do
      step.id = Claims::ClaimWindow.current.id
      expect(step).not_to be_valid
      expect(step.errors[:id]).to include("Select a claim window")
    end

    it "is valid for a past claim window" do
      step.id = past_claim_window.id
      expect(step).to be_valid
      expect(step.claim_window).to eq(past_claim_window)
    end
  end

  describe Claims::AddExceptionalClaimWizard::SchoolStep do
    let(:current_step) { :school }
    let(:state) { { "claim_window" => { "id" => past_claim_window.id } } }

    it "is invalid without a school" do
      expect(step).not_to be_valid
      expect(step.errors[:id]).to include("Enter a school name, unique reference number (URN) or postcode")
    end

    it "is valid for a school eligible for the selected claim window" do
      step.id = school.id
      expect(step).to be_valid
      expect(step.school).to eq(school)
    end

    it "is valid for a school that is not yet eligible for the selected claim window" do
      ineligible_school = create(:claims_school, name: "Ineligible Academy")
      step.id = ineligible_school.id

      expect(step).to be_valid
    end

    it "finds a school that has not yet been onboarded to the claims service" do
      not_onboarded_school = create(:school, claims_service: false, region: regions(:inner_london))
      step.id = not_onboarded_school.id

      expect(step).to be_valid
      expect(step.school).to be_a(Claims::School)
      expect(step.school.id).to eq(not_onboarded_school.id)
    end
  end

  describe Claims::AddExceptionalClaimWizard::EligibilityStep do
    let(:current_step) { :eligibility }
    let(:school) { create(:claims_school) }
    let(:state) do
      { "claim_window" => { "id" => past_claim_window.id }, "school" => { "id" => school.id } }
    end

    it "requires the support user to confirm the school should be made eligible" do
      step.confirmed = false
      expect(step).not_to be_valid
      expect(step.errors[:confirmed]).to include("Confirm that the school should be made eligible to claim")

      step.confirmed = true
      expect(step).to be_valid
    end
  end

  describe Claims::AddExceptionalClaimWizard::ClaimStatusStep do
    let(:current_step) { :claim_status }
    let(:provider) { create(:claims_provider, accredited: false).tap { |provider| Claims::ProviderEligibility.create!(provider:, academic_year: past_claim_window.academic_year) } }
    let!(:mentor) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "claim_window" => { "id" => past_claim_window.id },
        "school" => { "id" => school.id },
        "provider" => { "id" => provider.id },
        "mentor" => { "mentor_ids" => [mentor.id] },
        "mentor_training_#{mentor.id}" => { "mentor_id" => mentor.id, "hours_to_claim" => "maximum" },
      }
    end

    def assign_paid(status: "paid", paid_to_la: "false", date: past_claim_window.starts_on + 1.day)
      step.status = status
      step.paid_to_la = paid_to_la
      step.day = date&.day
      step.month = date&.month
      step.year = date&.year
    end

    it "offers submitted and paid" do
      expect(described_class::STATUSES).to eq(%w[submitted paid])
    end

    it "requires a status" do
      expect(step).not_to be_valid
      expect(step.errors[:status]).to include("Select a claim status")
    end

    it "rejects any other status" do
      step.status = "payment_in_progress"

      expect(step).not_to be_valid
      expect(step.errors[:status]).to include("Select a claim status")
    end

    it "is valid as submitted without any payment details" do
      step.status = "submitted"

      expect(step).to be_valid
      expect(step).not_to be_paid
    end

    it "ignores payment details entered for a submitted claim" do
      step = described_class.new(wizard:, attributes: { "status" => "submitted", "paid_to_la" => "true", "date_paid(3i)" => 4 })

      expect(step.paid_to_la).to be_nil
      expect(step.day).to be_nil
      expect(step).to be_valid
    end

    describe "when the claim is paid" do
      it "is valid with who it was paid to and a date paid" do
        assign_paid

        expect(step).to be_valid
        expect(step).to be_paid
      end

      it "accepts paying a local authority" do
        assign_paid(paid_to_la: "true")

        expect(step).to be_valid
        expect(step.paid_to_la?).to be(true)
      end

      it "accepts paying an academy" do
        assign_paid(paid_to_la: "false")

        expect(step.paid_to_la?).to be(false)
      end

      it "requires who the claim was paid to" do
        assign_paid(paid_to_la: nil)

        expect(step).not_to be_valid
        expect(step.errors[:paid_to_la]).to include("Select who the claim was paid to")
      end

      it "rejects an unknown paid to value" do
        assign_paid(paid_to_la: "maybe")

        expect(step).not_to be_valid
        expect(step.errors[:paid_to_la]).to include("Select who the claim was paid to")
      end

      it "requires a date paid" do
        assign_paid(date: nil)

        expect(step).not_to be_valid
        expect(step.errors[:date_paid]).to include("Enter the date the claim was paid")
      end

      it "rejects a partial date" do
        assign_paid
        step.month = nil

        expect(step).not_to be_valid
        expect(step.errors[:date_paid]).to include("Enter a real date the claim was paid")
      end

      it "rejects a date that does not exist" do
        assign_paid
        step.day = 31
        step.month = 2

        expect(step).not_to be_valid
        expect(step.errors[:date_paid]).to include("Enter a real date the claim was paid")
      end

      it "rejects a date in the future" do
        assign_paid(date: Date.current + 1.day)

        expect(step).not_to be_valid
        expect(step.errors[:date_paid]).to include("The date paid must be in the past")
      end

      it "accepts today" do
        assign_paid(date: Date.current)

        expect(step).to be_valid
      end

      it "rejects a date before the claim window opened" do
        assign_paid(date: past_claim_window.starts_on - 1.day)

        expect(step).not_to be_valid
        expect(step.errors[:date_paid]).to include("The date paid must not be before the claim window opened")
      end

      it "accepts the day the claim window opened" do
        assign_paid(date: past_claim_window.starts_on)

        expect(step).to be_valid
      end

      it "exposes the date paid as a time" do
        assign_paid(date: Date.new(2024, 12, 20))

        expect(step.date_paid).to eq(Date.new(2024, 12, 20))
        expect(step.date_paid_time).to eq(Time.zone.local(2024, 12, 20))
      end

      it "keeps what was entered when the date is not a real date" do
        assign_paid
        step.day = 31
        step.month = 2

        expect(step.date_paid).to have_attributes(day: 31, month: 2)
        expect(step.date_paid_time).to be_nil
      end
    end
  end

  describe Claims::AddExceptionalClaimWizard::SchoolOptionsStep do
    let(:current_step) { :school_options }
    let(:state) do
      { "claim_window" => { "id" => past_claim_window.id }, "school" => { "id" => "Shelbyville" } }
    end

    it "searches schools using the text entered in the school step" do
      shelbyville = create(:claims_school, name: "Shelbyville Elementary", eligibilities: [build(:eligibility, claim_window: past_claim_window)])
      create(:claims_school, name: "Springfield Elementary")
      not_onboarded = create(:school, name: "Shelbyville Secondary", claims_service: false, region: regions(:inner_london))

      expect(step.schools.map(&:id)).to contain_exactly(shelbyville.id, not_onboarded.id)
    end

    it "requires a selection" do
      expect(step).not_to be_valid
      expect(step.errors[:id]).to include("Select a school")
    end
  end

  describe Claims::AddExceptionalClaimWizard::MentorStep do
    let(:current_step) { :mentor }
    let(:provider) { create(:claims_provider, accredited: false).tap { |provider| Claims::ProviderEligibility.create!(provider:, academic_year: past_claim_window.academic_year) } }
    let!(:mentor) { create(:claims_mentor, schools: [school]) }
    let(:state) do
      {
        "claim_window" => { "id" => past_claim_window.id },
        "school" => { "id" => school.id },
        "provider" => { "id" => provider.id },
      }
    end

    it "only allows mentors from the school with claimable hours" do
      other_mentor = create(:claims_mentor)

      step.mentor_ids = [other_mentor.id]
      expect(step).not_to be_valid

      step.mentor_ids = [mentor.id]
      expect(step).to be_valid
    end
  end
end
