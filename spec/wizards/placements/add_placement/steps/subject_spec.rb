require "rails_helper"

RSpec.describe Placements::AddPlacement::Steps::Subject, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil, phase: nil, subject_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:phase) }
    it { is_expected.to validate_presence_of(:subject_id) }
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

      expect(step.subject_has_child_subjects?).to eq(true)
    end

    it "returns false if the subject does not have child subjects" do
      subject = create(:subject, :primary)
      step = described_class.new(subject_id: subject.id)

      expect(step.subject_has_child_subjects?).to eq(false)
    end
  end
end
