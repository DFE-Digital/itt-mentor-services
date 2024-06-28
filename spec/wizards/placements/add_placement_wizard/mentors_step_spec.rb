require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::MentorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:school) { create(:placements_school, mentors:) }
  let(:mentors) { build_list(:placements_mentor, 5) }

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_ids) }
  end

  describe "#mentors_for_selection" do
    let(:mentors) do
      [
        build(:placements_mentor, first_name: "Homer", last_name: "Simpson"),
        build(:placements_mentor, first_name: "Marge", last_name: "Simpson"),
        build(:placements_mentor, first_name: "Bart", last_name: "Simpson"),
        build(:placements_mentor, first_name: "Lisa", last_name: "Simpson"),
        build(:placements_mentor, first_name: "Maggie", last_name: "Simpson"),
      ]
    end

    it "returns mentors for the school, ordered by name" do
      expect(step.mentors_for_selection).to eq(school.mentors.order_by_full_name)
      expect(step.mentors_for_selection.map(&:full_name)).to eq([
        "Bart Simpson",
        "Homer Simpson",
        "Lisa Simpson",
        "Maggie Simpson",
        "Marge Simpson",
      ])
    end
  end

  describe "#mentor_ids=" do
    context "when the value is blank" do
      it "remains blank" do
        step.mentor_ids = []

        expect(step.mentor_ids).to eq([])
      end
    end

    context "when the value includes 'not_known'" do
      it "removes all values except not_known" do
        step.mentor_ids = ["not_known", mentors.first.id]

        expect(step.mentor_ids).to eq(%w[not_known])
      end
    end

    context "when the value includes mentor ids" do
      it "retains the mentor ids" do
        step.mentor_ids = school.mentors.ids

        expect(step.mentor_ids).to match_array(school.mentors.ids)
      end

      context "and the values include mentors from another school" do
        it "retains only the mentors from the target school" do
          another_school = create(:placements_school, mentors: build_list(:placements_mentor, 1))

          step.mentor_ids = another_school.mentors.ids + school.mentors.ids

          expect(step.mentor_ids).to match_array(school.mentors.ids)
        end
      end
    end
  end
end
