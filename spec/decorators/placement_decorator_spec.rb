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

  describe "#window" do
    context "when the window is autumn" do
      it "returns autumn" do
        placement = build(:placement, start_date: "2020-09-01", end_date: "2020-12-31")

        expect(placement.decorate.window).to eq("Autumn")
      end
    end

    context "when the window is spring" do
      it "returns spring" do
        placement = build(:placement, start_date: "2020-01-01", end_date: "2020-03-31")

        expect(placement.decorate.window).to eq("Spring")
      end
    end

    context "when the window is summer" do
      it "returns summer" do
        placement = build(:placement, start_date: "2020-04-01", end_date: "2020-07-31")

        expect(placement.decorate.window).to eq("Summer")
      end
    end

    context "when the window is not autumn, spring or summer" do
      it "returns the window date" do
        placement = build(:placement, start_date: "2020-02-01", end_date: "2020-03-31")

        expect(placement.decorate.window).to eq("February to March")
      end
    end
  end

  describe "#formatted_start_date" do
    it "returns the formatted start date" do
      placement = build(:placement, start_date: "2020-09-01")

      expect(placement.decorate.formatted_start_date).to eq(" 1 September 2020")
    end
  end
end
