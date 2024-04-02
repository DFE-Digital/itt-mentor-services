# == Schema Information
#
# Table name: claims
#
#  id                :uuid             not null, primary key
#  created_by_type   :string
#  reference         :string
#  status            :enum
#  submitted_at      :datetime
#  submitted_by_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :uuid
#  provider_id       :uuid
#  school_id         :uuid             not null
#  submitted_by_id   :uuid
#
# Indexes
#
#  index_claims_on_created_by    (created_by_type,created_by_id)
#  index_claims_on_provider_id   (provider_id)
#  index_claims_on_reference     (reference) UNIQUE
#  index_claims_on_school_id     (school_id)
#  index_claims_on_submitted_by  (submitted_by_type,submitted_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
FactoryBot.define do
  factory :claim, class: "Claims::Claim" do
    association :school, factory: :claims_school
    association :provider
    association :created_by, factory: :claims_user

    status { :internal_draft }

    trait :draft do
      status { :draft }
      reference { SecureRandom.random_number(99_999_999) }
    end

    trait :submitted do
      status { :submitted }
      submitted_at { Time.current }
      reference { SecureRandom.random_number(99_999_999) }
    end
  end
end
