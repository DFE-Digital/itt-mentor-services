# == Schema Information
#
# Table name: claim_activities
#
#  id          :uuid             not null, primary key
#  action      :string
#  record_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_id   :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_claim_activities_on_record   (record_type,record_id)
#  index_claim_activities_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :claim_activity, class: "Claims::ClaimActivity" do
    association :user, factory: :claims_support_user

    trait :payment_request_delivered do
      action { "payment_request_delivered" }

      record { build(:claims_payment, sent_by: user) }
    end

    trait :sampling_uploaded do
      action { "sampling_uploaded" }

      record { build(:claims_sampling) }
    end
  end
end
