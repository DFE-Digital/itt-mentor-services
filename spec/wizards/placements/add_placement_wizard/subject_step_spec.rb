require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::SubjectStep, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(phase: nil, subject_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phase) }

    describe "subject_id" do
      it "is not required if phase is not present" do
        step = described_class.new(phase: nil)

        expect(step).not_to validate_presence_of(:subject_id)
      end

      it "is required if phase is present" do
        step = described_class.new(phase: "Primary")

        expect(step).to validate_presence_of(:subject_id)
      end

      it "is invalid if the subject is not in the selection" do
        step = described_class.new(phase: "Primary", subject_id: 1)

        expect(step).not_to be_valid
        expect(step.errors[:subject_id]).to include "is not included in the list"
      end
    end
  end

  describe "#subjects_for_selection" do
    it "returns primary subjects when phase is Primary" do
      subject = create(:subject, :primary)
      step = described_class.new(phase: "Primary")

      expect(step.subjects_for_selection).to eq([subject])
    end

    it "returns secondary subjects when phase is Secondary" do
      subject = create(:subject, :secondary)
      step = described_class.new(phase: "Secondary")

      expect(step.subjects_for_selection).to eq([subject])
    end
  end

  describe "#wizard_attributes" do
    it "returns the subject_id" do
      step = described_class.new(subject_id: 1)

      expect(step.wizard_attributes).to eq({ subject_id: 1 })
    end
  end

  describe "#subject_has_child_subjects?" do
    it "returns true if the subject has child subjects" do
      subject = create(:subject, :primary, child_subjects: [build(:subject, :primary)])
      step = described_class.new(subject_id: subject.id)

      expect(step.subject_has_child_subjects?).to be(true)
    end

    it "returns false if the subject does not have child subjects" do
      subject = create(:subject, :primary)
      step = described_class.new(subject_id: subject.id)

      expect(step.subject_has_child_subjects?).to be(false)
    end
  end
end