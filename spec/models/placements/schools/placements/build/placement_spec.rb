require "rails_helper"

RSpec.describe Placements::Schools::Placements::Build::Placement, type: :model do
  let!(:school) { create(:placements_school) }

  describe "#valid_phase?" do
    it "returns false if phase is blank" do
      placement = described_class.new(phase: nil)

      expect(placement.valid_phase?).to eq(false)
    end

    it "returns false if phase is not valid" do
      placement = described_class.new(phase: "invalid")

      expect(placement.valid_phase?).to eq(false)
    end

    it "returns true if phase is valid" do
      placement = described_class.new(phase: School::PRIMARY_PHASE)

      expect(placement.valid_phase?).to eq(true)
    end
  end

  describe "#valid_mentor_ids?" do
    it "returns false if mentor_ids is blank" do
      placement = described_class.new(mentor_ids: nil, school:)

      expect(placement.valid_mentor_ids?).to eq(false)
    end

    it "returns false if mentor_ids is not valid" do
      other_school = create(:placements_school)
      mentor = create(:placements_mentor_membership, school: other_school).mentor
      placement = described_class.new(mentor_ids: [mentor.id], school:)

      expect(placement.valid_mentor_ids?).to eq(false)
    end

    it "returns true if mentor_ids is valid" do
      mentor = create(:placements_mentor_membership, school:).mentor
      placement_1 = described_class.new(mentor_ids: [mentor.id], school:)
      placement_2 = described_class.new(mentor_ids: %w[not_known], school:)

      expect(placement_1.valid_mentor_ids?).to eq(true)
      expect(placement_2.valid_mentor_ids?).to eq(true)
    end
  end

  describe "#valid_subjects?" do
    it "returns false if subjects is blank" do
      placement_1 = described_class.new(subject_ids: [], school:)
      placement_2 = described_class.new(subject_ids: "", school:)

      expect(placement_1.valid_subjects?).to eq(false)
      expect(placement_2.valid_subjects?).to eq(false)
    end

    it "returns false if subject does not match phase" do
      primary_subject = create(:subject, :primary)
      secondary_subject = create(:subject, :secondary)
      placement = described_class.new(phase: "primary", subject_ids: [primary_subject.id, secondary_subject.id], school:)

      expect(placement.valid_subjects?).to eq(false)
    end

    it "returns true if subjects is valid" do
      placement = described_class.new(phase: "primary", subject_ids: [create(:subject, :primary).id], school:)

      expect(placement.valid_subjects?).to eq(true)
    end
  end

  describe "#all_valid?" do
    it "returns false if phase is not valid" do
      placement = described_class.new(phase: "invalid", school:)

      expect(placement.all_valid?).to eq(false)
    end

    it "returns false if mentor_ids is not valid" do
      placement = described_class.new(mentor_ids: [], school:)

      expect(placement.all_valid?).to eq(false)
    end

    it "returns false if subjects is not valid" do
      placement = described_class.new(subjects: [], school:)

      expect(placement.all_valid?).to eq(false)
    end

    it "returns true if all are valid" do
      mentor = create(:placements_mentor_membership, school:).mentor
      subject = create(:subject, :primary)
      placement = described_class.new(phase: School::PRIMARY_PHASE, mentor_ids: [mentor.id], subject_ids: [subject.id],
                                      school:)

      expect(placement.all_valid?).to eq(true)
    end
  end
end
