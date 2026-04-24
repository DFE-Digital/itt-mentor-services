class NotifyRateLimiter < ApplicationService
  attr_accessor :collection, :mailer, :mailer_method, :batch_size, :interval, :mailer_args, :mailer_kwargs, :initial_wait_time

  def initialize(collection:, mailer:, mailer_method:, batch_size: 100, interval: 1.minute, mailer_args: [], mailer_kwargs: {}, initial_wait_time: 0.minutes)
    @collection = collection
    @mailer = mailer
    @mailer_method = mailer_method
    @mailer_args = mailer_args
    @mailer_kwargs = mailer_kwargs
    @batch_size = batch_size
    @interval = interval
    @initial_wait_time = initial_wait_time
  end

  def call
    collection.find_in_batches(batch_size:) do |batch|
      NotifyRateLimiterJob.perform_later(wait_time, batch, mailer, mailer_method, mailer_args, mailer_kwargs)
      @wait_time += interval
    end
  end

  private

  def wait_time
    @wait_time ||= initial_wait_time
  end
end
