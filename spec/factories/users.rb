# == Schema Information
#
# Table name: users
#
#  id                        :uuid             not null, primary key
#  dfe_sign_in_uid           :string
#  discarded_at              :datetime
#  email                     :string           not null
#  first_name                :string           not null
#  last_name                 :string           not null
#  last_signed_in_at         :datetime
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  selected_academic_year_id :uuid
#
# Indexes
#
#  index_users_on_selected_academic_year_id        (selected_academic_year_id)
#  index_users_on_type_and_discarded_at_and_email  (type,discarded_at,email)
#  index_users_on_type_and_email                   (type,email) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "User" }
    sequence(:last_name)
    sequence(:dfe_sign_in_uid) { _1 }

    trait :anne do
      first_name { "Anne" }
      last_name { "Wilson" }
      email { "anne_wilson@example.org" }
    end

    trait :patricia do
      first_name { "Patricia" }
      last_name { "Adebayo" }
      email { "patricia@example.com" }
    end

    trait :mary do
      first_name { "Mary" }
      last_name { "Lawson" }
      email { "mary@example.com" }
    end

    trait :colin do
      first_name { "Colin" }
      last_name { "Chapman" }
      email { "colin.chapman@education.gov.uk" }
    end

    trait :support do
      sequence(:email) { |n| "user#{n}@education.gov.uk" }

      first_name { "Support User" }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :next_academic_year do
      selected_academic_year { Placements::AcademicYear.current.next }
    end
  end

  factory :claims_user, class: "Claims::User", parent: :user
  factory :support_user, traits: [:support], parent: :user

  factory :placements_user,
          class: "Placements::User",
          parent: :user,
          traits: [:next_academic_year]

  factory :placements_support_user,
          class: "Placements::SupportUser",
          parent: :support_user,
          traits: [:next_academic_year]

  factory :claims_support_user,
          class: "Claims::SupportUser",
          parent: :support_user
end
