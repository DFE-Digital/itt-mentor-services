# == Schema Information
#
# Table name: payments
#
#  id         :uuid             not null, primary key
#  claim_ids  :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sent_by_id :uuid             not null
#
# Indexes
#
#  index_payments_on_sent_by_id  (sent_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (sent_by_id => users.id)
#
FactoryBot.define do
  factory :claims_payment, class: "Claims::Payment" do
    association :sent_by, factory: :claims_support_user
  end
end
