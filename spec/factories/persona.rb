FactoryBot.define do
  factory :persona do
    email { "anne_wilson@example.org" }
    first_name { "Persona" }
    service { "claims" }
    sequence(:last_name)

    trait :anne do
      first_name { "Anne" }
      last_name { "Wilson" }
    end

    trait :patricia do
      email { "patricia@example.com" }
      first_name { "Patricia" }
      last_name { "Adebayo" }
    end

    trait :mary do
      email { "mary@example.com" }
      first_name { "Mary" }
      last_name { "Lawson" }
    end

    trait :colin do
      email { "colin@example.com" }
      first_name { "Colin" }
      last_name { "Chapman" }
      support_user { true }
    end
  end
end
