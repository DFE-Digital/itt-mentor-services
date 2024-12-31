class Claims::PaymentResponse::Process < ApplicationService
  def initialize(payment_response:, current_user:)
    @payment_response = payment_response
    @current_user = current_user
  end

  def call
    return if Claims::Claim.payment_in_progress.none?

    ActiveRecord::Base.transaction do
      CSV.parse(payment_response.csv_file.download, headers: true).each do |row|
        claim = Claims::Claim.find_by(reference: row["claim_reference"])

        next unless claim
        next unless claim.payment_in_progress?

        case row["claim_status"]
        when "paid"
          claim.update!(status: :paid)
        when "unpaid"
          claim.update!(status: :payment_information_requested, unpaid_reason: row["claim_unpaid_reason"])
        end
      end

      Claims::ClaimActivity.create!(action: :payment_response_uploaded, user: current_user, record: payment_response)

      payment_response
    end
  end

  private

  attr_reader :payment_response, :current_user
end
