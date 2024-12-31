class Claims::RemoveUnprocessedPaymentResponsesJob < ApplicationJob
  queue_as :default

  def perform
    Claims::PaymentResponse.where(processed: false, created_at: ..1.day.ago).find_each(&:destroy!)
  end
end
