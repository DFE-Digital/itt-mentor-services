class AddAmendmentDeadlineNotificationSentAtToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :amendment_deadline_notification_sent_at, :datetime
  end
end
