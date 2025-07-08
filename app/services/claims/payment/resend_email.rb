class Claims::Payment::ResendEmail < ApplicationService
  def initialize(payment:)
    @payment = payment
  end

  def call
    ActiveRecord::Base.transaction do |transaction|
      csv_file = Claims::Payments::Claim::GenerateCSVFile.call(claims: payment.claims)
      payment.update!(csv_file: File.open(csv_file.to_io))

      transaction.after_commit do
        Claims::PaymentMailer.resend_payment_created_notification(payment).deliver_later
      end
    end
  end

  private

  attr_reader :payment
end
