# == Schema Information
#
# Table name: payment_responses
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  processed     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_payment_responses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :claims_payment_response, class: "Claims::PaymentResponse" do
    association :user, factory: :claims_support_user

    csv_file { file_fixture("example-payments-response.csv") }
  end
end
