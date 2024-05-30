require "rails_helper"

RSpec.describe PlacementDecorator do
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

  describe "#subject_names" do
    context "when the placement has a subject without children" do
      it "returns a list of subject names" do
        placement = create(:placement, subject: build(:subject, name: "Maths"))

        expect(placement.decorate.subject_name).to eq("Maths")
      end
    end

    context "when the placement has a subject with children" do
      context "when the placement has been created" do
        it "returns a list of subject names in alphabetical order" do
          subject = build(:subject, name: "Modern Foreign Languages")
          placement = create(:placement, subject:, additional_subjects: [
            build(:subject, name: "French", parent_subject: subject),
            build(:subject, name: "German", parent_subject: subject),
            build(:subject, name: "Spanish", parent_subject: subject),
          ])

          expect(placement.decorate.subject_name).to eq("French, German, and Spanish")
        end
      end

      context "when the placement has been built" do
        it "returns a list of subject names in alphabetical order" do
          subject = build(:subject, name: "Modern Foreign Languages")
          placement = build(:placement, subject:, additional_subjects: [
            build(:subject, name: "French", parent_subject: subject),
            build(:subject, name: "German", parent_subject: subject),
            build(:subject, name: "Spanish", parent_subject: subject),
          ])

          expect(placement.decorate.subject_name).to eq("French, German, and Spanish")
        end
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
end
