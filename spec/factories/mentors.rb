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
#
# Indexes
#
#  index_mentors_on_trn  (trn) UNIQUE
#
FactoryBot.define do
  factory :mentor do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    trn { (0...9).to_a.sample(7).join }
  end

  factory :claims_mentor,
          class: "Claims::Mentor",
          parent: :mentor do
            schools { [association(:claims_school)] }
          end

  factory :placements_mentor,
          class: "Placements::Mentor",
          parent: :mentor do
            schools { [association(:placements_school)] }
          end
end
