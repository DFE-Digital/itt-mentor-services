class NotifyRateLimiter < ApplicationService
  attr_accessor :collection, :mailer, :mailer_method, :batch_size, :interval

  def initialize(collection:, mailer:, mailer_method:, batch_size: 100, interval: 1.minute)
    @collection = collection
    @mailer = mailer
    @mailer_method = mailer_method
    @batch_size = batch_size
    @interval = interval
  end

  def call
    collection.find_in_batches(batch_size:) do |batch|
      NotifyRateLimiterJob.perform_later(wait_time, batch, mailer:, mailer_method:)
      @wait_time += interval
    end
  end

  private

  def wait_time
    @wait_time ||= 0.minutes
  end
end
