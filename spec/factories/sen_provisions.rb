# == Schema Information
#
# Table name: sen_provisions
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sen_provisions_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :sen_provision do
    name { "ASD - Autistic Spectrum Disorder" }

    trait :asd do
      name { "ASD - Autistic Spectrum Disorder" }
    end

    trait :hi do
      name { "HI - Hearing Impairment" }
    end

    trait :not_applicable do
      name { "Not Applicable" }
    end
  end
end
