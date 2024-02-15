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

RSpec.describe Placements::MentorMembership, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:mentor) }
    it { is_expected.to belong_to(:school) }
  end

  it "returns Placements::Mentor when calling #mentor" do
    mentor = create(:placements_mentor)
    mentor_membership = create(
      :mentor_membership,
      :placements,
      mentor:,
    )

    expect(mentor_membership.mentor).to be_a(Placements::Mentor)
  end

  it "returns Placements::School when calling #school" do
    school = create(:placements_school)
    mentor_membership = create(
      :mentor_membership,
      :placements,
      school:,
    )

    expect(mentor_membership.school).to be_a(Placements::School)
  end
end
