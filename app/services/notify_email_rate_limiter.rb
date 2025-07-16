class NotifyEmailRateLimiter
  BATCH_SIZE = 100

  def self.schedule!
    pending_ids = NotifyEmailQueue.pending.order(:created_at).limit(1000).pluck(:id)

    pending_ids.each_slice(BATCH_SIZE).with_index do |batch_ids, index|
      NotifyEmailBatchJob.set(wait: index.minutes).perform_later(batch_ids)
    end
  end
end
