class NotifyRateLimiter < ApplicationService
  attr_accessor :collection, :mailer, :mailer_method, :batch_size, :interval, :mailer_args, :mailer_kwargs

  def initialize(collection:, mailer:, mailer_method:, batch_size: 100, interval: 1.minute, mailer_args: [], mailer_kwargs: {})
    @collection = collection
    @mailer = mailer
    @mailer_method = mailer_method
    @mailer_args = mailer_args
    @mailer_kwargs = mailer_kwargs
    @batch_size = batch_size
    @interval = interval
  end

  def call
    collection.find_in_batches(batch_size:) do |batch|
      NotifyRateLimiterJob.perform_now(wait_time, batch, mailer, mailer_method, mailer_args, mailer_kwargs)
      @wait_time += interval
    end
  end

  private

  def wait_time
    @wait_time ||= 0.minutes
  end
end
