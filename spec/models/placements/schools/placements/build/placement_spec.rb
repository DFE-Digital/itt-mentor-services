# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  year_group  :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#  subject_id  :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#  index_placements_on_subject_id   (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (subject_id => subjects.id)
#
require "rails_helper"

RSpec.describe Placements::Schools::Placements::Build::Placement, type: :model do
  let!(:school) { create(:placements_school) }

  describe "delegations" do
    it { is_expected.to delegate_method(:has_child_subjects?).to(:subject).with_prefix(true).allow_nil }
  end

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

  describe "#valid_subject?" do
    it "returns false if subject is blank" do
      placement_1 = described_class.new(subject_id: nil, school:)

      expect(placement_1.valid_subject?).to eq(false)
    end

    it "returns false if subject does not match phase" do
      invalid_subject = create(:subject, :secondary)
      placement = described_class.new(phase: "primary", subject: invalid_subject, school:)

      expect(placement.valid_subject?).to eq(false)
    end

    it "returns true if subject is valid" do
      placement = described_class.new(phase: "primary", subject: create(:subject, :primary), school:)

      expect(placement.valid_subject?).to eq(true)
    end
  end

  describe "#valid_additional_subjects?" do
    it "returns false if additional_subject_ids is blank" do
      placement = described_class.new(additional_subject_ids: nil)

      expect(placement.valid_additional_subjects?).to eq(false)
    end

    it "returns true if additional_subject_ids is valid" do
      subject = create(:subject, :primary)
      placement = described_class.new(additional_subject_ids: [subject.id])

      expect(placement.valid_additional_subjects?).to eq(true)
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

    it "returns true if all are valid" do
      mentor = create(:placements_mentor_membership, school:).mentor
      subject = create(:subject, :primary)
      additional_subject = create(:subject, :primary, parent_subject: subject)
      placement = described_class.new(phase: School::PRIMARY_PHASE, mentor_ids: [mentor.id], subject:,
                                      school:, additional_subject_ids: [additional_subject.id])

      expect(placement.all_valid?).to eq(true)
    end
  end

  describe "build_additional_subjects" do
    context "when passed an array" do
      it "builds additional subjects" do
        placement = described_class.new(school:)
        subject_1 = create(:subject)
        subject_2 = create(:subject)

        placement.build_additional_subjects([subject_1.id, subject_2.id])

        expect(placement.additional_subjects).to match_array([
          have_attributes(subject_1.attributes),
          have_attributes(subject_2.attributes),
        ])
      end
    end

    context "when passed nil" do
      it "builds additional subjects" do
        placement = described_class.new(school:)

        placement.build_additional_subjects

        expect(placement.additional_subjects).to match_array([
          have_attributes(Subject.new.attributes),
        ])
      end
    end
  end

  describe "#build_mentors" do
    context "when passed an array" do
      it "builds mentors" do
        placement = described_class.new(school:)
        mentor_1 = create(:placements_mentor_membership, school:, mentor: create(:placements_mentor)).mentor
        mentor_2 = create(:placements_mentor_membership, school:, mentor: create(:placements_mentor)).mentor

        placement.build_mentors([mentor_1.id, mentor_2.id])

        expect(placement.mentors).to match_array([
          have_attributes(mentor_1.attributes),
          have_attributes(mentor_2.attributes),
        ])
      end
    end

    context "when passed nil" do
      it "builds mentors" do
        placement = described_class.new(school:)

        placement.build_mentors

        expect(placement.mentors).to match_array([
          have_attributes(Placements::Mentor.new.attributes),
        ])
      end
    end
  end

  describe "#build_phase" do
    context "when passed a phase" do
      it "returns the phase" do
        placement = described_class.new

        expect(placement.build_phase("Primary")).to eq("Primary")
      end
    end

    context "when phase is blank and the school phase is set" do
      it "returns the school's phase" do
        allow(school).to receive(:phase).and_return("Primary")
        placement = described_class.new(school:)

        expect(placement.build_phase(nil)).to eq(school.phase)
      end
    end

    context "when phase is blank and the school phase is not set" do
      it "returns 'Primary'" do
        allow(school).to receive(:phase).and_return(nil)
        placement = described_class.new(school:)

        expect(placement.build_phase(nil)).to eq("Primary")
      end
    end
  end
end
