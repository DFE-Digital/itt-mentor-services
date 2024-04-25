require "rails_helper"

RSpec.describe PlacementDecorator do
  describe "#mentor_names" do
    context "when the placement has no mentors" do
      it "returns Not known yet" do
        placement = build(:placement)

        expect(placement.decorate.mentor_names).to eq("Not known yet")
      end
    end

    context "when the placement has one mentor" do
      it "returns a list of mentor names" do
        placement = build(:placement, mentors: [
          build(:placements_mentor, first_name: "John", last_name: "Doe"),
        ])

        expect(placement.decorate.mentor_names).to eq(
          "John Doe",
        )
      end
    end

    context "when the placement has multiple mentors" do
      it "returns a list of mentor names in alphabetical order" do
        placement = build(:placement, mentors: [
          build(:placements_mentor, first_name: "John", last_name: "Doe"),
          build(:placements_mentor, first_name: "Jane", last_name: "Doe"),
        ])

        expect(placement.decorate.mentor_names).to eq(
          "Jane Doe and John Doe",
        )
      end
    end
  end

  describe "#subject_names" do
    context "when the placement has no subjects" do
      it "returns Not known yet" do
        placement = build(:placement)

        expect(placement.decorate.subject_names).to eq("Not known yet")
      end
    end

    context "when the placement has one subject" do
      it "returns a list of subject names" do
        placement = create(:placement, subjects: [build(:subject, name: "Maths")])

        expect(placement.decorate.subject_names).to eq("Maths")
      end
    end

    context "when the placement has multiple subjects" do
      it "returns a list of subject names in alphabetical order" do
        placement = create(:placement, subjects: [
          build(:subject, name: "Maths"),
          build(:subject, name: "English"),
        ])

        expect(placement.decorate.subject_names).to eq("English and Maths")
      end
    end
  end

  describe "#school_level" do
    it "returns the school level" do
      placement = build(:placement, subjects: [build(:subject, :primary)])

      expect(placement.decorate.school_level).to eq("Primary")
    end
  end

  describe "#formatted_start_date" do
    it "returns the formatted start date" do
      placement = build(:placement, start_date: "2020-09-01")

      expect(placement.decorate.formatted_start_date).to eq(" 1 September 2020")
    end
  end
end
