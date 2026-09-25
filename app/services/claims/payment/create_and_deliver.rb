class Claims::Payment::CreateAndDeliver < ApplicationService
  def initialize(current_user:, claim_window:)
    @current_user = current_user
    @claim_window = claim_window
  end

  def call
    return if submitted_claims.none?

    ActiveRecord::Base.transaction do |transaction|
      csv_file = Claims::Payments::Claim::GenerateCSVFile.call(claims: submitted_claims)

      payment = Claims::Payment.create!(sent_by: current_user, csv_file: File.open(csv_file.to_io), claims: submitted_claims)

      submitted_claims.find_each do |claim|
        claim.update!(status: :payment_in_progress, payment_in_progress_at: Time.current)
      end

      Claims::ClaimActivity.create!(action: :payment_request_delivered, user: current_user, record: payment)

      transaction.after_commit do
        Claims::PaymentMailer.payment_created_notification(payment).deliver_later
      end
    end
  end

  private

  attr_reader :current_user, :claim_window

  def submitted_claims
    @submitted_claims ||= Claims::Claim.submitted.where(claim_window:)
  end
end
