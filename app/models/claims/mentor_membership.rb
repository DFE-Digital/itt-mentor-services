class Claims::MentorMembership < MentorMembership
  belongs_to :mentor
  belongs_to :school
end
