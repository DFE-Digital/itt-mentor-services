FactoryBot.define do
  factory :subject do
    subject_area { %i[primary secondary].sample }
    name { Faker::Educator.subject }
    code { Faker::Alphanumeric.alpha(number: 2) }

    trait :primary do
      subject_area { :primary }
    end

    trait :secondary do
      subject_area { :secondary }
    end
  end
end
