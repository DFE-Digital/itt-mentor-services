# == Schema Information
#
# Table name: hosting_interests
#
#  id                  :uuid             not null, primary key
#  appetite            :enum
#  reasons_not_hosting :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  academic_year_id    :uuid             not null
#  school_id           :uuid             not null
#
# Indexes
#
#  index_hosting_interests_on_academic_year_id                (academic_year_id)
#  index_hosting_interests_on_school_id                       (school_id)
#  index_hosting_interests_on_school_id_and_academic_year_id  (school_id,academic_year_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Placements::HostingInterest, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:academic_year) }
  end

  describe "validations" do
    subject(:hosting_interest) { build(:hosting_interest) }

    it { is_expected.to validate_uniqueness_of(:academic_year_id).scoped_to(:school_id).case_insensitive }
  end

  describe "enums" do
    subject(:hosting_interest) { build(:hosting_interest) }

    it "defines the expected values" do
      expect(hosting_interest).to define_enum_for(:appetite)
        .with_values(
          actively_looking: "actively_looking",
          interested: "interested",
          not_open: "not_open",
          already_organised: "already_organised",
        )
        .backed_by_column_of_type(:enum)
    end
  end

  describe "scopes" do
    describe "for_academic_year" do
      let(:current_year_hosting_interest_1) { create(:hosting_interest) }
      let(:current_year_hosting_interest_2) { create(:hosting_interest) }
      let(:previous_year_hosting_interest) do
        create(:hosting_interest, academic_year: Placements::AcademicYear.current.previous)
      end
      let(:next_year_hosting_interest) do
        create(:hosting_interest, academic_year: Placements::AcademicYear.current.previous)
      end

      it "returns the hosting interests for the given academic year" do
        expect(
          described_class.for_academic_year(Placements::AcademicYear.current),
        ).to contain_exactly(
          current_year_hosting_interest_1,
          current_year_hosting_interest_2,
        )
      end
    end
  end
end
