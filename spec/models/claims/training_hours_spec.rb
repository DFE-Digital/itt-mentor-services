require "rails_helper"

RSpec.describe Claims::TrainingHours, type: :model do
  subject(:training_hours) { described_class.new(academic_year:) }

  context "when the academic year starts before 2026" do
    let(:academic_year) do
      create(:academic_year,
             starts_on: Date.parse("1 September 2019"),
             ends_on: Date.parse("31 August 2020"),
             name: "2019 to 2020")
    end

    describe "#initial" do
      it "returns the initial training hours" do
        expect(training_hours.initial).to eq(20)
      end
    end

    describe "#refresher" do
      it "returns the refresher training hours" do
        expect(training_hours.refresher).to eq(6)
      end
    end

    describe ".for" do
      it "returns the hours for the requested training type" do
        expect(described_class.for(academic_year:, training_type: :initial)).to eq(20)
        expect(described_class.for(academic_year:, training_type: :refresher)).to eq(6)
      end
    end
  end

  context "when the academic year starts in 2026 or later" do
    let(:academic_year) do
      create(:academic_year,
             starts_on: Date.parse("1 September 2026"),
             ends_on: Date.parse("31 August 2027"),
             name: "2026 to 2027")
    end

    describe "#initial" do
      it "returns the initial training hours" do
        expect(training_hours.initial).to eq(16)
      end
    end

    describe "#refresher" do
      it "returns the refresher training hours" do
        expect(training_hours.refresher).to eq(6)
      end
    end

    describe ".for" do
      it "returns the hours for the requested training type" do
        expect(described_class.for(academic_year:, training_type: :initial)).to eq(16)
        expect(described_class.for(academic_year:, training_type: :refresher)).to eq(6)
      end
    end
  end
end
