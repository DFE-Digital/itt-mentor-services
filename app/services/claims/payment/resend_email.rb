class Claims::Payment::ResendEmail < ApplicationService
  def initialize(payment:)
    @payment = payment
  end

  def call
    Claims::PaymentMailer.resend_payment_created_notification(payment).deliver_later
  end

  private

  attr_reader :payment
end
