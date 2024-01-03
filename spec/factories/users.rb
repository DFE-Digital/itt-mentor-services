# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  email        :string           not null
#  first_name   :string           not null
#  last_name    :string           not null
#  service      :enum             not null
#  support_user :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_service_and_email  (service,email) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "User" }
    service { %w[placements claims].sample }
    sequence(:last_name)

    trait :support do
      support_user { true }
    end
  end

  factory :claims_user, class: "Claims::User", parent: :user do
    service { "claims" }
  end

  factory :placements_user, class: "Placements::User", parent: :user do
    service { "placements" }
  end

  factory :placements_support_user,
          class: "Placements::SupportUser",
          parent: :user do
    service { "placements" }
  end

  factory :claims_support_user,
          class: "Claims::SupportUser",
          parent: :user do
    service { "claims" }
  end
end
