class Placements::Mentor < Mentor
  has_many :mentor_memberships
  has_many :schools, through: :mentor_memberships

  default_scope { joins(:mentor_memberships).merge(Placements::MentorMembership.all) }
end
