require "rails_helper"

RSpec.describe Claims::TrainingAllowance, type: :model do
  subject(:training_allowance) { described_class.new(mentor:, provider:, academic_year:) }

    let!(:mentor) { create(:claims_mentor) }
    let!(:academic_year) do
      create(:academic_year,
             starts_on: Date.parse("1 September 2019"),
             ends_on: Date.parse("31 August 2020"),
             name: "2019 to 2020")
    end
    let!(:provider) { create(:claims_provider) }
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

  describe "#training_type" do
    context "when the mentor has not received training in the previous academic year" do
      it "returns initial" do
        expect(training_allowance.training_type).to eq(:initial)
      end
    end

    context "when the mentor has received training in the previous academic year" do
      let(:claim_window) { build(:claim_window, :current, academic_year: previous_academic_year) }
      let(:claim) { build(:claim, :submitted, claim_window:) }
      let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:) }

      before { mentor_training }

      it "returns refresher" do
        expect(training_allowance.training_type).to eq(:refresher)
      end
    end

    context "when the provider has trained a different mentor for the academic year" do
      let(:claim_window) { build(:claim_window, :current, academic_year:) }
      let(:claim) { build(:claim, :submitted, claim_window:) }
      let(:mentor_training) { create(:mentor_training, provider:, claim:) }

      before { mentor_training }

      it "returns initial" do
        expect(training_allowance.training_type).to eq(:initial)
      end
    end
  end

  describe "#total_hours" do
    context "when the mentor has received initial training" do
      it "returns 20" do
        expect(training_allowance.total_hours).to eq(20)
      end
    end

    context "when the mentor has received refresher training" do
      let(:claim_window) { build(:claim_window, :current, academic_year: previous_academic_year) }
      let(:claim) { build(:claim, :submitted, claim_window:) }
      let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:) }

      before do
        mentor_training
      end

      it "returns 6" do
        expect(training_allowance.total_hours).to eq(6)
      end
    end
  end

  describe "initial training" do
    let(:claim_window) { build(:claim_window, :current, academic_year:) }
    let(:claim) { build(:claim, :submitted, claim_window:) }
    let(:hours_completed) { 5 }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    before { mentor_training }

    it "returns 15" do
      expect(training_allowance.training_type).to eq(:initial)
      expect(training_allowance.total_hours).to eq(20)
      expect(training_allowance.remaining_hours).to eq(15)
      expect(training_allowance).to be_available
    end
  end
  
  describe "refresher training" do
    let(:claim_window) { build(:claim_window, :current, academic_year:) }
    let(:claim) { build(:claim, :submitted, claim_window:, provider:) }
    let(:hours_completed) { 5 }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    let(:previous_claim_window) { build(:claim_window, starts_on: 8.days.ago, ends_on: 4.days.ago, academic_year: previous_academic_year) }
    let(:previous_claim) { build(:claim, :submitted, claim_window: previous_claim_window, provider:) }
    let(:previous_mentor_training) { create(:mentor_training, mentor:, provider:, claim: previous_claim, hours_completed: nil) }

    before do
      mentor_training
      previous_mentor_training
    end

    it "returns 15" do
      expect(training_allowance.training_type).to eq(:refresher)
      expect(training_allowance.total_hours).to eq(6)
      expect(training_allowance.remaining_hours).to eq(1)
      expect(training_allowance).to be_available
    end
  end

  describe "#remaining_hours" do
    let(:claim_window) { build(:claim_window, :current, academic_year: previous_academic_year) }
    let(:claim) { build(:claim, :submitted, claim_window:) }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    context "with initial training" do
      context "when no hours have been completed" do
        let(:hours_completed) { nil }

        before { mentor_training }

        it "returns 20" do
          expect(training_allowance.remaining_hours).to eq(20)
        end
      end

      context "when some of the hours have been completed" do
        let(:hours_completed) { 13 }

        before { mentor_training }

        it "returns 7" do
          expect(training_allowance.remaining_hours).to eq(7)
        end
      end

      context "when all of the hours have been completed" do
        let(:hours_completed) { 20 }

        before { mentor_training }

        it "returns 0" do
          expect(training_allowance.remaining_hours).to eq(0)
        end
      end

      context "when a claim has been provided to be excluded" do
        subject(:training_allowance) do
          described_class.new(mentor:, provider:, academic_year:)
        end

        let(:excluded_claim) { create(:claim, :submitted, claim_window:) }
        let(:excluded_mentor_training) do
          create(:mentor_training, mentor:, provider:, claim: excluded_claim, hours_completed: 5)
        end

        before { excluded_mentor_training }

        it "does not include the hours from the excluded claim" do
          expect(training_allowance.remaining_hours).to eq(6)
        end
      end
    end
  end

  describe "#available?" do
    let(:claim_window) { build(:claim_window, :current, academic_year: previous_academic_year) }
    let(:claim) { build(:claim, :submitted, claim_window:) }
    let(:mentor_training) { create(:mentor_training, mentor:, provider:, claim:, hours_completed:) }

    context "when there are remaining hours" do
      let(:hours_completed) { 13 }

      before { mentor_training }

      it "returns true" do
        expect(training_allowance.available?).to be(true)
      end
    end

    context "when there are no remaining hours" do
      let(:hours_completed) { 20 }

      before { mentor_training }

      it "returns false" do
        expect(training_allowance.available?).to be(false)
      end
    end
  end
end
