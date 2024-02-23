FactoryBot.define do
  factory :subject do
    subject_area { %w[primary secondary].sample }
    name { Faker::Educator.subject }
  end
end
