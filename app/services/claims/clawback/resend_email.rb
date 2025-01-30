class Claims::Clawback::ResendEmail < ApplicationService
  def initialize(clawback:)
    @clawback = clawback
  end

  def call
    Claims::ESFAMailer.resend_claims_require_clawback(clawback).deliver_later
  end

  private

  attr_reader :clawback
end
