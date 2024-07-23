FactoryBot.define do
  factory :claim_window, class: "Claims::ClaimWindow" do
    trait :current do
      starts_on { 2.days.ago }
      ends_on { 2.days.from_now }
      association :academic_year, :current

      to_create { |instance| instance.save!(validate: false) }
    end
  end
end
