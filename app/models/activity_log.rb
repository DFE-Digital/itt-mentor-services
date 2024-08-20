# == Schema Information
#
# Table name: activity_logs
#
#  id          :uuid             not null, primary key
#  activity    :string
#  record_type :string           not null
#  service     :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_id   :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_activity_logs_on_record   (record_type,record_id)
#  index_activity_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :record, polymorphic: true

  enum :service, claims: "claims", placements: "placements"
  enum :activity, payment_delivered: "payment_delivered"

  def self.policy_class
    "ActivityLogPolicy"
  end
end
