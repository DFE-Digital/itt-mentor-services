FactoryBot.define do
  factory :subject do
    subject_area { %w[primary secondary].sample }
    name { Faker::Educator.subject }
    code { Faker::Alphanumeric.alpha(number: 2) }
  end

  trait :primary do
    subject_area { "primary" }
  end

  trait :secondary do
    subject_area { "secondary" }
  end
end
