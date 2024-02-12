# == Schema Information
#
# Table name: mentor_memberships
#
#  id         :uuid             not null, primary key
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mentor_id  :uuid             not null
#  school_id  :uuid             not null
#
# Indexes
#
#  index_mentor_memberships_on_mentor_id  (mentor_id)
#  index_mentor_memberships_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (school_id => schools.id)
#
class Claims::MentorMembership < MentorMembership
  belongs_to :mentor
  belongs_to :school
end
