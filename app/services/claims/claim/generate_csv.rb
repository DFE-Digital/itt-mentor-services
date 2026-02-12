require "csv"

class Claims::Claim::GenerateCSV < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    school_type_of_establishment
    school_group
    provider_name
    provider_code
    claim_amount
    claim_submission_date
    claim_status
    claim_unpaid_reason
  ].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        csv << [
          claim.reference,
          claim.school.urn,
          claim.school_name,
          claim.school.local_authority_name,
          claim.school.type_of_establishment,
          claim.school.group,
          claim.provider_name,
          claim.provider_code,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.submitted_at&.iso8601,
          claim.status,
        ]
      end
    end
  end

  private

  attr_reader :claims
end
