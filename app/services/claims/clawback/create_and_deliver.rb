class Claims::Clawback::CreateAndDeliver < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    clawback_requested_claims = Claims::Claim.clawback_requested
    return if clawback_requested_claims.none?

    ActiveRecord::Base.transaction do |transaction|
      clawback = Claims::Clawback.create!(claims: clawback_requested_claims)

      clawback_requested_claims.each do |claim|
        Claims::Claim::ChangeStatus.call(
          claim:, actor: current_user, source: clawback, expected_status: :clawback_requested,
          attributes: { status: :clawback_in_progress }
        )
      end

      csv_file = Claims::Clawback::GenerateCSVFile.call(claim_ids: clawback.claim_ids)
      clawback.csv_file.attach(io: File.open(csv_file.to_io), filename: File.basename(csv_file.to_io))

      Claims::ClaimActivity.create!(action: :clawback_request_delivered, user: current_user, record: clawback)

      transaction.after_commit do
        Claims::ESFAMailer.claims_require_clawback(clawback).deliver_later
      end
    end
  end

  private

  attr_reader :current_user
end
