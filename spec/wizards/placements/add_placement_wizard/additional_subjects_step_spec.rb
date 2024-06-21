require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::AdditionalSubjectsStep, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil, parent_subject_id: nil, additional_subject_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:parent_subject_id) }

    describe "additional subjects validation" do
      let(:school) { create(:placements_school) }
      let(:parent_subject) { create(:subject) }

      it "is invalid if the parent subject is present and additional subjects are blank" do
        step = described_class.new(school:, parent_subject_id: parent_subject.id)

        expect(step).to be_invalid
      end

      it "is invalid if the additional subject does not exist" do
        child_subject = create(:subject, parent_subject:)
        step = described_class.new(school:, parent_subject_id: parent_subject.id, additional_subject_ids: ["not_a_subject", child_subject.id])

        expect(step).to be_invalid
      end

      it "is valid if all additional subjects exist and are children of the parent subject" do
        child_subject = create(:subject, parent_subject:)
        child_subject_2 = create(:subject, parent_subject:)
        step = described_class.new(school:, parent_subject_id: parent_subject.id, additional_subject_ids: [child_subject.id, child_subject_2.id])

        expect(step).to be_valid
      end
    end
  end

  describe "#additional_subjects_for_selection" do
    let(:parent_subject) { create(:subject) }
    let(:child_subject) { create(:subject, parent_subject:) }

    it "returns child subjects of the parent subject" do
      step = described_class.new(parent_subject_id: parent_subject.id)

      expect(step.additional_subjects_for_selection).to eq([child_subject])
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
