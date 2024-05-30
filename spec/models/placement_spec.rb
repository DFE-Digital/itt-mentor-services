# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
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

RSpec.describe Placement, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_mentor_joins).dependent(:destroy) }
    it { is_expected.to have_many(:mentors).through(:placement_mentor_joins) }

    it { is_expected.to have_many(:placement_subject_joins).dependent(:destroy) }
    it { is_expected.to have_many(:subjects).through(:placement_subject_joins) }
    it { is_expected.to have_many(:placement_additional_subjects).class_name("Placements::PlacementAdditionalSubject").dependent(:destroy) }
    it { is_expected.to have_many(:additional_subjects).through(:placement_additional_subjects).class_name("Subject") }

    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:provider).optional }
    it { is_expected.to belong_to(:subject).optional } # TODO: Remove optional after data migration
  end

  describe "validations" do
    subject { build(:placement) }

    it { is_expected.to validate_presence_of(:school) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:has_child_subjects?).to(:subject).with_prefix(true).allow_nil }
  end

  describe "scopes" do
    describe "#order_by_subject_school_name" do
      it "returns the placements ordered by their associated schools name" do
        school_a = create(:placements_school, name: "Abbey School")
        school_b = create(:placements_school, name: "Bentley School")

        subject_a = create(:subject, name: "Art and design")
        subject_b = create(:subject, name: "Biology")

        placement_1 = create(:placement, school: school_b, subjects: [subject_a])
        placement_2 = create(:placement, school: school_a, subjects: [subject_b])
        placement_3 = create(:placement, school: school_b, subjects: [subject_b])
        placement_4 = create(:placement, school: school_b, subjects: [subject_a, subject_b])

        expect(described_class.order_by_subject_school_name).to eq(
          [placement_1, placement_4, placement_2, placement_3],
        )
      end
    end
  end

  describe "order_by_school_ids" do
    it "returns placements ordered by a given list of school ids" do
      school_1 = create(:placements_school)
      school_2 = create(:placements_school)
      school_3 = create(:placements_school)

      placement_1 = create(:placement, school: school_1)
      placement_2 = create(:placement, school: school_2)
      placement_3 = create(:placement, school: school_3)

      expect(
        described_class.order_by_school_ids(
          [school_2.id, school_3.id, school_1.id],
        ),
      ).to eq(
        [placement_2, placement_3, placement_1],
      )

      expect(
        described_class.order_by_school_ids(
          [school_3.id, school_2.id, school_1.id],
        ),
      ).to eq(
        [placement_3, placement_2, placement_1],
      )
    end
  end

  # TODO: Remove after data migrated
  describe "#assign_subject" do
    subject(:placement) { create(:placement, subjects:, subject: a_subject) }

    context "when no subjects have been associated with the placement" do
      let(:subjects) { [] }
      let(:a_subject) { nil }

      it "does not assign a subject" do
        expect(placement.subject).to eq(nil)
      end
    end

    context "when subjects have been associated with the placement" do
      context "when subject is nil" do
        let(:subjects) { [create(:subject)] }
        let(:a_subject) { nil }

        it "assigns a subject to the placement" do
          expect(placement.subject).to eq(subjects.last)
        end
      end

      context "when subject is not nil" do
        let(:subjects) { [create(:subject)] }
        let(:a_subject) { create(:subject) }

        it "keeps the original subject assigned to the placement" do
          expect(placement.subject).to eq(a_subject)
        end
      end
    end
  end

  describe "#additional_subject_names" do
    it "returns the names of additional subjects" do
      subject = build(:subject, name: "Modern foreign languages")
      additional_subjects = [build(:subject, name: "French", parent_subject: subject),
                             build(:subject, name: "Spanish", parent_subject: subject)]

      placement = create(:placement, subject:, additional_subjects:)

      expect(placement.becomes(Placements::Schools::Placements::Build::Placement).additional_subject_names).to eq(%w[French Spanish])
    end
  end
end
