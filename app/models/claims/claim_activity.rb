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
  belongs_to :user, class_name: "Claims::SupportUser"
  belongs_to :record, polymorphic: true

  enum :action, {
    payment_request_delivered: "payment_request_delivered",
    payment_response_uploaded: "payment_response_uploaded",
    sampling_uploaded: "sampling_uploaded",
    sampling_response_uploaded: "sampling_response_uploaded",
    clawback_request_delivered: "clawback_request_delivered",
    clawback_response_uploaded: "clawback_response_uploaded",
    sampling_approved_manually: "sampling_approved_manually",
    rejected_by_provider: "rejected_by_provider",
    rejected_by_school: "rejected_by_school",
    clawback_requested: "clawback_requested",
  }, validate: true

  delegate :full_name, to: :user, prefix: true, allow_nil: true
end
