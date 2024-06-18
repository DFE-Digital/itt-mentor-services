require "rails_helper"

RSpec.describe Placements::AddPlacement::Steps::Mentors, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil, mentor_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:mentor_ids) }
  end

  describe "#mentors_for_selection" do
    it "returns mentors for the school" do
      school = create(:placements_school, mentors: build_list(:placements_mentor, 1))
      step = described_class.new(school:)

      expect(step.mentors_for_selection).to eq(school.mentors)
    end
  end

  describe "#mentor_ids=" do
    context "when the value is blank" do
      it "remains blank" do
        school = create(:placements_school)
        step = described_class.new(school:)

        step.mentor_ids = []

        expect(step.mentor_ids).to eq([])
      end
    end

    context "when the value includes 'not_known'" do
      it "removes all values except not_known" do
        school = create(:placements_school, mentors: build_list(:placements_mentor, 1))
        mentor = school.mentors.first
        step = described_class.new(school:)

        step.mentor_ids = ["not_known", mentor.id]

        expect(step.mentor_ids).to eq([:not_known])
      end
    end

    context "when the value includes mentor ids" do
      it "retains the mentor ids" do
        school = create(:placements_school, mentors: build_list(:placements_mentor, 1))
        step = described_class.new(school:)

        step.mentor_ids = school.mentors.ids

        expect(step.mentor_ids).to eq(school.mentors.ids)
      end

      context "and the values include mentors from another school" do
        it "retains only the mentors from the target school" do
          school = create(:placements_school, mentors: build_list(:placements_mentor, 1))
          another_school = create(:placements_school, mentors: build_list(:placements_mentor, 1))
          step = described_class.new(school:)

          step.mentor_ids = another_school.mentors.ids + school.mentors.ids

          expect(step.mentor_ids).to eq(school.mentors.ids)
        end
      end
    end
  end

  describe "#wizard_attributes" do
    it "removes not_known" do
      school = create(:placements_school)
      step = described_class.new(school:, mentor_ids: [:not_known])

      expect(step.wizard_attributes).to eq({ mentor_ids: [] })
    end

    it "returns mentor ids" do
      school = create(:placements_school)
      mentor = create(:placements_mentor_membership, school:).mentor
      step = described_class.new(school:, mentor_ids: [mentor.id])

      expect(step.wizard_attributes).to eq({ mentor_ids: [mentor.id] })
    end
  end
end
