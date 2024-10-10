class Claims::Payment::ParseConfirmation < ApplicationService
  def initialize(file:)
    @file = file
  end

  def call
    CSV.foreach(file, headers: true) do |row|
      next unless row["claim_status"].in? %w[paid unpaid]

      claim = Claims::Claim.find_by(reference: row["claim_reference"])

      next unless claim.status.in? %w[payment_in_progress payment_information_sent payment_information_requested]

      if row["claim_status"] == "paid"
        claim.update!(status: :paid)
      elsif row["claim_status"] == "unpaid"
        claim.update!(status: :payment_information_requested, unpaid_reason: row["claim_unpaid_reason"])
      end
    end
  end

  private

  attr_reader :file
end
