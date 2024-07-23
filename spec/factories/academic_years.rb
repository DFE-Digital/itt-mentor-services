FactoryBot.define do
  factory :academic_year do
    trait :current do
      starts_on { Date.parse("1 September #{Date.current.year - 1}") }
      ends_on { Date.parse("31 August #{Date.current.year}") }
      name { "#{starts_on.year} to #{ends_on.year}" }

      to_create { |instance| instance.save!(validate: false) }
    end
  end
end
