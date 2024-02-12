# == Schema Information
#
# Table name: mentors
#
#  id         :uuid             not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  trn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid             not null
#
# Indexes
#
#  index_mentors_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Placements::Mentor < Mentor
  has_many :mentor_memberships
  has_many :schools, through: :mentor_memberships

  default_scope { joins(:mentor_memberships) }
end
