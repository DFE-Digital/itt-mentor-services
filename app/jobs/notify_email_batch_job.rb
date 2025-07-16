class NotifyEmailBatchJob < ApplicationJob
  queue_as :default

  def perform(email_ids)
    NotifyEmailQueue.where(id: email_ids).find_each do |email|
      notify_client.send_email(
        email_address: email.recipient,
        subject: email.subject,
        body: email.body,
      )
      email.update!(status: :sent, sent_at: Time.current)
    rescue StandardError => e
      email.update!(status: :failed, error: e.message)
      Rails.logger.error("[NotifyEmail] Failed for #{email.recipient}: #{e.message}")
    end
  end

  def notify_client
    #unsure as of yet what should go here
  end
end
