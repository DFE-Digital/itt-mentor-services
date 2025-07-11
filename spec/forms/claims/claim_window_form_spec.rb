require "rails_helper"

describe Claims::ClaimWindowForm, type: :model do
  subject(:claim_window_form) { described_class.new(academic_year_id: academic_year.id) }

  let(:academic_year) { create(:academic_year, starts_on: Date.parse("1 September 2023"), ends_on: Date.parse("31 August 2024"), name: "2023 to 2024") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }
    it { is_expected.to validate_presence_of(:academic_year_id) }

    it "validates that end date is always after the start date" do
      claim_window_form.starts_on = Date.parse("17 July 2023")
      claim_window_form.ends_on = Date.parse("18 July 2023")

      expect(claim_window_form).to be_valid

      claim_window_form.ends_on = Date.parse("16 July 2023")

      expect(claim_window_form).to be_invalid
      expect(claim_window_form.errors[:ends_on]).to include("Enter a window closing date that is after the opening date")
    end

    context "with validating against existing claim windows" do
      before do
        create(:claim_window, starts_on: Date.parse("1 July 2024"), ends_on: Date.parse("31 July 2024"), academic_year:)
      end

      it "validates that the start date does not fall within an existing claim window" do
        claim_window_form.starts_on = Date.parse("17 July 2024")
        claim_window_form.ends_on = Date.parse("27 August 2024")

        expect(claim_window_form).to be_invalid
        expect(claim_window_form.errors[:starts_on]).to include("Select a date that is not within an existing claim window")
      end

      it "validates that the end date does not fall within an existing claim window" do
        claim_window_form.starts_on = Date.parse("1 June 2024")
        claim_window_form.ends_on = Date.parse("17 July 2024")

        expect(claim_window_form).to be_invalid
        expect(claim_window_form.errors[:ends_on]).to include("Select a date that is not within an existing claim window")
      end

      it "validates that no claim windows existing within the given start and end dates" do
        claim_window_form.starts_on = Date.parse("1 June 2024")
        claim_window_form.ends_on = Date.parse("31 August 2024")

        expect(claim_window_form).to be_invalid
        expect(claim_window_form.errors[:starts_on]).to include("A claim window already exists within the selected dates")
      end
    end
  end

  describe "#academic_year_name" do
    subject(:academic_year_name) { claim_window_form.academic_year_name }

    it "returns the name of the academic year" do
      claim_window_form.academic_year_id = academic_year.id

      expect(academic_year_name).to eq("2023 to 2024")
    end

    it "returns nil if the academic year is not present" do
      claim_window_form.academic_year_id = nil

      expect(academic_year_name).to be_nil
    end
  end
end
