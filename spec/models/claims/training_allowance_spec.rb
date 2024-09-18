require "rails_helper"

RSpec.describe Claims::TrainingAllowance, type: :model do
  subject(:training_allowance) { described_class.new(mentor:, provider:, academic_year:, claim_to_exclude:) }

  let(:claim_to_exclude) { nil }
  let!(:mentor) { create(:claims_mentor) }
  let!(:provider) { create(:claims_provider) }
  let!(:academic_year) do
    create(:academic_year,
           starts_on: Date.parse("1 September 2019"),
           ends_on: Date.parse("31 August 2020"),
           name: "2019 to 2020")
  end
  let!(:previous_academic_year) do
    create(:academic_year,
           starts_on: Date.parse("1 September 2018"),
           ends_on: Date.parse("31 August 2019"),
           name: "2018 to 2019")
  end

  describe "initial training" do
    let(:claim_window) { build(:claim_window, :current, academic_year:) }
    let(:claim) { build(:claim, :submitted, claim_window:) }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    context "when the mentor has not completed any training for the academic year" do
      it "returns the expected results" do
        expect(training_allowance.training_type).to eq(:initial)
        expect(training_allowance.total_hours).to eq(20)
        expect(training_allowance.remaining_hours).to eq(20)
        expect(training_allowance).to be_available
      end
    end

    context "when a draft claim exists and the mentor has not completed any training for the academic year" do
      let(:draft_claim) { build(:claim, :draft, claim_window:) }

      before do
        create(:mentor_training, mentor:, provider:, claim: draft_claim, hours_completed: 1)
      end

      it "does not include the draft claim" do
        expect(training_allowance.training_type).to eq(:initial)
        expect(training_allowance.total_hours).to eq(20)
        expect(training_allowance.remaining_hours).to eq(20)
        expect(training_allowance).to be_available
      end
    end

    context "when an internal draft claim exists and the mentor has not completed any training for the academic year" do
      let(:internal_draft_claim) { build(:claim, status: :internal_draft, claim_window:) }

      before do
        create(:mentor_training, mentor:, provider:, claim: internal_draft_claim, hours_completed: 1)
      end

      it "does not include the internal draft claim" do
        expect(training_allowance.training_type).to eq(:initial)
        expect(training_allowance.total_hours).to eq(20)
        expect(training_allowance.remaining_hours).to eq(20)
        expect(training_allowance).to be_available
      end
    end

    context "when the mentor has completed training for the academic year" do
      before { mentor_training }

      context "when the mentor has completed 5 hours of training in the current academic year" do
        let(:hours_completed) { 5 }

        it "returns the expected results" do
          expect(training_allowance.training_type).to eq(:initial)
          expect(training_allowance.total_hours).to eq(20)
          expect(training_allowance.remaining_hours).to eq(15)
          expect(training_allowance).to be_available
        end
      end

      context "when the mentor has completed 20 hours of training in the current academic year" do
        let(:hours_completed) { 20 }

        it "returns the expected results" do
          expect(training_allowance.training_type).to eq(:initial)
          expect(training_allowance.total_hours).to eq(20)
          expect(training_allowance.remaining_hours).to eq(0)
          expect(training_allowance).not_to be_available
        end
      end

      context "when the mentor has completed 10 hours of training in the current academic year for a claim they want to exclude" do
        let(:hours_completed) { 10 }
        let(:claim_to_exclude) { claim }

        it "returns the expected results" do
          expect(training_allowance.training_type).to eq(:initial)
          expect(training_allowance.total_hours).to eq(20)
          expect(training_allowance.remaining_hours).to eq(20)
          expect(training_allowance).to be_available
        end

        context "when a second claim has been made whilst excluding a previous claim" do
          let(:second_claim) { build(:claim, :submitted, claim_window:, provider:) }
          let(:second_mentor_training) { create(:mentor_training, mentor:, provider:, claim: second_claim, hours_completed: 3) }

          before do
            second_mentor_training
          end

          it "does not exclude other claims" do
            expect(training_allowance.training_type).to eq(:initial)
            expect(training_allowance.total_hours).to eq(20)
            expect(training_allowance.remaining_hours).to eq(17)
            expect(training_allowance).to be_available
          end
        end
      end
    end
  end

  describe "refresher training" do
    let(:claim_window) { build(:claim_window, :current, academic_year:) }
    let(:claim) { build(:claim, :submitted, claim_window:, provider:) }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    let(:previous_claim_window) { build(:claim_window, starts_on: 8.days.ago, ends_on: 4.days.ago, academic_year: previous_academic_year) }
    let(:previous_claim) { build(:claim, :submitted, claim_window: previous_claim_window, provider:) }
    let(:previous_mentor_training) { create(:mentor_training, mentor:, provider:, claim: previous_claim, hours_completed: 20) }

    context "when the mentor has not completed any training for the academic year" do
      before { previous_mentor_training }

      it "returns the expected results" do
        expect(training_allowance.training_type).to eq(:refresher)
        expect(training_allowance.total_hours).to eq(6)
        expect(training_allowance.remaining_hours).to eq(6)
        expect(training_allowance).to be_available
      end
    end

    context "when a draft claim exists and the mentor has not completed any training for the academic year" do
      let(:draft_claim) { build(:claim, :draft, claim_window:) }

      before do
        previous_mentor_training
        create(:mentor_training, mentor:, provider:, claim: draft_claim, hours_completed: 1)
      end

      it "does not include the draft claim" do
        expect(training_allowance.training_type).to eq(:refresher)
        expect(training_allowance.total_hours).to eq(6)
        expect(training_allowance.remaining_hours).to eq(6)
        expect(training_allowance).to be_available
      end
    end

    context "when an internal draft claim exists and the mentor has not completed any training for the academic year" do
      let(:internal_draft_claim) { build(:claim, status: :internal_draft, claim_window:) }

      before do
        previous_mentor_training
        create(:mentor_training, mentor:, provider:, claim: internal_draft_claim, hours_completed: 1)
      end

      it "does not include the internal draft claim" do
        expect(training_allowance.training_type).to eq(:refresher)
        expect(training_allowance.total_hours).to eq(6)
        expect(training_allowance.remaining_hours).to eq(6)
        expect(training_allowance).to be_available
      end
    end

    context "when the mentor has completed training for the academic year" do
      before do
        mentor_training
        previous_mentor_training
      end

      context "when the mentor has completed 5 hours of training in the current academic year and 20 hours in the previous academic year" do
        let(:hours_completed) { 5 }

        it "returns the expected results" do
          expect(training_allowance.training_type).to eq(:refresher)
          expect(training_allowance.total_hours).to eq(6)
          expect(training_allowance.remaining_hours).to eq(1)
          expect(training_allowance).to be_available
        end
      end

      context "when the mentor has completed 6 hours of training in the current academic year and 20 hours in the previous academic year" do
        let(:hours_completed) { 6 }

        it "returns the expected results" do
          expect(training_allowance.training_type).to eq(:refresher)
          expect(training_allowance.total_hours).to eq(6)
          expect(training_allowance.remaining_hours).to eq(0)
          expect(training_allowance).not_to be_available
        end
      end

      context "when the mentor has completed 3 hours of training in the current academic year and 20 hours in the previous academic year for a claim they want to exclude" do
        let(:hours_completed) { 6 }
        let(:claim_to_exclude) { claim }

        it "excludes the excluded claim" do
          expect(training_allowance.training_type).to eq(:refresher)
          expect(training_allowance.total_hours).to eq(6)
          expect(training_allowance.remaining_hours).to eq(6)
          expect(training_allowance).to be_available
        end

        context "when a second claim has been made whilst excluding a previous claim" do
          let(:second_claim) { build(:claim, :submitted, claim_window:, provider:) }
          let(:second_mentor_training) { create(:mentor_training, mentor:, provider:, claim: second_claim, hours_completed: 3) }

          before do
            second_mentor_training
          end

          it "does not exclude other claims" do
            expect(training_allowance.training_type).to eq(:refresher)
            expect(training_allowance.total_hours).to eq(6)
            expect(training_allowance.remaining_hours).to eq(3)
            expect(training_allowance).to be_available
          end
        end
      end
    end
  end
end
