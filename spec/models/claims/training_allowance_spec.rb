require "rails_helper"

RSpec.describe Claims::TrainingAllowance, type: :model do
  describe "#training_type" do
    subject(:training_allowance) { Claims::TrainingAllowance.new(mentor:, provider:, academic_year:) }

    let!(:mentor) { create(:claims_mentor) }
    let!(:academic_year) do
      create(:academic_year,
             starts_on: Date.parse("1 September 2019"),
             ends_on: Date.parse("31 August 2020"),
             name: "2019 to 2020")
    end
    let!(:provider) { create(:claims_provider) }

    context "when the mentor has not received training in a previous academic year" do
      it "returns initial" do
        expect(training_allowance.training_type).to eq(:initial)
      end
    end

    context "when the mentor has received training in a previous academic year" do
      let(:claim_window) { build(:claim_window, academic_year:) }
      let(:claim) { build(:claim, claim_window:) }
      let(:mentor_training) { create(:mentor_training, :submitted, mentor:, provider:, claim:) }

      before do
        mentor_training
      end

      it "returns refresher" do
        expect(training_allowance.training_type).to eq(:refresher)
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