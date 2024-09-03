require "rails_helper"

RSpec.describe PlacementDecorator do
  describe "#subject_name" do
    it "returns the name of the subject" do
      placement = build(:placement, subject: build(:subject, name: "Maths"))
      expect(placement.decorate.subject_name).to eq("Maths")
    end
  end

  describe "#mentor_names" do
    context "when the placement has no mentors" do
      it "returns Not yet known" do
        placement = build(:placement)

        expect(placement.decorate.mentor_names).to eq("Not yet known")
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

  describe "#title" do
    context "when the placement has a subject without children" do
      it "returns a the subject name" do
        placement = create(:placement, subject: build(:subject, name: "Maths"))

        expect(placement.decorate.title).to eq("Maths")
      end
    end

    context "when the placement has a subject with children" do
      it "returns a list of subject names in alphabetical order" do
        subject = build(:subject, name: "Modern Foreign Languages")
        placement = create(:placement, subject:, additional_subjects: [
          build(:subject, name: "French", parent_subject: subject),
          build(:subject, name: "German", parent_subject: subject),
          build(:subject, name: "Spanish", parent_subject: subject),
        ])

        expect(placement.decorate.title).to eq("French, German, and Spanish")
      end
    end

    context "when the placement has a year group" do
      it "returns a subject name, followed by the year group in brackets" do
        placement = create(:placement, subject: build(:subject, name: "Maths"), year_group: :year_1)

        expect(placement.decorate.title).to eq("Maths (Year 1)")
      end
    end
  end

  describe "#school_level" do
    it "returns the school level" do
      placement = build(:placement, subject: build(:subject, :primary))

      expect(placement.decorate.school_level).to eq("Primary")
    end
  end

  describe "#provider_name" do
    context "when the placement has no provider" do
      it "returns Not known yet" do
        placement = build(:placement)

        expect(placement.decorate.provider_name).to eq("Not yet known")
      end
    end

    context "when the placement has a provider" do
      it "returns the provider name" do
        placement = build(:placement, provider: build(:provider, name: "Provider 1"))

        expect(placement.decorate.provider_name).to eq("Provider 1")
      end
    end
  end

  describe "#additional_subject_names" do
    it "returns the names of additional subjects" do
      subject = build(:subject, name: "Modern foreign languages")
      additional_subjects = [build(:subject, name: "French", parent_subject: subject),
                             build(:subject, name: "Spanish", parent_subject: subject)]

      placement = create(:placement, subject:, additional_subjects:)

      expect(placement.decorate.additional_subject_names).to eq("French and Spanish")
    end
  end

  describe "#term_names" do
    context "when the placement has no terms" do
      it "returns Any term" do
        placement = build(:placement)

        expect(placement.decorate.term_names).to eq("Any time in the academic year")
      end
    end

    context "when the placement has one term" do
      it "returns the term name" do
        placement = create(:placement)
        term = create(:placements_term, :autumn)
        placement.terms << term

        expect(placement.decorate.term_names).to eq("Autumn term")
      end
    end

    context "when the placement has multiple terms" do
      it "returns a list of term names" do
        placement = create(:placement)
        term1 = create(:placements_term, :spring)
        term2 = create(:placements_term, :autumn)
        placement.terms << term1
        placement.terms << term2

        expect(placement.decorate.term_names).to eq("Autumn term, Spring term")
      end
    end
  end
end
