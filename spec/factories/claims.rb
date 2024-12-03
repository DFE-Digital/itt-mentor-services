# == Schema Information
#
# Table name: claims
#
#  id                   :uuid             not null, primary key
#  created_by_type      :string
#  reference            :string
#  reviewed             :boolean          default(FALSE)
#  sampling_reason      :text
#  status               :enum
#  submitted_at         :datetime
#  submitted_by_type    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  claim_window_id      :uuid
#  created_by_id        :uuid
#  previous_revision_id :uuid
#  provider_id          :uuid
#  school_id            :uuid             not null
#  submitted_by_id      :uuid
#
# Indexes
#
#  index_claims_on_claim_window_id       (claim_window_id)
#  index_claims_on_created_by            (created_by_type,created_by_id)
#  index_claims_on_previous_revision_id  (previous_revision_id)
#  index_claims_on_provider_id           (provider_id)
#  index_claims_on_reference             (reference)
#  index_claims_on_school_id             (school_id)
#  index_claims_on_submitted_by          (submitted_by_type,submitted_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
FactoryBot.define do
  factory :claim, class: "Claims::Claim" do
    association :school, factory: :claims_school
    association :provider, factory: :claims_provider
    association :created_by, factory: :claims_user
    association :submitted_by, factory: :claims_user

    claim_window { Claims::ClaimWindow.current || create(:claim_window, :current) }

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
