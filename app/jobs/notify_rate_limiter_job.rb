class NotifyRateLimiterJob < ApplicationJob
  queue_as :default

  def perform(wait_time, batch, mailer:, mailer_method:)
    batch.each do |record|
      mailer.public_send(mailer_method, record).deliver_later(wait: wait_time)
    end
  end
end
