class Claims::Clawback::ResendEmail < ApplicationService
  def initialize(clawback:)
    @clawback = clawback
  end

  def call
    ActiveRecord::Base.transaction do |transaction|
      csv_file = Claims::Clawback::GenerateCSVFile.call(claims: clawback.claims)
      clawback.update!(csv_file: File.open(csv_file.to_io))

      transaction.after_commit do
        Claims::ESFAMailer.resend_claims_require_clawback(clawback).deliver_later
      end
    end
  end

  private

  attr_reader :clawback
end
