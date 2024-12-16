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
class Claims::ClaimActivity < ApplicationRecord
  belongs_to :user
  belongs_to :record, polymorphic: true

  enum :action, { payment_delivered: "payment_delivered" }
end
