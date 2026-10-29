class Claims::RemoveUnprocessedPaymentResponsesJob < ApplicationJob
  queue_as :default

  def perform
    referenced_ids = Claims::ClaimStatusChange.where(source_type: "Claims::PaymentResponse").select(:source_id)
    activity_ids = Claims::ClaimActivity.where(record_type: "Claims::PaymentResponse").select(:record_id)
    Claims::PaymentResponse.where(processed: false, created_at: ..1.day.ago)
      .where.not(id: referenced_ids).where.not(id: activity_ids).find_each(&:destroy!)
  end
end
