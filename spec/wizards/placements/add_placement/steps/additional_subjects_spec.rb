require "rails_helper"

RSpec.describe Placements::AddPlacement::Steps::AdditionalSubjects, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil, parent_subject_id: nil, additional_subject_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:parent_subject_id) }
    it { is_expected.to validate_presence_of(:additional_subject_ids) }

    describe "#additional_subjects_valid" do
      let(:school) { create(:placements_school) }
      let(:parent_subject) { create(:subject) }

      it "is invalid of the subject does not exist" do
        step = described_class.new(parent_subject_id: parent_subject.id, additional_subject_ids: %w[not_a_subject])

        expect(step).to be_invalid
      end

      it "is valid if all additional subjects exist" do
        child_subject = create(:subject, parent_subject:)
        step = described_class.new(school:, parent_subject_id: parent_subject.id, additional_subject_ids: [child_subject.id])

        expect(step).to be_valid
      end
    end
  end

  describe "#additional_subjects_for_selection" do
    let(:parent_subject) { create(:subject) }
    let(:child_subject) { create(:subject, parent_subject:) }

    it "returns additional subjects for the subject" do
      step = described_class.new(parent_subject_id: parent_subject.id)

      expect(step.additional_subjects_for_selection).to eq([child_subject])
    end
  end

  describe "#additional_subject_ids=" do
    let(:parent_subject) { create(:subject) }

    it "normalises the value to an array" do
      step = described_class.new

      step.additional_subject_ids = parent_subject.id

      expect(step.additional_subject_ids).to eq([parent_subject.id])
    end
  end

  describe "#wizard_attributes" do
    let(:parent_subject) { create(:subject) }

    it "returns the additional_subject_ids" do
      step = described_class.new(additional_subject_ids: [parent_subject.id])

      expect(step.wizard_attributes).to eq({ additional_subject_ids: [parent_subject.id] })
    end
  end
end
