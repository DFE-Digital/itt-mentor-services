# == Schema Information
#
# Table name: terms
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :placements_term, class: "Placements::Term" do
    name { "Any time in the academic year" }

    trait :spring do
      name { "Spring term" }
    end

    trait :summer do
      name { "Summer term" }
    end

    trait :autumn do
      name { "Autumn term" }
    end
  end
end
