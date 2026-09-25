# == Schema Information
#
# Table name: claims
#
#  id                     :uuid             not null, primary key
#  created_by_type        :string
#  payment_in_progress_at :datetime
#  reference              :string
#  reviewed               :boolean          default(FALSE)
#  sampling_reason        :text
#  status                 :enum
#  submitted_at           :datetime
#  submitted_by_type      :string
#  unpaid_reason          :text
#  zendesk_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  claim_window_id        :uuid
#  created_by_id          :uuid
#  provider_id            :uuid
#  school_id              :uuid             not null
#  submitted_by_id        :uuid
#  support_user_id        :uuid
#
# Indexes
#
#  index_claims_on_claim_window_id  (claim_window_id)
#  index_claims_on_created_by       (created_by_type,created_by_id)
#  index_claims_on_provider_id      (provider_id)
#  index_claims_on_reference        (reference)
#  index_claims_on_school_id        (school_id)
#  index_claims_on_submitted_by     (submitted_by_type,submitted_by_id)
#  index_claims_on_support_user_id  (support_user_id)
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

    claim_window { Claims::ClaimWindow.current || create(:claim_window, :current) }

    status { :internal_draft }

    trait :draft do
      status { :draft }
      reference { SecureRandom.random_number(99_999_999) }
    end

    trait :submitted do
      draft
      status { :submitted }
      submitted_at { Time.current }
      association :submitted_by, factory: :claims_user
    end

    trait :payment_in_progress do
      submitted
      status { :payment_in_progress }
      payment_in_progress_at { Time.current }
    end

    trait :payment_information_requested do
      payment_in_progress
      status { :payment_information_requested }
    end

    trait :payment_information_sent do
      payment_information_requested
      status { :payment_information_sent }
    end

    trait :payment_not_approved do
      status { :payment_not_approved }
    end

    trait :audit_requested do
      payment_in_progress
      status { :sampling_in_progress }
      sampling_reason { "Small claim" }
    end
  end
end
