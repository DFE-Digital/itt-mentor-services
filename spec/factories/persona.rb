FactoryBot.define do
  factory :persona do
    email { "anne_wilson@example.org" }
    first_name { "Persona" }
    sequence(:last_name)

    trait :anne do
      first_name { "Anne" }
      last_name { "Wilson" }
    end
  end
end
