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
FactoryBot.define do
  factory :mentor do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:trn) { _1 }
  end

  factory :claims_mentor,
          class: "Claims::Mentor",
          parent: :mentor

  factory :placements_mentor,
          class: "Placements::Mentor",
          parent: :mentor
end
