# == Schema Information
#
# Table name: mentor_memberships
#
#  id         :uuid             not null, primary key
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mentor_id  :uuid             not null
#  school_id  :uuid             not null
#
# Indexes
#
#  index_mentor_memberships_on_mentor_id                         (mentor_id)
#  index_mentor_memberships_on_school_id                         (school_id)
#  index_mentor_memberships_on_type_and_mentor_id                (type,mentor_id)
#  index_mentor_memberships_on_type_and_school_id_and_mentor_id  (type,school_id,mentor_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe MentorMembership, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:mentor) }
    it { is_expected.to belong_to(:school) }
  end

  context "with validations" do
    it "validates uniqueness of mentor_id scoped to type and school_id" do
      mentor = create(:mentor)
      school = create(:claims_school)
      create(:mentor_membership, :claims, mentor:, school:)
      duplicated_mentor_membership = build(:mentor_membership, :claims, mentor:, school:)

      expect(duplicated_mentor_membership).not_to be_valid
      expect(duplicated_mentor_membership.errors.messages)
        .to match(mentor_id: ["has already been taken"])
    end
  end
end
