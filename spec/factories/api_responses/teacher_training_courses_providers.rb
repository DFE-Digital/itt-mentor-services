# Use this to stub providers in the Teacher Training Courses API
FactoryBot.define do
  factory :teacher_training_courses_provider, class: "Hash" do
    initialize_with do
      {
        id: attributes.fetch(:id),
        type: "providers",
        attributes: attributes.except(:id),
      }.deep_stringify_keys
    end
    
    sequence(:id) { |n| (10_000 + n).to_s }
    code { generate :provider_code }
    name { Faker::Company.name }
    email { Faker::Internet.email }
    website { Faker::Internet.url(path: nil) }
    ukprn
    accredited_body { false }

    trait :accredited do
      accredited_body { true }
    end
  end
end
