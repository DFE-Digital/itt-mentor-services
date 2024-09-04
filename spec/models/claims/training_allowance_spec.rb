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

      end

      describe "#remaining_hours" do

      end

      describe "#available?" do

    end
end