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
FactoryBot.define do
  factory :mentor_membership do
    association :school
    association :mentor

    trait :claims do
      type { Claims::MentorMembership }
    end

    trait :placements do
      type { Placements::MentorMembership }
    end

    factory :claims_mentor_membership,
            class: "Claims::MentorMembership",
            parent: :mentor_membership

    factory :placements_mentor_membership,
            class: "Placements::MentorMembership",
            parent: :mentor_membership
  end
end
