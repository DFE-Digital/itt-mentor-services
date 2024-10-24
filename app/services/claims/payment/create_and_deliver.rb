class Claims::Payment::CreateAndDeliver < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    return if submitted_claims.none?

    ActiveRecord::Base.transaction do |transaction|
      payment = Claims::Payment.create!(sent_by: current_user, claim_ids: submitted_claims.pluck(:id))

      submitted_claims.find_each do |claim|
        claim.update!(status: :payment_in_progress)
      end

      Claims::ActivityLog.create!(activity: :payment_delivered, user: current_user, record: payment)

      transaction.after_commit do
        Claims::PaymentMailer.with(service: :claims).payment_created_notification(payment).deliver_later
      end
    end
  end

  private

  attr_reader :payment_params, :current_user

  def submitted_claims
    @submitted_claims ||= Claims::Claim.submitted
  end
end
