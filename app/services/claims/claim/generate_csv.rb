require "csv"

class Claims::Claim::GenerateCSV < ApplicationService
  HEADERS = %w[claim_reference urn school_name local_authority claim_amount type_of_establishment establishment_type date_submitted claim_status].freeze

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
          claim.school.name,
          claim.school.local_authority_name,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.school.type_of_establishment,
          claim.school.group,
          claim.submitted_at&.iso8601,
          claim.status,
        ]
      end
    end
  end

  private

  attr_reader :claims
end
