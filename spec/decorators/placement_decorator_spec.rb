require "rails_helper"

RSpec.describe PlacementDecorator do
  describe "#mentor_names" do
    context "when the placement has no mentors" do
      it "returns Not known yet" do
        placement = create(:placement)

        expect(placement.decorate.mentor_names).to eq("Not known yet")
      end
    end

    it "returns a list of mentor names" do
      placement = create(:placement)
      mentor = create(:placements_mentor, first_name: "John", last_name: "Doe")
      create(
        :mentor_membership,
        :placements,
        mentor:,
      )
      PlacementMentorJoin.create!(placement:, mentor:)

      expect(placement.decorate.mentor_names).to eq(
        "John Doe",
      )
    end
  end

  describe "#subject_names" do
    it "returns a list of subject names" do
      placement = create(:placement)
      subject = create(:subject, name: "Maths")
      PlacementSubjectJoin.create!(placement:, subject:)

      expect(placement.decorate.subject_names).to eq("Maths")
    end
  end

  describe "#school_level" do
    it "returns the school level" do
      placement = create(:placement)
      subject = create(:subject, subject_area: "primary")
      PlacementSubjectJoin.create!(placement:, subject:)

      expect(placement.decorate.school_level).to eq("Primary")
    end
  end

  describe "#window" do
    context "when the window is autumn" do
      it "returns autumn" do
        placement = create(:placement, start_date: "2020-09-01", end_date: "2020-12-31")

        expect(placement.decorate.window).to eq("Autumn")
      end
    end

    context "when the window is spring" do
      it "returns spring" do
        placement = create(:placement, start_date: "2020-01-01", end_date: "2020-03-31")

        expect(placement.decorate.window).to eq("Spring")
      end
    end

    context "when the window is summer" do
      it "returns summer" do
        placement = create(:placement, start_date: "2020-04-01", end_date: "2020-07-31")

        expect(placement.decorate.window).to eq("Summer")
      end
    end

    context "when the window is not autumn, spring or summer" do
      it "returns the window date" do
        placement = create(:placement, start_date: "2020-02-01", end_date: "2020-03-31")

        expect(placement.decorate.window).to eq("February to March")
      end
    end
  end

  describe "#formatted_start_date" do
    it "returns the formatted start date" do
      placement = create(:placement, start_date: "2020-09-01")

      expect(placement.decorate.formatted_start_date).to eq(" 1 September 2020")
    end
  end
end
