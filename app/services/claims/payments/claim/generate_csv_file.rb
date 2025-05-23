require "csv"

class Claims::Payments::Claim::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    claim_amount
    school_type_of_establishment
    school_group
    claim_submission_date
    claim_status
    claim_unpaid_reason
  ].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        csv << [
          claim.reference,
          claim.school.urn,
          claim.school_name,
          claim.school.local_authority_name,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.school.type_of_establishment,
          claim.school.group,
          claim.submitted_at&.iso8601,
          claim.status,
        ]
      end

      csv
    end
  end

  private

  attr_reader :claims

  def file_name
    Rails.root.join("tmp/payment-claims-#{Time.current}.csv")
  end
end
