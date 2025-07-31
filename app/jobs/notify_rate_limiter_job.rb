class NotifyRateLimiterJob < ApplicationJob
  queue_as :default

  def perform(wait_time, batch, mailer_class, mailer_method, mailer_args = [], mailer_kwargs = {})
    batch.each do |item|
      mailer_class.constantize.public_send(mailer_method, item, *mailer_args, **mailer_kwargs).deliver_later(wait: wait_time)
    end
  end
end
