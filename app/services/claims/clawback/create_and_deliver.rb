class Claims::Clawback::CreateAndDeliver < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    return if clawback_requested_claims.none?

    ActiveRecord::Base.transaction do |transaction|
      csv_file = Claims::Clawback::GenerateCSVFile.call(claims: clawback_requested_claims)

      clawback = Claims::Clawback.create!(claims: clawback_requested_claims, csv_file: File.open(csv_file.to_io))

      clawback_requested_claims.find_each do |claim|
        claim.update!(status: :clawback_in_progress)
      end

      Claims::ClaimActivity.create!(action: :clawback_in_progress, user: current_user, record: clawback)

      transaction.after_commit do
        Claims::ESFAMailer.claims_require_clawback(clawback).deliver_later
      end
    end
  end

  private

  attr_reader :current_user

  def clawback_requested_claims
    @clawback_requested_claims ||= Claims::Claim.clawback_requested
  end
end
