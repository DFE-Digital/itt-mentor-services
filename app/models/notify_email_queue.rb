class NotifyEmailQueue < ApplicationRecord
  enum status: { pending: 0, sent: 1, failed: 2 }

  validates :recipient, :subject, :body, presence: true
end
